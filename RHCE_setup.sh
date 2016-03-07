#! /bin/bash

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
virt-install --name "$VM1_NAME" --memory 1024 --vcpus 1 --import --disk "$IMAGE_PATH""$NEW_IMAGE_1" --noautoconsole
echo " "

#Create the second VM
echo "Creating second VM..."
virt-install --name "$VM2_NAME" --memory 1024 --vcpus 1 --import --disk "$IMAGE_PATH""$NEW_IMAGE_2" --noautoconsole
echo " "

#Let the user know the creation has finished
echo "Virtual Machines Created"
echo "Root password for both machines is S3cur3"
