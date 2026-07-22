#!/bin/bash
# This script installs Android Cuttlefish on Ubuntu. It is based on the official Android Cuttlefish installation instructions for Ubuntu, which can be found here: https://source.android.com/docs/devices/cuttlefish/get-started
# Ask user to confirm before proceeding, as this script will make changes to the system and may require a restart. The user can choose to skip the installation if they do not want to proceed.

# Call messages.sh to define font colours for outputting errors (red), warnings(yellow), information (cyan) or confirmation (green)
source "$(dirname "$0")/../lib/messages.sh"
define_font_colours

FURTHER_STEPS_MESSAGE="$(cat << EOT
1. Cuttlefish is part of the Android Open-Source Platform (AOSP). Builds of the virtual device are found at the Android Continuous Integration site. To find an index of all Android builds, navigate to the Android Continuous Integration site at http://ci.android.com/.

2. Enter a branch name, if it has not been done already. Use the default aosp-android-latest-release branch or use a generic system image (GSI) branch such as aosp-android13-gsi  or aosp-android14-gsi.

3. Navigate to the aosp_cf_x86_64_only_phone build target and click userdebug for the latest build.
Tip: For ARM64, use the branch aosp-android-latest-release and the device target aosp_cf_arm64_only_phone-userdebug.

4. Click the green box below userdebug to select this build. A Details panel appears with more information specific to this build. In this panel, click Artifacts to see a list of all the artifacts attached to this build.

5. In the Artifacts panel, download the artifacts for Cuttlefish.
Click the aosp_cf_x86_64_phone-img-xxxxxx.zip artifact for x86_64 or the aosp_cf_arm64_only_phone-xxxxxx.zip artifact for ARM64, which contains the device images. In the filename, "xxxxxx" is the build ID for this device.

6. Scroll down in the panel and download cvd-host_package.tar.gz. Always download the host package from the same build as your images.

7. On your local system, create a container folder and extract the packages:

  x86_64 architecture:

    mkdir cf
    cd cf
    tar -xvf /path/to/cvd-host_package.tar.gz
    unzip /path/to/aosp_cf_x86_64_phone-img-xxxxxx.zip

  ARM64 architecture:

    mkdir cf
    cd cf
    tar -xvf /path/to/cvd-host_package.tar.gz
    unzip /path/to/aosp_cf_arm64_only_phone-img-xxxxxx.zip

8. Launch Cuttlefish:
  HOME=\$PWD ./bin/launch_cvd --daemon

EOT
)"

if [[ -d "/home/$USER/repos/android-cuttlefish" ]]; then
  echo "Android Cuttlefish seems to be already installed in /home/$USER/repos/android-cuttlefish"
  echo "If you just rebooted, you may wish to follow the instructions below to download and set up the necessary device images."
  echo "If you want to reinstall Android Cuttlefish, please run this script with the -r or --reinstall option."
  echo "$FURTHER_STEPS_MESSAGE"
fi

if [[ "$1" == "-r" || "$1" == "--reinstall" ]]; then
  clear
  echo "Reinstalling Android Cuttlefish..."
  if [[ -d "/home/$USER/repos/android-cuttlefish" ]]; then
    echo "Removing existing Android Cuttlefish installation..."
    sudo rm -rf /home/$USER/repos/android-cuttlefish
  fi
else
  read -n 1 -s -r -p $'Press any key to exit\n'
  exit 0
fi

EXIT_CODE=0
read -p $'This script will make changes to the system to install \033[1;32mAndroid Cuttlefish\033[0m. Do you want to continue? (\033[1;32my\033[0m/\033[1;31mn\033[0m): ' -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ && -n $REPLY ]]; then
  echo "Android Cuttlefish installation skipped. You can run this script again later to install it."
  exit 0
fi

# Check if the CPU supports hardware virtualization (VT-x for Intel or AMD-V for AMD)
if [[ "$(grep -c -w "vmx\|svm" /proc/cpuinfo)" -eq 0 ]]; then
  echo -e "\033[1;31mVirtualisation\033[0m does not seem to be supported."
  read -n 1 -s -r -p $'Try enabling hardware virtualization in BIOS/UEFI settings, install KVM, then try again.\nPress any key to exit\n'
  critical_error "Virtualisation is not supported on this CPU. Please check your BIOS/UEFI settings to enable hardware virtualization (VT-x for Intel or AMD-V for AMD)."
fi

# Check if qemu and kvm are already installed
if command -v qemu-system-x86_64 &> /dev/null && command -v kvm &> /dev/null; then
  echo "QEMU and KVM are already installed"
