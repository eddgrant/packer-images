#cloud-config
autoinstall:
  version: 1
  early-commands:
  # If we install the SSH server using the subiquity `ssh` configuration then port 22 gets opened up to packer _before_
  # the requisite configuration has been done to allow Packer to SSH on to the guest O/S. This results in a failed build
  # as Packer exceeds its SSH permitted number of SSH handshake attempts.
  #
  # To ensure this doesn't happen we stop the SSH service until right at the end when we re-enable it
  # using a late-command.
    #- sudo iptables -I INPUT -p tcp --dport 22 -j DROP
    - sudo systemctl stop ssh
  locale: en_GB
  refresh-installer:
    update: yes
  keyboard:
    layout: gb
  #network:
  #  network:
  #    version: 2
  #    ethernets:
  #      ens33:
  #        dhcp4: true
  storage:
    layout:
      name: lvm
  ssh:
    allow-pw: true
    install-server: yes
  user-data:
    disable_root: false
    users:
      -
        name: ${os_username}
        passwd: ${hashed_os_password}
        groups: [ adm, cdrom, dip, plugdev, lxd, sudo ]
        lock-passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
    #  write_files:
    #    -   path: /etc/ssh/sshd_config
    #        content: |
    #          Port 22
    #          Protocol 2
    #          HostKey /etc/ssh/ssh_host_rsa_key
    #          HostKey /etc/ssh/ssh_host_dsa_key
    #          HostKey /etc/ssh/ssh_host_ecdsa_key
    #          HostKey /etc/ssh/ssh_host_ed25519_key
    #          UsePrivilegeSeparation yes
    #          KeyRegenerationInterval 3600
    #          ServerKeyBits 1024
    #          SyslogFacility AUTH
    #          LogLevel INFO
    #          LoginGraceTime 120
    #          PermitRootLogin yes
    #          StrictModes no
    #          RSAAuthentication yes
    #          PubkeyAuthentication no
    #          IgnoreRhosts yes
    #          RhostsRSAAuthentication no
    #          HostbasedAuthentication no
    #          PermitEmptyPasswords no
    #          ChallengeResponseAuthentication no
    #          X11Forwarding yes
    #          X11DisplayOffset 10
    #          PrintMotd no
    #          PrintLastLog yes
    #          TCPKeepAlive yes
    #          AcceptEnv LANG LC_*
    #          Subsystem sftp /usr/lib/openssh/sftp-server
    #          UsePAM yes
    #          AllowUsers ubuntu
  packages:
    - qemu-guest-agent
  late-commands:
    #- sudo iptables -D INPUT -p tcp --dport 22 -j DROP
    - sudo systemctl start ssh
