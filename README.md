# WIP: Knative Appliance

[![Photon OS 3.0](https://img.shields.io/badge/Photon%20OS-3.0-orange)](https://vmware.github.io/photon/)

[![Twitter Follow](https://img.shields.io/twitter/follow/vmw_rguske?style=social)](https://twitter.com/vmw_rguske)

- [WIP: Knative Appliance](#wip-knative-appliance)
  - [Credits](#credits)
  - [Overview](#overview)
  - [Build requirements](#build-requirements)
  - [Built the Knative-Appliance](#built-the-knative-appliance)
    - [Debugging](#debugging)
    - [Output directoy](#output-directoy)
  - [License](#license)

## Credits

All credits goes out to [Michael Gasch](https://twitter.com/embano1) and [William Lam](https://twitter.com/lamw) who are the maintainer of the awesome VMware Open Source project [VMware Event Broker Appliance](https://www.vmweventbroker.io). They developed this great way to build an VMware Photon OS based appliance in an automated fashion from scratch. I reused the code and stripped it down to the necessary bits and extended it for my needs.

[![Twitter Follow](https://img.shields.io/twitter/follow/lamw?style=social)](https://twitter.com/lamw)
[![Twitter
Follow](https://img.shields.io/twitter/follow/embano1?style=social)](https://twitter.com/embano1)

## Overview

This repository contains the necessary code to build the Knative-Appliance. The Knative-Appliance can be easily deployed on VMware's Desktop Hypervisor solutions Fusion (Mac/Linux) and Workstaion (Windows) as well as on vSphere. It will provide you a ready-to-go Knative `Serving` and `Eventing` environment.

## Build requirements

**CLI Tools:**

- [VMware ovftool](https://www.vmware.com/support/developer/ovf/)
- [Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)
- [jq](https://github.com/stedolan/jq/wiki/Installation)
- [PowerShell](https://github.com/PowerShell/PowerShell) - more optional

**Network:**

- DHCP enabled
- SSH enabled
- No network restrictions between the build system (were `packer` is running on) and the VMware ESXi host.
- Packer will create an http server serving `http_directory`
  - Random port used within the range of 8000 and 9000

**ESXi Version**

- ESXi 6.7 or greater
- ! All my tests failed with latest vSphere ESXi 7.0U2a !

## Built the Knative-Appliance

1. Clone the repository
`git clone https://github.com/rguske/knative-appliance.git`

2. Change directoy
`cd knative-appliance`
3. Adjust the `photon-builder.json` file with the appropriate ESXi (Build host) data (IP, user, password, datastore, network)
4. If you like to change the versions for e.g. Kubernetes or Knative, just modify those via the `bom.json`.
5. Run the `build.sh` script

### Debugging

By putting `PACKER_LOG=1` in front of the `packer build` command in the `build.sh` script, it gives you a very detailed output during the build. Example: `PACKER_LOG=1 packer build -var "APPLIANCE_VERSION=${APPLIANCE_VERSION_FROM_BOM}" [...]` ).

### Output directoy

The finished build `ova` file will be exported to the `output-vmware-iso` directory.

## License

WIP
