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
- PXEクライアント: NUC6i5SYH (Intel NUC)

## 構成

```bash
captain@ubuntu:~/develop$ tree
.
├── dnsmasq
│   ├── dnsmasq.conf
│   └── Dockerfile
├── docker-compose.yaml
├── Makefile
├── pxeboot
│   ├── autoinstall
│   │   ├── meta-data
│   │   └── user-data
│   └── ubuntu-20.04.3-live-server-amd64.iso
├── README.md
└── tftpboot
    ├── initrd
    ├── ldlinux.c32
    ├── libcom32.c32
    ├── libutil.c32
    ├── pxelinux.0
    ├── pxelinux.cfg
    │   └── default
    └── vmlinuz
```

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
dhcp_1   | dnsmasq: started, version 2.80 DNS disabled
dhcp_1   | dnsmasq: compile time options: IPv6 GNU-getopt DBus i18n IDN DHCP DHCPv6 no-Lua TFTP conntrack ipset auth nettlehash DNSSEC loop-detect inotify dumpfile
dhcp_1   | dnsmasq-dhcp: DHCP, proxy on subnet 192.168.1.0
dhcp_1   | dnsmasq-tftp: TFTP root is /tftpboot 
dhcp_1   | dnsmasq-dhcp: 811623529 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 811623529 vendor class: PXEClient:Arch:00000:UNDI:002001
dhcp_1   | dnsmasq-dhcp: 811623529 PXE(eno1) f4:4d:... proxy
dhcp_1   | dnsmasq-dhcp: 811623529 tags: eno1
dhcp_1   | dnsmasq-dhcp: 811623529 bootfile name: pxelinux.0
dhcp_1   | dnsmasq-dhcp: 811623529 broadcast response
dhcp_1   | dnsmasq-dhcp: 811623529 sent size:  1 option: 53 message-type  2
dhcp_1   | dnsmasq-dhcp: 811623529 sent size:  4 option: 54 server-identifier  192.168.1.50
dhcp_1   | dnsmasq-dhcp: 811623529 sent size:  9 option: 60 vendor-class  50:58:...
dhcp_1   | dnsmasq-dhcp: 811623529 sent size: 17 option: 97 client-machine-id  00:58:...
dhcp_1   | dnsmasq-dhcp: 811623529 sent size: 36 option: 43 vendor-encap  06:01:...
dhcp_1   | dnsmasq-dhcp: 811623529 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 811623529 vendor class: PXEClient:Arch:00000:UNDI:002001
dhcp_1   | dnsmasq-dhcp: 811623529 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 811623529 vendor class: PXEClient:Arch:00000:UNDI:002001
dhcp_1   | dnsmasq-dhcp: 811623529 PXE(eno1) 192.168.1.14 f4:4d:... pxelinux.0
dhcp_1   | dnsmasq-dhcp: 811623529 tags: eno1
dhcp_1   | dnsmasq-dhcp: 811623529 bootfile name: pxelinux.0
dhcp_1   | dnsmasq-dhcp: 811623529 next server: 192.168.1.50
dhcp_1   | dnsmasq-dhcp: 811623529 sent size:  1 option: 53 message-type  5
dhcp_1   | dnsmasq-dhcp: 811623529 sent size:  4 option: 54 server-identifier  192.168.1.50
dhcp_1   | dnsmasq-dhcp: 811623529 sent size:  9 option: 60 vendor-class  50:58:...
dhcp_1   | dnsmasq-dhcp: 811623529 sent size: 17 option: 97 client-machine-id  00:58:...
dhcp_1   | dnsmasq-dhcp: 811623529 sent size:  7 option: 43 vendor-encap  47:04:...
dhcp_1   | dnsmasq-tftp: error 0 TFTP Aborted received from 192.168.1.14
dhcp_1   | dnsmasq-tftp: failed sending /tftpboot/pxelinux.0 to 192.168.1.14
dhcp_1   | dnsmasq-tftp: sent /tftpboot/pxelinux.0 to 192.168.1.14
dhcp_1   | dnsmasq-tftp: sent /tftpboot/ldlinux.c32 to 192.168.1.14
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/58b41815-581e-c62a-d4e2-f44d30606469 not found
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/01-f4-4d-30-60-64-69 not found
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/C0A8010E not found
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/C0A8010 not found
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/C0A801 not found
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/C0A80 not found
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/C0A8 not found
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/C0A not found
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/C0 not found
dhcp_1   | dnsmasq-tftp: file /tftpboot/pxelinux.cfg/C not found
dhcp_1   | dnsmasq-tftp: sent /tftpboot/pxelinux.cfg/default to 192.168.1.14
dhcp_1   | dnsmasq-tftp: sent /tftpboot/vmlinuz to 192.168.1.14
dhcp_1   | dnsmasq-tftp: sent /tftpboot/initrd to 192.168.1.14
dhcp_1   | dnsmasq-dhcp: 1785943612 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 3506991687 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 3506991687 available DHCP subnet: 192.168.1.0/255.255.255.0
nginx_1  | 192.168.1.14 - - [20/Feb/2022:03:31:59 +0000] "GET /pxeboot/ubuntu-20.04.3-live-server-amd64.iso HTTP/1.1" 200 1261371392 "-" "Wget" "-"
nginx_1  | 192.168.1.14 - - [20/Feb/2022:03:32:26 +0000] "GET /pxeboot/ubuntu-20.04.3-live-server-amd64.iso HTTP/1.1" 200 1261371392 "-" "Cloud-Init/21.2-3-g899bfaa9-0ubuntu2~20.04.1" "-"
dhcp_1   | dnsmasq-dhcp: 348588572 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 348588572 client provides name: ubuntu-server
dhcp_1   | dnsmasq-dhcp: 348588572 available DHCP subnet: 192.168.1.0/255.255.255.0
dhcp_1   | dnsmasq-dhcp: 348588572 client provides name: ubuntu-server
nginx_1  | 192.168.1.14 - - [20/Feb/2022:03:32:41 +0000] "GET /pxeboot/ubuntu-20.04.3-live-server-amd64.iso HTTP/1.1" 200 1261371392 "-" "Cloud-Init/21.2-3-g899bfaa9-0ubuntu2~20.04.1" "-"
nginx_1  | 192.168.1.14 - - [20/Feb/2022:03:32:42 +0000] "GET /pxeboot/autoinstall/meta-data HTTP/1.1" 200 0 "-" "Cloud-Init/21.2-3-g899bfaa9-0ubuntu2~20.04.1" "-"
nginx_1  | 192.168.1.14 - - [20/Feb/2022:03:32:42 +0000] "GET /pxeboot/autoinstall/user-data HTTP/1.1" 200 369 "-" "Cloud-Init/21.2-3-g899bfaa9-0ubuntu2~20.04.1" "-"
nginx_1  | 2022/02/20 03:32:42 [error] 24#24: *6 open() "/usr/share/nginx/html/pxeboot/autoinstall/vendor-data" failed (2: No such file or directory), client: 192.168.1.14, server: localhost, request: "GET /pxeboot/autoinstall/vendor-data HTTP/1.1", host: "192.168.1.50"
nginx_1  | 192.168.1.14 - - [20/Feb/2022:03:32:42 +0000] "GET /pxeboot/autoinstall/vendor-data HTTP/1.1" 404 153 "-" "Cloud-Init/21.2-3-g899bfaa9-0ubuntu2~20.04.1" "-"
nginx_1  | 2022/02/20 03:32:43 [error] 24#24: *7 open() "/usr/share/nginx/html/pxeboot/autoinstall/vendor-data" failed (2: No such file or directory), client: 192.168.1.14, server: localhost, request: "GET /pxeboot/autoinstall/vendor-data HTTP/1.1", host: "192.168.1.50"
nginx_1  | 192.168.1.14 - - [20/Feb/2022:03:32:43 +0000] "GET /pxeboot/autoinstall/vendor-data HTTP/1.1" 404 153 "-" "Cloud-Init/21.2-3-g899bfaa9-0ubuntu2~20.04.1" "-"
nginx_1  | 2022/02/20 03:32:44 [error] 24#24: *8 open() "/usr/share/nginx/html/pxeboot/autoinstall/vendor-data" failed (2: No such file or directory), client: 192.168.1.14, server: localhost, request: "GET /pxeboot/autoinstall/vendor-data HTTP/1.1", host: "192.168.1.50"
nginx_1  | 192.168.1.14 - - [20/Feb/2022:03:32:44 +0000] "GET /pxeboot/autoinstall/vendor-data HTTP/1.1" 404 153 "-" "Cloud-Init/21.2-3-g899bfaa9-0ubuntu2~20.04.1" "-"
nginx_1  | 2022/02/20 03:32:45 [error] 24#24: *9 open() "/usr/share/nginx/html/pxeboot/autoinstall/vendor-data" failed (2: No such file or directory), client: 192.168.1.14, server: localhost, request: "GET /pxeboot/autoinstall/vendor-data HTTP/1.1", host: "192.168.1.50"
...
# Client側でUbuntuのインストール画面が出てくる
```

## 参考にしている資料
- [OS自動インストールを行うためのPXEブート環境を作る - Qiita](https://qiita.com/sakai00kou/items/bc6ae4d6b4cacc4b8af9)
- [Ubuntu Server 20.04の自動インストール機能でネットワークインストールする。 - Qiita](https://qiita.com/sakai00kou/items/7ce4a8a410251b98b2ac)
- [DNSMASQ](https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html)
- [Netbooting the server installer on amd64 - Ubuntu](https://ubuntu.com/server/docs/install/netboot-amd64)
