xe host-list
export host_uuid="$( xe host-list | grep -oP "[\d\w-]+" | grep -oP ".{20,}" | head -n 1 )"
echo host_uuid is this :    _____________ $host_uuid ______
xe sr-list
xe sr-list name-label="Local storage"
xe template-list | grep Debian

export vm_name="${1:-xeclivm}"
xe vm-install template="Debian Bookworm 12" new-name-label="${vm_name}"
export vm_uuid=$( xe vm-list | grep -B 1 "$vm_name" | grep -oP "[\d\w-]{20,}" )

echo vm_uuid is this : _______________ $vm_uuid __________
## Creating the iso sr Locally
mkdir -p /var/opt/xen/ISO_Store
cd /var/opt/xen/ISO_Store

xe-mount-iso-sr /run/sr-mount/bedd1ebf-c12c-875d-960c-257de20dec45/
xe sr-create host-uuid=$host_uuid name-label=LOCAL_ISO type=iso device-config:location=/var/opt/xen/ISO_Store device-config:legacy_mode=true content-type=iso     ###creating local ISO SR
#wget https://download.rockylinux.org/pub/r...
xe sr-list type=iso
export sr_iso_uuid=$(xe sr-list type=iso | grep -B 1 LOCAL_ISO | head -n 1 | grep -oP "[\d\w-]+-[\w\d]+")
xe sr-scan uuid=$sr_iso_uuid
## example shared
## xe sr-create name-label="Example ISO SR" content-type=iso type=iso shared=true device-config:location=$smb_iso_share device-config:username=cbitsys2 device-config:cifspassword="password" device-config:type=cifs device-config:vers="1.0"
# Dropping some files with your preferred workstation and the same rescan method as Locally
## xe cd-list | grep Rocky
## export cd_iso=Rocky-9.0-20220805.0-x86_64-minimal.iso
export cd_iso="debian-12.11.0-amd64-netinst.iso"
## xe vm-disk-list vm-name-label=$vm-name  
export vm_disk_uuid=$(  xe vm-disk-list uuid=$vm_uuid | grep -B 2 "Local storage" | head -n 1 | grep -oP "[\d\w-]+-[\d\w]+"  )
## xe network-list
export network_uuid=$( xe network-list | grep -B 3 xenbr0 | head -n 1 | grep -oP "[\d\w-]+-[\d\w]+" )
xe vm-cd-add uuid=$vm_uuid cd-name="$cd_iso" device=1
xe vm-param-set HVM-boot-policy="BIOS order" uuid=$vm_uuid
xe vif-create vm-uuid=$vm_uuid network-uuid=$network_uuid device=0
xe vm-memory-limits-set dynamic-max=2048MiB dynamic-min=2048MiB static-max=2048MiB static-min=512MiB uuid=$vm_uuid
xe vdi-resize uuid=$vm_disk_uuid disk-size=20GiB

xe vm-param-set uuid=$vm_uuid HVM-boot-params:order=dc

xe vbd-create \
  vm-uuid=$vm_uuid \
  device=3 \
  type=CD \
  vdi-uuid=8dba583e-57df-44eb-a954-c1db24d22cc0 \
  mode=RO \
  bootable=true

xe vm-param-set uuid=$vm_uuid platform:secureboot=false
xe vm-param-set uuid=$vm_uuid platform:device-model=qemu-traditional

xe vm-param-set uuid=$vm_uuid HVM-boot-policy="BIOS order"
xe vm-param-set uuid=$vm_uuid HVM-boot-params:firmware=bios

xe vm-cd-eject uuid=$vm_uuid
xe vm-cd-insert cd-name=guest-tools.iso uuid=$vm_uuid
xe vm-cd-insert vm=$1   cd-name=debian-12.11.0-amd64-netinst.iso

xe vm-start uuid=$vm_uuid
## at xcp-ng host:
#yum install socat
#list_domains | grep $vm_uuid
#socat TCP-LISTEN:9000 UNIX-CONNECT:/var/run/xen/vnc-??
## On the windows workstation with putty ssh tunnel
## Connection with vnc-viewer
# xe vm-cd-eject uuid=$vm_uuid
# xe vm-cd-insert cd-name=guest-tools.iso uuid=$vm_uuid
# xe vm-cd-insert vm=$1   cd-name=debian-12.11.0-amd64-netinst.iso
# sudo sysctl -w net.ipv4.ip_forward=1
#
# sudo iptables -t nat -A OUTPUT -p tcp -d 172.30.29.11 --dport 443 -j DNAT --to-destination 127.0.0.1:1818
