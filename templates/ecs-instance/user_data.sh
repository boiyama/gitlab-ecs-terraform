Content-Type: multipart/mixed; boundary="===============BOUNDARY=="
MIME-Version: 1.0

--===============BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"

#! /bin/bash
#Put your standard user data here
echo "extra standard user data"

--===============BOUNDARY==
MIME-Version: 1.0
Content-Type: text/cloud-boothook; charset="us-ascii"

#cloud-boothook
#Join your ECS cluster
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config
PATH=$PATH:/usr/local/bin
#Instance should be added to an security group that allows HTTP outbound
yum update
#Install NFS client
if ! rpm -qa | grep -qw nfs-utils; then
    yum -y install nfs-utils
fi
#Get region of EC2 from instance metadata
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
#Get EFS FileSystemID attribute
#Instance needs to be added to a EC2 role that give the instance at least read access to EFS
EFS_FILE_SYSTEM_ID=${efs_id}
#Instance needs to be a member of security group that allows 2049 inbound/outbound
#The security group that the instance belongs to has to be added to EFS file system configuration
#Create variables for source and target
DIR_SRC=$EC2_AVAIL_ZONE.$EFS_FILE_SYSTEM_ID.efs.$EC2_REGION.amazonaws.com
DIR_TGT=/mnt/efs
#Create a mount point for your Amazon EFS file system
if [ ! -d "$DIR_TGT" ]; then
  mkdir -p $DIR_TGT
fi
#Mount your file system with the following command. Be sure to replace the file system ID and region with your own
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $DIR_SRC:/ $DIR_TGT
#Validate that the file system is mounted correctly with the following command
#You should see a file system entry that matches your Amazon EFS file system
#If not, see Troubleshooting Amazon EFS in the Amazon Elastic File System User Guide
mount | grep efs
#Make a backup of the /etc/fstab file
cp /etc/fstab /etc/fstab.bak-$(date +%F)
#Update the /etc/fstab file to automatically mount the file system at boot
echo "$DIR_SRC:/ $DIR_TGT nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" | tee -a /etc/fstab
#Reload the file system table to verify that your mounts are working properly
mount -a
#Stop the Amazon ECS container agent
stop ecs
#Restart the Docker daemon
service docker restart
#Start the Amazon ECS container agent
start ecs
--===============BOUNDARY==--
