# Setup

## Before Starting

You need to install Just on your host machine.  
Just is a command runner similar to Make, designed to save and run project-specific commands. It helps streamline development workflows by storing recipes in a justfile.  

You can install Just using one of the following methods:

### On Debian/Ubuntu

```sh
sudo apt update
sudo apt install just
```

### On Fedora

```sh
sudo dnf install just
```

### Using Cargo (cross-platform)

If you have Rust installed:

```sh
cargo install just
```

## Getting started

I combined tools installation and the OpenTofu provisioning into a single recipe:  

```sh
just deploy
```

After a couple of minutes, your cluster is setup and ready to be use.  

## Need a Reminder?

To see a list of all available commands and what they do, run:

```sh
just help
```

This will show a helpful summary of all commands included.  

