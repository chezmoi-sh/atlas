# Configuration document about the Raspberry Pi OS installation

> \[!NOTE]
> This document contains all information about how to install and configure the
> Raspberry Pi OS for this project.\
> Instead of trying to automate everything for something that will be done only
> once *(until something breaks)*, I prefer to do everything by hand and document
> each step here.

## 🏗️ Raspberry Pi 5 components

This nex·pi Raspberry Pi 5 will be composed of the following components:

* [**Raspberry Pi 5 *(8GB RAM)*:**](https://www.raspberrypi.com/products/raspberry-pi-5/) as the main board. <!-- trunk-ignore(markdown-link-check/403): URL behind Cloudflare -->
* [**PoE Hat from Waveshare:**](https://www.waveshare.com/poe-hat-f.htm) to power the Raspberry Pi.
* [**NVMe Base for Raspberry Pi 5:**](https://shop.pimoroni.com/products/nvme-base?variant=41219587178579) to
  add an NVMe SSD to the Raspberry Pi.
* [**ADATA LEGEND 700 PCIe NVMe *(500 Go)***](https://www.adata.com/us/consumer/category/ssds/solid-state-drives-legend-700/)
  as the main storage.
* [**SanDisk High Endurance microSDHC *(64 Go)***](https://www.westerndigital.com/en-ap/products/memory-cards/sandisk-high-endurance-uhs-i-microsd?sku=SDSQQNR-064G-GHEIA)
  as the OS storage.

## ⚙️ Raspberry Pi OS installation

> \[!NOTE]
> **Why Raspberry Pi OS?**\
> For this project, I chose to use the Raspberry Pi OS because it is the most
> compatible with the Raspberry Pi hardware. Made by the Raspberry Pi Foundation
> and based on Debian, I didn't found any reason to use another OS.\
> It is lightweight, easy to use, and has a lot of support from the community
> and had some features that I want to use in this project like the `read-only`
> overlay.

<!-- trunk-ignore-begin(markdown-link-check/403): URL behind Cloudflare -->

> \[!WARNING]
> Working on Windows, I will use the official Raspberry Pi Imager to flash the
> microSD card. If you are on another OS, you can follow the instructions on
> the [official Raspberry Pi website](https://www.raspberrypi.com/software/).

<!-- trunk-ignore-end(markdown-link-check/403) -->

### *Step 1:* Install the Raspberry Pi OS on the microSD card

* Download the [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
* Insert the microSD card into the computer.
* Open the Raspberry Pi Imager and select the Raspberry Pi OS Lite 64-bit
  *(Raspberry Pi OS (other))*.
* Select the microSD card and click on `Next`.
  * Configure using these preferences:
    * General settings:
      * Hostname: `nexpi`
      * User: `pi`
      * Password: 32 characters long password generated randomly
      * No wireless network
      * Timezone: `Europe/Paris`
      * Keyboard: `US`
    * Services settings:
      * SSH: `Enabled`
      * SSH key: the one used for my devices
* Start the installation and wait for it to finish.

### *Step 2:* Bootstrap and configure the Raspberry Pi OS

* Insert the microSD card into the Raspberry Pi.

* Connect the Raspberry Pi to the network using an Ethernet cable.

* Wait for the Raspberry Pi to boot and connect to it using SSH.

* Update the system and reboot to apply the changes (like firmware updates):
  ```bash
  sudo apt update && sudo apt upgrade --yes
  sudo reboot
  ```

* Avoid running `rpi-eeprom-update` automatically to avoid any potential
  disruption after a reboot:
  ```bash
  sudo systemctl mask rpi-eeprom-update
  ```

* Configure the Raspberry Pi to use the NVMe SSD Gen 3[^1]:
  ```bash
  cat <<EOF | sudo tee --append /boot/firmware/config.txt
  # Enable NVMe SSD Gen 3
  dtparam=pciex1_gen=3
  EOF
  sudo reboot
  ```

* Install required packages to manage the NVMe SSD Gen 3 with `btrfs`:
  ```bash
  sudo apt install --yes initramfs-tools btrfs-progs btrbk
  ```

> \[!CAUTION]
> **THE NEXT STEPS WILL ERASE ALL DATA ON THE NVMe SSD.**\
> **BE WARNED !**

* **ONLY IF THE NVMe HAS NEVER BEEN USED BEFORE**

  * Create a new partition on the
    NVMe SSD and format it:
    ```bash
    sudo parted /dev/nvme0n1 --align=opt --script \
      mklabel gpt \
      mkpart primary  0% 100%
    sudo mkfs.btrfs /dev/nvme0n1p1
    ```
  * Create subvolume for `/var/lib/{@k3s,@data}` and configure quotas:

    ```bash
    # mount the BTRFS partition
    sudo mount -t btrfs /dev/nvme0n1p1 /mnt

    # create subvolumes for k3s and persistent data
    sudo btrfs subvolume create /mnt/@k3s
    sudo btrfs subvolume create /mnt/@k3s/etc
    sudo btrfs subvolume create /mnt/@k3s/var
    sudo btrfs subvolume create /mnt/@data

    # enable quotas and configure them
    sudo btrfs quota enable /mnt
    sudo btrfs qgroup create 1/0 /mnt
    sudo btrfs qgroup assign 0/257 1/0 /mnt
    sudo btrfs qgroup assign 0/258 1/0 /mnt
    sudo btrfs qgroup limit 16K /mnt/@k3s
    sudo btrfs qgroup limit -e 50G 1/0 /mnt

    # unmount the BTRFS partition
    sudo umount /mnt
    ```

    To see if everything is correctly configured, you can run the following
    command:

    ```bash
    sudo btrfs subvolume list /mnt
    sudo btrfs qgroup show -pcre /mnt
    ```

> \[!NOTE]
> I limit to 50G the size of the k3s subvolumes to avoid it to grow too much
> and fill the NVMe SSD. Also, as `@k3s` and `@data` may share some bytes[^2],
> 50G should be enough.

* Mount the BTRFS partitions at boot:
  ```bash
  export UUID=$(sudo btrfs filesystem show /dev/nvme0n1p1 | awk 'NR==1 {print $4; exit}')

  envsubst <<EOF | sudo tee /etc/systemd/system/etc-rancher.mount
  [Unit]
  Description=k3s configuration directory
  Before=k3s.service

  [Mount]
  What=/dev/disk/by-uuid/${UUID}
  Where=/etc/rancher
  Type=btrfs
  Options=subvol=@k3s/etc,defaults

  [Install]
  WantedBy=multi-user.target
  EOF

  envsubst <<EOF | sudo tee /etc/systemd/system/var-lib-rancher-k3s.mount
  [Unit]
  Description=k3s data directory
  Before=k3s.service

  [Mount]
  What=/dev/disk/by-uuid/${UUID}
  Where=/var/lib/rancher/k3s
  Type=btrfs
  Options=subvol=@k3s/var,defaults

  [Install]
  WantedBy=multi-user.target
  EOF

  envsubst <<EOF | sudo tee /etc/systemd/system/srv-persistent.mount
  [Unit]
  Description=Persistent data configuration volume
  Before=k3s.service

  [Mount]
  What=/dev/disk/by-uuid/${UUID}
  Where=/srv/persistent
  Type=btrfs
  Options=subvol=@data,defaults,nodatacow

  [Install]
  WantedBy=multi-user.target
  EOF

  sudo systemctl daemon-reload
  sudo systemctl enable --now etc-rancher.mount var-lib-rancher-k3s.mount srv-persistent.mount
  ```

* Configure the firewall to only allow necessary ports:
  ```bash
  sudo apt install --yes ufw

  cat <<EOF | sudo tee /etc/ufw/applications.d/kubernetes
  [Kubernetes API]
  title=Kubernetes API Server
  description=Kubernetes API Server
  ports=6443/tcp
  EOF

  cat <<EOF | sudo tee /etc/ufw/applications.d/full-dns
  [DNS over HTTPS]
  title=DNS over HTTPS (DoH)
  description=DNS over HTTPS (DoH)
  ports=443/tcp

  [DNS over TLS]
  title=DNS over TLS (DoT)
  description=DNS over TLS (DoT)
  ports=853/tcp

  [DNS over QUIC]
  title=DNS over QUIC (DoQ)
  description=DNS over QUIC (DoQ)
  ports=853/udp
  EOF

  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow SSH
  sudo ufw allow DNS
  sudo ufw allow 'DNS over HTTPS'
  sudo ufw allow 'DNS over TLS'
  sudo ufw allow 'DNS over QUIC'
  sudo ufw allow 'Kubernetes API'
  sudo ufw allow LDAPS
  sudo ufw allow 'WWW Full'

  sudo ufw status
  ```

* Enable the firewall
  ```bash
  sudo ufw enable
  ```

### *Step 3:* Install and configure `k3s`

* Install `k3s` without `traefik` and without starting it:
  ```bash
  sudo grep -q "cgroup_memory=1 cgroup_enable=memory" /boot/firmware/cmdline.txt \
  || (echo -n " cgroup_memory=1 cgroup_enable=memory" | sudo tee -a /boot/firmware/cmdline.txt > /dev/null)
  curl -sfL https://get.k3s.io | sudo INSTALL_K3S_SKIP_START=true sh -s - --disable=traefik --tls-san kubernetes.nr.chezmoi.sh
  ```

* Configure `k3s` to use ZOT registry as pull-proxy:

> \[!NOTE]
> Not yet implemented.

### *Step 4:* Enable OverlayFS on the Raspberry Pi and reboot to apply the changes

> \[!IMPORTANT]
> Do this step after anything else because it will switch on the overlayfs
> on which nothing can be changed after.

```bash
sudo raspi-config nonint do_overlayfs 0
sudo reboot
```

### *Step 5:* Start `k3s` and copy the kubeconfig locally

> \[!TIP]
> The `k3s` service will start automatically after the last reboot, so nothing
> needs to be done here.

* Copy the `kubeconfig` locally to be able to use `kubectl`:
  ```bash
  export K3S_IP=<hostname_or_ip>
  export KUBECONFIG=$PWD/kubeconfig.yaml
  ssh pi@${K3S_IP} -- sudo cat /etc/rancher/k3s/k3s.yaml | sed "s|server: https://127.0.0.1:6443|server: https://${K3S_IP}:6443|" > $KUBECONFIG
  kubectl get nodes
  ```

[^1]: All information about the NVMe SSD Gen 3 configuration can be found on the
    [Pimoroni website](https://learn.pimoroni.com/article/getting-started-with-nvme-base)
    and the [NVMe base product page](https://shop.pimoroni.com/products/nvme-base?variant=41219587178579).

[^2]: The `@k3s` and `@data` subvolumes may share some bytes because ZOT registry,
    which acts as a pull-proxy for all `atlas` projects, including this one.