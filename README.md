PXEチャレンジ
===
ぼくだってOSのブートについて完全に理解してPXEブートでイケイケになりたい

## 環境
- Network: 192.168.1.0/24
- DHCP Server: 192.168.1.1
  - ブロードバンドルーター
- DHCP Range: 192.168.1.2-192.168.1.49
  - ブロードバンドルーターで設定
- proxy-DHCP Server: 192.168.1.50
  - dnsmasqで実装
- TFTP Server: 192.168.1.50
  - dnsmasqで実装


## 作業ログ
```bash
# ディレクトリ堀り
captain@ubuntu:~/develop$ mkdir -p tftpboot/pxelinux.cfg
captain@ubuntu:~/develop$ mkdir -p pxeboot/autoinstall

# ISOをDLして格納
captain@ubuntu:~/develop$ wget https://releases.ubuntu.com/20.04/ubuntu-20.04.3-live-server-amd64.iso 
captain@ubuntu:~/develop$ mv ubuntu-20.04.3-live-server-amd64.iso pxeboot/

# ISOからカーネル(?)を引っ張り出してTFTPで配布できるように設定
captain@ubuntu:~/develop$ sudo mount -t iso9660 -o loop pxeboot/ubuntu-20.04.3-live-server-amd64.iso /mnt
captain@ubuntu:~/develop$ sudo cp /mnt/casper/{vmlinuz,initrd} tftpboot/
captain@ubuntu:~/develop$ sudo umount /mnt

# 必要そうなモジュールたちをDLしてTFTPで配布できるように設定
captain@ubuntu:~/develop$ wget http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/current/legacy-images/netboot/ubuntu-installer/amd64/pxelinux.0
captain@ubuntu:~/develop$ wget http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/current/legacy-images/netboot/ubuntu-installer/amd64/boot-screens/ldlinux.c32
captain@ubuntu:~/develop$ wget http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/current/legacy-images/netboot/ubuntu-installer/amd64/boot-screens/libcom32.c32
captain@ubuntu:~/develop$ wget http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/current/legacy-images/netboot/ubuntu-installer/amd64/boot-screens/libutil.c32
captain@ubuntu:~/develop$ mv ./{pxelinux.0,ldlinux.c32,libcom32.c32,libutil.c32} tftpboot/

# コンテナ作成
captain@ubuntu:~/develop$ make dnsmasq

# dnsmasqとnginxを起動
captain@ubuntu:~/develop$ docker-compose up
dhcp_1   | dnsmasq: started, version 2.80 DNS disabled
dhcp_1   | dnsmasq: compile time options: IPv6 GNU-getopt DBus i18n IDN DHCP DHCPv6 no-Lua TFTP conntrack ipset auth nettlehash DNSSEC loop-detect inotify dumpfile
dhcp_1   | dnsmasq-dhcp: DHCP, proxy on subnet 192.168.1.0
dhcp_1   | dnsmasq-tftp: TFTP root is /tftpboot 
...

# Clientノードスタート、Start PXE...
dhcp_1   | dnsmasq-dhcp: 110268312 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 110268312 vendor class: PXEClient:Arch:00007:UNDI:003016
dhcp_1   | dnsmasq-dhcp: 110268312 PXE(eno1) f4:4d:... proxy
dhcp_1   | dnsmasq-dhcp: 110268312 tags: eno1
dhcp_1   | dnsmasq-dhcp: 110268312 bootfile name: pxelinux.0
dhcp_1   | dnsmasq-dhcp: 110268312 next server: 192.168.1.50
dhcp_1   | dnsmasq-dhcp: 110268312 broadcast response
dhcp_1   | dnsmasq-dhcp: 110268312 sent size:  1 option: 53 message-type  2
dhcp_1   | dnsmasq-dhcp: 110268312 sent size:  4 option: 54 server-identifier  192.168.1.50
dhcp_1   | dnsmasq-dhcp: 110268312 sent size:  9 option: 60 vendor-class  50:58:45:...
dhcp_1   | dnsmasq-dhcp: 110268312 sent size: 17 option: 97 client-machine-id  00:58:b4:18:...
dhcp_1   | dnsmasq-dhcp: 110268312 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 110268312 vendor class: PXEClient:Arch:00007:UNDI:003016
dhcp_1   | dnsmasq-dhcp: 12207496 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 12207496 vendor class: PXEClient:Arch:00007:UNDI:003016
dhcp_1   | dnsmasq-dhcp: 12207496 PXE(eno1) f4:4d:... proxy
dhcp_1   | dnsmasq-dhcp: 12207496 tags: eno1
dhcp_1   | dnsmasq-dhcp: 12207496 bootfile name: pxelinux.0
dhcp_1   | dnsmasq-dhcp: 12207496 next server: 192.168.1.50
dhcp_1   | dnsmasq-dhcp: 12207496 sent size:  1 option: 53 message-type  5
dhcp_1   | dnsmasq-dhcp: 12207496 sent size:  4 option: 54 server-identifier  192.168.1.50
dhcp_1   | dnsmasq-dhcp: 12207496 sent size:  9 option: 60 vendor-class  50:58:45:...
dhcp_1   | dnsmasq-dhcp: 12207496 sent size: 17 option: 97 client-machine-id  00:58:b4:18:...
dhcp_1   | dnsmasq-dhcp: 12207496 sent size: 10 option: 43 vendor-encap  06:01:08:...
# Client側で"PXE-E21 : Remote boot canceled"のエラーが発生、Boot終了
```
