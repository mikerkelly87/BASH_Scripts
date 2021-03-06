#! /bin/bash

#While Studying for the RHCE I pretty much always needed
#2 VMs running. This BASH script assumes you are running
#KVM (yum/dnf install kvm virt-manager OR apt-get install
#kvm virt-manager), if you don't have the virt-install package
#you will also need to install that.
#
#This script will take a base qcow2 image and create 2 VMs
#If you run the script again it will delete the existing VMs
#before recreating them.
#
#This is just for my personal use so don't blame me if you run
#this script and it deletes other things on your machine.

#Set Variables
IMAGE_PATH=/var/lib/libvirt/images/
BASE_IMAGE=CentOS7_Base1.qcow2
NEW_IMAGE_1=RHCE1.qcow2
NEW_IMAGE_2=RHCE2.qcow2
VM1_NAME=RHCE1
VM2_NAME=RHCE2

#Check to see if VMs exist
echo "Checking to see if VMs already exist"
echo " "
virsh list --all | grep RHCE
if [ $? == 0 ]; then
#If VMs exist check to see if they are running
virsh list --all | grep running
        if [ $? == 0 ]; then
        echo "VMs exist AND ARE running"
        echo " "
        echo "Shutting Down VMs now..."
        echo " "
        #Shutdown VMs
        virsh destroy "$VM1_NAME"
        virsh destroy "$VM2_NAME"
        elif [ $? == 1 ]; then
        echo "VMs exist and ARE NOT running"
        echo " "
        fi
#Delete VMs
echo "Deleting VMs"
echo " "
virsh undefine "$VM1_NAME"
virsh undefine "$VM2_NAME"

#If VMs don't exist, move along sir
else
echo "VMs don't already exist, preparing to create..."
echo " "
fi

#Check to see if Disk Files exist
echo "Checking to see if disk images already exist..."
echo " "
ls "$IMAGE_PATH" | grep RHCE
#If image files exist...
if [ $? == 0 ]; then
echo "Older image files exist, preparing to remove..."
echo " "
#Delete the existing disk image files
rm -f "$IMAGE_PATH""$NEW_IMAGE_1"
rm -f "$IMAGE_PATH""$NEW_IMAGE_2"
else
#If files don't exist, move along sir
echo "Image files don't already exist, will create them..."
echo " "
fi

#Create the first copy of the base image
echo "Creating copy of first disk image..."
cp "$IMAGE_PATH""$BASE_IMAGE" "$IMAGE_PATH""$NEW_IMAGE_1"
echo " "

#Create the second copy of the base image
echo "Creating copy of second disk image..."
cp "$IMAGE_PATH""$BASE_IMAGE" "$IMAGE_PATH""$NEW_IMAGE_2"
echo " "

#Create the first VM
echo "Creating first VM..."
virt-install --name "$VM1_NAME" --memory 512 --vcpus 1 --import --disk "$IMAGE_PATH""$NEW_IMAGE_1" --noautoconsole
echo " "

#Create the second VM
echo "Creating second VM..."
virt-install --name "$VM2_NAME" --memory 512 --vcpus 1 --import --disk "$IMAGE_PATH""$NEW_IMAGE_2" --noautoconsole
echo " "

#Add extra network adapter on first VM
echo "Adding Second Interface to First VM"
virsh attach-interface --domain "$VM1_NAME" --type network --source default --persistent
echo " "

#Add extra network adapter on second VM
echo "Adding Second Interface to Second VM"
virsh attach-interface --domain "$VM2_NAME" --type network --source default --persistent
echo " "

#Let the user know the creation has finished
echo "Virtual Machines Created"
echo "Root password for both machines is password"

#Author Mike Kelly 2016
