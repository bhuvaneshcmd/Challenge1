#!/bin/bash

# Step 1: Update and install required packages
sudo apt-get update
sudo apt-get install ruby-full ruby-webrick wget -y

# Step 2: Clean any previous leftovers
rm -rf /tmp/codedeploy-agent_1.3.2-1902*
cd /tmp

# Step 3: Download the CodeDeploy agent
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/releases/codedeploy-agent_1.3.2-1902_all.deb

# Step 4: Extract and patch the package
mkdir codedeploy-agent_1.3.2-1902_ubuntu22
dpkg-deb -R codedeploy-agent_1.3.2-1902_all.deb codedeploy-agent_1.3.2-1902_ubuntu22

# Patch control file: change ruby3.0 -> ruby3.2
sed -i 's/Depends:.*/Depends: ruby3.2/' codedeploy-agent_1.3.2-1902_ubuntu22/DEBIAN/control

# Step 5: Rebuild the package
dpkg-deb -b codedeploy-agent_1.3.2-1902_ubuntu22

# Step 6: Install the patched package
sudo dpkg -i codedeploy-agent_1.3.2-1902_ubuntu22.deb

# Step 7: Start and enable codedeploy agent
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent

# Step 8: Verify status
sudo service codedeploy-agent status
