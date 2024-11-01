#!/bin/bash

LOGFILE="/var/log/user-data.log"

# 只保留一个全局重定向
exec > >(tee -a ${LOGFILE} | logger -t user-data) 2>&1

echo "开始更新包列表..."
sudo apt-get update && echo "包列表更新完成。" || echo "包列表更新失败。"

echo "安装基础依赖包..."
sudo apt-get install -y \
    unzip \
    curl \
    wget \
    python3 \
    python3-pip \
    docker.io \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    zsh \
    fonts-powerline \
    && echo "基础依赖包安装完成。" || echo "基础依赖包安装失败。"

echo "安装 Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 安装常用的 Zsh 插件
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 配置 Zsh
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker aws)/' ~/.zshrc

# 添加一些有用的 Zsh 别名
cat << 'EOF' >> ~/.zshrc

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias python=python3
alias pip=pip3

# AWS aliases
alias awslocal='aws --endpoint-url=http://localhost:4566'
alias samlocal='sam local'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'

# Python virtual environment
alias venv='python -m venv venv'
alias activate='source venv/bin/activate'

# AWS SAM aliases
alias saml='sam local'
alias samt='sam template'
alias samb='sam build'
alias samd='sam deploy'

EOF

# 将 Zsh 设置为默认 shell
sudo chsh -s $(which zsh) ubuntu

echo "添加 Amazon SSM Agent 仓库..."
sudo snap install amazon-ssm-agent --classic && echo "Amazon SSM Agent 仓库添加成功。" || echo "Amazon SSM Agent 仓库添加失败。"

echo "开始安装 Nginx..."
sudo apt-get install -y nginx && echo "Nginx 安装完成。" || echo "Nginx 安装失败。"

echo "安装 AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
aws --version && echo "AWS CLI v2 安装完成。" || echo "AWS CLI v2 安装失败。"

echo "安装 AWS SAM CLI..."
wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
sudo ./sam-installation/install
rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
sam --version && echo "AWS SAM CLI 安装完成。" || echo "AWS SAM CLI 安装失败。"

echo "安装 nvm (Node Version Manager)..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 添加 nvm 到 .bashrc
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# 安装最新的 LTS 版本 Node.js
nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

echo "安装 pyenv (Python Version Manager)..."
curl https://pyenv.run | bash

# 添加 pyenv 到 .bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# 立即加载 pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# 安装 Python 版本
pyenv install 3.9.18
pyenv install 3.11.7
pyenv global 3.11.7

echo "安装 AWS CDK..."
npm install -g aws-cdk
cdk --version && echo "AWS CDK 安装完成。" || echo "AWS CDK 安装失败。"

echo "安装 Python AWS 开发包..."
pip3 install \
    boto3 \
    awscli \
    aws-sam-cli \
    aws-cdk-lib \
    poetry \
    virtualenv \
    && echo "Python AWS 开发包安装完成。" || echo "Python AWS 开发包安装失败。"

echo "启动 Docker 服务..."
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
docker --version && echo "Docker 服务配置完成。" || echo "Docker 服务配置失败。"

echo "启动 Nginx 服务..."
sudo systemctl start nginx && echo "Nginx 启动成功。" || echo "Nginx 启动失败。"

echo "启动 Amazon SSM Agent 服务..."
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service && echo "Amazon SSM Agent 启动成功。" || echo "Amazon SSM Agent 启动失败。"

echo "设置服务开机自启动..."
sudo systemctl enable nginx && echo "Nginx 设置为开机自启动。" || echo "Nginx 开机自启动设置失败。"
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service && echo "Amazon SSM Agent 设置为开机自启动。" || echo "Amazon SSM Agent 开机自启动设置失败。"
sudo systemctl enable docker && echo "Docker 设置为开机自启动。" || echo "Docker 开机自启动设置失败。"

echo "检查 SSH 服务状态..."
if sudo systemctl is-active --quiet ssh; then
  echo "SSH 服务已运行。"
else
  echo "SSH 服务未运行，尝试启动..."
  sudo systemctl start ssh && echo "SSH 服务启动成功。" || echo "SSH 服务启动失败。"
fi

# 创建版本管理器使用说明
cat << 'EOF' > ~/version-manager-guide.txt
版本管理器使用指南：

1. NVM (Node.js 版本管理)：
   - 列出可用版本：nvm ls-remote
   - 安装特定版本：nvm install <version>
   - 切换版本：nvm use <version>
   - 设置默认版本：nvm alias default <version>

2. Pyenv (Python 版本管理)：
   - 列出可用版本：pyenv install --list
   - 安装特定版本：pyenv install <version>
   - 切换版本：pyenv global <version>
   - 查看已安装版本：pyenv versions

3. Zsh 配置信息：
   - 当前主题：agnoster
   - 已安装插件：
     * git
     * zsh-autosuggestions (命令建议)
     * zsh-syntax-highlighting (语法高亮)
     * docker (Docker 命令补全)
     * aws (AWS CLI 命令补全)
   
   常用别名：
   - ll, la, l：列表文件
   - d：docker
   - dc：docker-compose
   - gs：git status
   - awslocal：本地 AWS 端点
   - saml：sam local
   - venv：创建 Python 虚拟环境
   - activate：激活虚拟环境

已安装的 Python 版本：
- Python 3.9.18
- Python 3.11.7 (默认)

已安装的 Node.js 版本：
- 最新 LTS 版本 (默认)

注意：首次使用时需要重新加载终端或执行 'source ~/.bashrc' 以使环境变量生效。
EOF

echo "配置 AWS 开发环境完成。版本管理器使用指南已保存到 ~/version-manager-guide.txt"
