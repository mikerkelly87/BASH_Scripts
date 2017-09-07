#!/bin/bash

# Script to automate my Red Hat 7 Clustering Lab environment creation
# This uses both virt-install (KVM) and Kickstart files to autmate the
# creation and configuration of the virtual machines
# This also relies on having the Kickstart files hosted on a web server

# Check to see if this is being run as a user with
# root privileges as VM creation requires it
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Variables to make life easier should names or paths change
IMAGE_PATH=/var/lib/libvirt/images/
NEW_IMAGE_1=RHCE1.qcow2
NEW_IMAGE_2=RHCE2.qcow2
VM1_NAME=node1
VM2_NAME=node2
VM1_DISK=node1.qcow2
VM2_DISK=node2.qcow2
MEDIA_PATH=/home/mkelly/ISOs/CentOS-7-x86_64-DVD-1611.iso
KS1_URL=http://192.168.122.1/node1-ks.cfg
KS2_URL=http://192.168.122.1/node2-ks.cfg


echo "Starting Creation of Clustering Lab"
echo " "


# Check to see if VMs exist
echo "Checking to see if VMs already exist"
echo " "
virsh list --all | grep node
if [ $? == 0 ]; then
# If VMs exist check to see if they are running
virsh list --all | grep running
        if [ $? == 0 ]; then
        echo "VMs exist AND ARE running"
        echo " "
        echo "Shutting Down VMs now..."
        echo " "
        # Shutdown VMs
        virsh destroy "$VM1_NAME"
        virsh destroy "$VM2_NAME"
        elif [ $? == 1 ]; then
        echo "VMs exist and ARE NOT running"
        echo " "
        fi
# Delete VMs
echo "Deleting VMs"
echo " "
virsh undefine "$VM1_NAME"
virsh undefine "$VM2_NAME"


# If VMs don't exist, move along sir
else
echo "VMs don't already exist, preparing to create..."
echo " "
fi


# Check to see if Disk Files exist
echo "Checking to see if disk images already exist..."
echo " "
ls "$IMAGE_PATH" | grep node
# If image files exist...
if [ $? == 0 ]; then
echo "Older disk image files exist, preparing to remove..."
echo " "
# Delete the existing disk image files
rm -f "$IMAGE_PATH""$VM1_DISK"
rm -f "$IMAGE_PATH""$VM2_DISK"
else
# If files don't exist, move along sir
echo "Disk image files don't already exist, will create them..."
echo " "
fi


# Create first VM
echo "Creating first VM node"
echo " "
virt-install                                                    \
  --name node1                                                  \
  --memory 1024                                                 \
  --vcpus 1                                                     \
  --disk path="$IMAGE_PATH""$VM1_DISK",format=qcow2,size=10     \
  --graphics vnc                                                \
  --noautoconsole                                               \
  --location $MEDIA_PATH                                        \
  --network default                                             \
  --network default                                             \
  --extra-args ks=$KS1_URL


# Create second VM
echo "Creating second VM node"
echo " "
virt-install                                                    \
  --name node2                                                  \
  --memory 1024                                                 \
  --vcpus 1                                                     \
  --disk path="$IMAGE_PATH""$VM2_DISK",format=qcow2,size=10     \
  --graphics vnc                                                \
  --noautoconsole                                               \
  --location $MEDIA_PATH                                        \
  --network default                                             \
  --network default                                             \
  --extra-args ks=$KS2_URL


# Exit script
echo "You can monitor the installation process by running 'virt-manager'"
