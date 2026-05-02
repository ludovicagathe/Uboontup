# 🚀 Uboontup

> **Fast, automated, and hassle-free post-installation setup for Ubuntu Server & Desktop.**

Uboontup is a collection of Bash scripts, snippets and customizations designed to take a freshly installed Ubuntu machine and turn it into a fully configured, production-ready environment in minutes. 

Currently focused on spinning up a **monolithic server architecture**, this project handles the tedious parts of server prep so you can get straight to building, hosting, and deploying.

## ⚠️ Warning
This is a work in progress which is still basic in terms of features and at a very early stage of development. It is not yet intended for distribution or use in production environments.

## ✨ Features

* **📦 Essential Packages:** Automatically installs must-have utilities (`build-essential`, `software-properties-common`, `curl`, etc).
* **🔗 Repository Management:** Securely adds, configures, and updates necessary application repositories, from official sources.
* **✅ Requirement Verification:** Runs pre-flight checks to ensure your system meets the necessary hardware and software requirements before installation.
* **🏗️ Monolithic Stack Setup:** Provisions a complete, ready-to-use stack right out of the box.
* **🎯 Ubuntu-Native:** Built, tested, and optimized specifically for Ubuntu environments.

## 🥞 The Stack (Current Phase)

*As Uboontup evolves, the ultimate setup may change. However, the initial releases target a robust monolithic architecture including:*

* **Runtime:** Node.js, Python
* **Webserver:** (e.g., Nginx or Apache)
* **Database:** (e.g., PostgreSQL, MySQL, or MongoDB)
* **In-Memory Cache:** (e.g., Redis or Valkey)

---

## 🚀 Getting Started

### Prerequisites
* A fresh installation of **Ubuntu Server** or **Ubuntu Desktop**.
* A user account with `sudo` privileges.

### Quick Start

```bash
# Clone the repository
git clone https://github.com/ludovicagathe/Uboontup.git uboontup

# Navigate to the directory
cd uboontup

# Clone and initialise feature repositories
git submodule update --init --recursive

# Make the setup script executable
chmod +x setup

# Run the installer
sudo ./setup
```
---

### Test features
A test suite is provided that will simulate the script and will not make any permanent changes to the system. These tests will run in a subfolder, `./uboontup/tests/test_home`

```bash
# Clone the repository
git clone https://github.com/ludovicagathe/Uboontup.git uboontup

# Navigate to the directory
cd uboontup/tests

# Clone and initialise feature repositories
git submodule update --init --recursive

# Make the setup script executable
chmod +x test.sh

# Run the installer
sudo ./test.sh
```
---
## 🗺️ Roadmap

Uboontup is a living project. While the current iteration focuses on establishing a rock-solid monolithic server setup, future updates may introduce modularity—allowing you to pick and choose specific components, scale out, or tailor the environment for different developer workflows.

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the issues page if you want to help improve the scripts.

## 📫 Contact

Ludovic Agathe 📧 ludovic.agathe@gmail.com

🌐 [GitHub](https://github.com/ludovicagathe) - [LinkedIn](https://mu.linkedin.com/in/ludovic-agathe)

Built with 💻 and ☕ for the Ubuntu community.