# Getting started with Uboontup
## What is Uboontup
Uboontup is a set of customisations and scripts made to ease the setting up an Ubuntu machine (preferably a server), up and running to host web apps with common packages, services and administrative tools.
The name is a compression of UBuntu bOOt N seTUP

## Where to go from here
The first step is to clone the repository, preferably in your home (`$HOME`) folder:
```bash
git clone https://github.com/ludovicagathe/uboontup.git uboontup
cd uboontup
```
Then, you launch the `setup` script and follow the instructions when prompted:
`./setup`

`setup` is an executable, but if you get an error on launching, you may try to change the file mode to make it executable:
```bash
chmod +x ./setup
./setup
```

## What Uboontup will do for you
It will install basic packages (see the list in `documentation > 02 - package_list.md`), as well as add some Bash custom aliases and functions (see `documentation > 03 - bash_aliases_and_functions`)