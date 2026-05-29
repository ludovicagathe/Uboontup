#!/bin/bash
# This script installs QEMU and KVM on Ubuntu. It is based on the official QEMU and KVM installation instructions for Ubuntu, which can be found here: https://help.ubuntu.com/community/KVM/Installation
# Ask user to confirm before proceeding, as this script will make changes to the system and may require a restart. The user can choose to skip the installation if they do not want to proceed.

read -p $'This script will make changes to the system to install \033[1;32mQEMU/KVM\033[0m. Do you want to continue? (\033[1;32my\033[0m/\033[1;31mn\033[0m): ' -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ && -n $REPLY ]]; then
  echo "QEMU/KVM installation skipped. You can run this script again later to install it."
  exit 0
fi

# Check if qemu and kvm are already installed
if command -v qemu-system-x86_64 &> /dev/null && command -v kvm &> /dev/null; then
  echo "QEMU and KVM are already installed. Skipping installation."
  exit 0
fi

sudo apt update
sudo apt install qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients bridge-utils virt-manager

sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

echo "To check if KVM is working, run 'sudo kvm-ok'"
echo "To start the libvirt daemon, run 'sudo systemctl start libvirtd'"
echo "To check if the libvirt daemon is running, run 'sudo systemctl status libvirtd'"
echo "To enable the libvirt daemon to start on boot, run 'sudo systemctl enable libvirtd'"
echo "To manage virtual machines, you can use 'virt-manager' or 'virsh' commands."

read -n 1 -s -r -p $'Press any key to continue\n'