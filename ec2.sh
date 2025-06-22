#!/bin/bash

# ---------- REQUIRED CONFIG ----------
REGION="us-east-1"
AMI_ID="ami-020cba7c55df1f615"  # Ubuntu 22.04 LTS x86_64 for us-east-1
INSTANCE_TYPE="t3.medium"
KEY_NAME="runner-ec2"            # Make sure this key already exists
SECURITY_GROUP_ID="sg-xxxxxxxxxxxx" # Must allow port 22 (SSH)
SUBNET_ID="subnet-xxxxxxxxxxxx"     # Must be a public subnet
IAM_ROLE_NAME="EC2EKSReadRole"      # Optional
INSTANCE_NAME="self-hosted-runner"
VOLUME_SIZE=30                      # GB
# -------------------------------------

# Create the instance
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SECURITY_GROUP_ID \
  --subnet-id $SUBNET_ID \
  --associate-public-ip-address \
  --iam-instance-profile Name=$IAM_ROLE_NAME \
  --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":$VOLUME_SIZE,\"VolumeType\":\"gp3\"}}]" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
  --region $REGION \
  --query 'Instances[0].InstanceId' \
  --output text
)

echo "EC2 instance launched with ID: $INSTANCE_ID"

# Wait for instance to be running
echo "Waiting for instance to enter 'running' state..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --region $REGION \
  --output text
)

echo "EC2 instance is running at public IP: $PUBLIC_IP"
