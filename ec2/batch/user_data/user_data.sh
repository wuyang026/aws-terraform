#!/bin/bash
set -e

# システム設定
echo 'export LANG=ja_JP.UTF-8'       | sudo tee -a /etc/bashrc
echo 'export LC_ALL=ja_JP.UTF-8'     | sudo tee -a /etc/bashrc
echo 'export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "' | sudo tee -a /etc/bashrc

# aws cli v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update

# git
sudo yum install -y git

# kubectl
curl -LO https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.3/2025-08-03/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# eksctl
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl

# ==== 変数 ====
ADMIN_USER="${admin_username}"
DEFAULT_PASS="${default_password}"
REGION="${region}"
CLUSTER_NAME="${cluster_name}"

# ==== 管理者ユーザー作成 ====
echo "Creating user $ADMIN_USER ..."
sudo useradd -m -s /bin/bash "$ADMIN_USER"
echo "$ADMIN_USER:$DEFAULT_PASS" | sudo chpasswd
sudo chage -d 0 "$ADMIN_USER"
sudo usermod -aG wheel "$ADMIN_USER"

echo "$ADMIN_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/admin_nopasswd
sudo chmod 0440 /etc/sudoers.d/admin_nopasswd
echo "User $ADMIN_USER created, password set to default"

# ==== 一般ユーザー作成 ====
%{ for user in normal_users ~}
if id "${user}" &>/dev/null; then
  echo "User ${user} already exists, skipping"
else
  echo "Creating user ${user} ..."
  sudo useradd -m -s /bin/bash "${user}"
  echo "${user}:$DEFAULT_PASS" | sudo chpasswd
  sudo chage -d 0 "${user}"
  echo "User ${user} created, password set to default"

  # Setup kubeconfig for the user
  echo "Setting up kubeconfig for ${user}..."
  sudo runuser -l "${user}" -c "aws eks update-kubeconfig --region ${aws_region} --name ${eks_cluster_name}"
  sudo runuser -l "${user}" -c "kubectl config set-context --current --namespace=${default_namespace}"
  echo "Kubeconfig setup done for ${user}"
fi
%{ endfor ~}

echo "All users have been processed."

# ==== ec2-user無効化 ====
sudo usermod -s /sbin/nologin ec2-user

# ==== SSH設定 ====
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "DenyUsers ec2-user" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart sshd