else
  echo "QEMU and KVM are not installed. Please use the installation script in ../services/install_qemu_kvm.sh to install them before running this script again."
  read -n 1 -s -r -p $'Press any key to exit\n'
  critical_error "QEMU and KVM are not installed. They are required for Android Cuttlefish."
fi

# Install required packages for Android Cuttlefish
echo "Updating apt repositories and installing required packages (devscripts equivs config-package-dev debhelper-compat golang) for Android Cuttlefish..."
sudo apt update > /dev/null
(( EXIT_CODE+=$? ))
sudo apt install devscripts equivs config-package-dev debhelper-compat golang gcc-14 g++-14 -y > /dev/null
(( EXIT_CODE+=$? ))

if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "There was an \033[1;31mERROR\033[0m installing \033[1;31mrequired packages for Android Cuttlefish\033[0m. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to exit\n'
  critical_error "Failed to install required packages for Android Cuttlefish."
fi

echo "Cloning the Android Cuttlefish repository from GitHub..."
git clone https://github.com/google/android-cuttlefish /home/$USER/repos/android-cuttlefish > /dev/null 2>&1
(( EXIT_CODE+=$? ))

if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "There was an \033[1;31mERROR cloning the Android Cuttlefish repository\033[0m. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to exit\n'
  critical_error "Failed to clone the Android Cuttlefish repository."
fi

if [[ ! -f "/usr/lib/x86_64-linux-gnu/libxml2.so.2" ]]; then
  echo "libxml2 is not installed. Installing it now..."
  echo "Installing libxml2-dev..."
  sudo apt install libxml2-dev -y > /dev/null
  (( EXIT_CODE+=$? ))
  if [[ ! -f "/usr/lib/x86_64-linux-gnu/libxml2.so.2" ]]; then
    echo "libxml2.so.2 not found in /usr/lib/x86_64-linux-gnu/. Attempting to create a symbolic link..."
    LIBXML2_PATH="$(find /usr/lib/x86_64-linux-gnu/ -regextype posix-basic -regex '/usr/lib/x86_64-linux-gnu/libxml2\.so\.[0-9]\+\(\.[0-9]\)\+' -print0 | tail -z -n 1)" 2>/dev/null
    sudo ln -sf "$LIBXML2_PATH" /usr/lib/x86_64-linux-gnu/libxml2.so.2
  fi
  (( EXIT_CODE+=$? ))
fi

if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "There was an \033[1;31mERROR\033[0m installing \033[1;31mlibxml2\033[0m. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to exit\n'
  critical_error "Failed to install libxml2."
fi

echo "All dependencies installed successfully."
echo "Building the Android Cuttlefish packages..."
cd /home/$USER/repos/android-cuttlefish
export CC="gcc-14"
export CXX="g++-14"
run_and_log "./tools/buildutils/build_packages.sh"
(( EXIT_CODE+=$? ))

if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "There was an \033[1;31mERROR\033[0m building the Android Cuttlefish packages. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to exit\n'
  critical_error "Failed to build the Android Cuttlefish packages."
fi

run_and_log "sudo dpkg -i ./cuttlefish-base_*_*64.deb || sudo apt-get install -f"
(( EXIT_CODE+=$? ))
run_and_log "sudo dpkg -i ./cuttlefish-user_*_*64.deb || sudo apt-get install -f"
(( EXIT_CODE+=$? ))

if [[ $EXIT_CODE -ne 0 ]]; then
  echo -e "There was an \033[1;31mERROR\033[0m installing the Android Cuttlefish packages. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to exit\n'
  critical_error "Failed to install the Android Cuttlefish packages."
fi

run_and_log "sudo usermod -aG kvm,cvdnetwork,render $USER"
(( EXIT_CODE+=$? ))
if [[ $EXIT_CODE -eq 0 ]]; then
  echo "User $USER added to kvm, cvdnetwork, and render groups. You may need to log out and log back in for the changes to take effect."
else
  echo -e "There was an \033[1;31mERROR\033[0m adding user $USER to kvm, cvdnetwork, and render groups. Please check the output above for details."
  read -n 1 -s -r -p $'Press any key to exit\n'
  critical_error "Failed to add user $USER to kvm, cvdnetwork, and render groups."
fi

echo "$FURTHER_STEPS_MESSAGE"

read -n 1 -s -r -p $'Press any key to continue\n'

echo "A reboot is recommended to ensure all changes take effect."
echo "Run 'sudo reboot' to reboot now, or run this script again after rebooting to continue with the installation of the device images and launching Cuttlefish."

exit 0
