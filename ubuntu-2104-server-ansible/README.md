# ubuntu-2104-server-ansible

A Packer template which builds an Ubuntu 21.04 live server image in Vagrant box format.

| Name                       | Operating System         | Architecture | Description                                             |
| -------------------------- | ------------------------ | ------------ | ------------------------------------------------------- |
| ubuntu-2104-server-ansible | Ubuntu 21.04 Live Server | AMD64 | Ubuntu 21.04 Live Server for use testing Ansible roles. |

The confguration is known to be compatible with Packer 1.7.3.

# Design goals

Provide an extremely vanilla Ubuntu installation, with just enough configuration to provide SSH access, so that Ansible roles can be provisioned on the guest and tested.

# SSH Access

SSH Access is provided, via a single o/s username and password, which is configured at image build time.

# User Details

The defaults are:

| Username | Password |
| -------- | -------- |
| ansible  | ansible  |

Using the defaults obviously leads to an extremely insecure image with known credentials, so can be overridden as described in the configuration section.

# How to build the image:

```bash
cd ubuntu-2104-server-ansible
packer build -on-error=ask \
  ubuntu-21.04-server-ansible.pkr.hcl
```

# How to configure the image:

Ubuntu 21.04 uses Subiquity to configure the installation. Packer provides the following files to Subiquity to configure the installation:

| File | Description | HTTP endpoint presented to Subiquity |
| ---------------------------------------- | ---------------------------------------------------------- | ---------- |
| [subiquity/http/user-data.yaml.pkrtpl.hcl](subiquity/http/user-data.yaml.pkrtpl.hcl) | HCL template which contains the installation configuration | /user-data |
| [subiquity/http/meta-data](subiquity/http/meta-data) | Empty file to satisfy Subiqity | /meta-data |

To tweak the configuration edit settings in the `user-data.yaml.pkrtpl.hcl` file.

## Username and Password

The `os_username` and `os_password` variables can be used to override the default username and password respectively e.g.

```bash
cd ubuntu-2104-server-ansible
packer build -on-error=ask \
  -var os_username=little-bobby-tables \
  -var os_password=foobar \
  ubuntu-21.04-server-ansible.pkr.hcl
```

# Output

Once generated, the Vagrant box will be output to `ubuntu-2104-server-ansible/packer_ubuntu-21-04-live-server_virtualbox.box` in the repository.

