# docker-swarm-setup

<!-- TOC -->

- [Overview](#overview)
- [Prerequisites](#prerequisites)
  - [Machines](#machines)
  - [Certificate](#certificate)
  - [SSH Key Pair](#ssh-key-pair)
  - [Dockerfile](#dockerfile)
  - [Using an Insecure Registry](#using-an-insecure-registry)
- [Installation](#installation)
- [Uninstallation](#uninstallation)
- [Configuration Guide](#configuration-guide)

<!-- /TOC -->


## Overview

These scripts are intended to enable the creation of an example Docker Swarm
microservices environment for use with API Connect.

## Prerequisites
### Machines
You will need six (6) virtual/physical machines, running operating systems that
are compatible with Docker. Each VM must have the following:
- An account with passwordless sudo access. It is **strongly** recommended
that you setup an account that is not root for this purpose! The setup script
assumes that the _same_ username will be used for _each machine_!
Examples:
  * [Ubuntu](http://askubuntu.com/questions/192050/how-to-run-sudo-command-with-no-password)

- A fully-qualified domain name. If you cannot use domain names or do not wish
to set this up, you can make use of an [insecure registry](#prereq-registry),
which will require additional steps.

### Certificate
The Docker Registry will require the use of a certificate between machines.
This script automatically adds your specified .crt file to the members of the
swarm to establish trust between them.

We will assume the certificate is self-signed, but use of a CA-signed 
certificate is always recommended for real-world deployments.

>**WARNING**: USE OF SELF-SIGNED CERTIFICATES ALWAYS CARRY SOME INHERENT RISK.
DO NOT DO THIS FOR ANY REAL-WORLD SYSTEM OR DEPLOYMENT!

If your systems do not already have domain names (either provided by
an internal DNS server or a real-world external DNS server) then you will need
to add them via your `/etc/hosts` file. The certificate must be made with a
Common Name that matches the given domain name of your Docker Registry.

  >If your Docker Registry is at 12.23.34.45, and your certificate's
  Common Name is `www.example.com`, then you'll need to add an entry to your
  `/etc/hosts` file:
  ```
  # Example /etc/hosts file
  127.0.0.1       localhost
  ::1             localhost
  # New entry here
  12.23.34.45     www.example.com
  ```

Next, generate the new certificate:
```
openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=US/ST=New York/L=New York City/O=IBM Corp/CN=www.example.com" \
    -keyout www.example.com.key \
    -out www.example.com.cert
```

Finally, add the certificate to your operating system's trust store. See your
system's manual, or online help for details.

### SSH Key Pair
You'll also want an SSH key pair for use on your VMs, as this will allow Docker
Machine to remote in and perform the necessary operations. This script assumes
that you'll use one key pair across the whole system.
>**WARNING**: This is also a security risk, as it means that an attacker that
has the decrypted private key of one machine may now freely access all of them!
**Always use unique keys for each machine in a real-world environment.**

Add the public key to the `authorized_keys` file of the privileged user account:
```
# This may be different based on your OpenSSH configuration.
cat yourkey.pub >> ~/.ssh/authorized_keys
```

### Dockerfile
You will need to create a Dockerfile that can be built into an image. This image
will automatically be pushed to the Docker Registry as a part of setup.

This bundle comes with a pre-packaged application and Dockerfile that you may
modify or replace as you please. If you only wish to see the proof-of-concept in
action, the pre-packaged application and Dockerfile should suffice.

### Using an Insecure Registry
If you are not using a domain name for your machines (more specifically, for
your registry machine), then you will need to use an insecure registry.

- On the machine running the scripts, add the IP address of the registry machine
to your insecure registry list in Docker. (For help, see [this doc](https://docs.docker.com/registry/insecure/))
- Enable the `useInsecureRegistry` flag in your [configuration file](#configuration-guide).

**NOTE**: Enabling this flag will cause a prompt to appear during setup. Using
an insecure registry is extremely dangerous, and this prompt exists to ensure
that you understand the risks associated with deploying an environment that
relies on them for operation.

## Installation

- Make a copy of the config file template in the root of this directory and
place it anywhere you wish.
- Edit the configuration file to add in:
  * VM addresses
  * Key and certificate locations
  * Dockerfile location
  * App bundle location
- Export the path of this configuration file using the `SWARM_SETUP_CFG`
environment variable.
- Modify the script to be executable (`chmod +x setup.sh`) and execute

```
# Example
export SWARM_SETUP_CFG=/home/foo/myconfig
chmod +x setup.sh
sh setup.sh
```

## Uninstallation

Using the same configuration file, run `sh teardown.sh`. This will disable the
`microservice` service and disassemble the Docker Swarm.
>Note: Host VMs will still have Docker installed.

## Configuration Guide

The configuration file contains all of the variables used in the setup process.

Note: Even though some of the variable names contain FQDN (Fully-Qualified
Domain Name), they might contain IP addresses if you are using an insecure
registry. If possible, the use of VMs with FQDNs is always preferred to the use
of IP addresses.

| Variable Name  | Purpose        | Optional |
| :------------- | :------------- | :------- |
| registryName | The name to give to the Docker Registry. | no |
| registryFQDN | The fully-qualified domain name (FQDN) OR IP address of the Docker Registry. | no |
| useInsecureRegistry | Whether or not to use an insecure registry. Omit this parameter to use the default behaviour. | yes |
| manager{#}Name | The name of manager{#} (manager1, manager2, etc...) | no |
| manager{#}FQDN | The FQDN/IP address of manager{#} (manager1, manager2, etc...) | no |
| worker{#}Name | The name of worker{#} (worker1, worker2, etc...) | no |
| worker{#}FQDN | The FQDN/IP address of worker{#} (worker1, worker2, etc...) | no |
| user | The SSH user account with passwordless sudo access. | no |
| keypair | The SSH public/private keypair to gain access to the target VMs. Both keys should share the same name (eg. `foo` and `foo.pub`) | no |
| cert | The certificate pair used by the Docker Registry and the Docker Swarm members. Both the cert and the key should share the same name (eg. `domain.crt` and `domain.key`)| no |
| dockerImageName | The name to give to the Docker image on build, and the name it will have when pushed to the registry. | no |
| dockerFileDir | The directory that contains your Dockerfile. Depending on how you build your Dockerfile, this directory may contain other files as well. | no |
