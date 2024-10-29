#!/bin/bash

LOGFILE="/var/log/user-data.log"

# 只保留一个全局重定向
exec > >(tee -a ${LOGFILE} | logger -t user-data) 2>&1

echo "开始更新包列表..."
sudo apt-get update && echo "包列表更新完成。" || echo "包列表更新失败。"

echo "添加 Amazon SSM Agent 仓库..."
sudo snap install amazon-ssm-agent --classic && echo "Amazon SSM Agent 仓库添加成功。" || echo "Amazon SSM Agent 仓库添加失败。"

echo "开始安装 Nginx..."
sudo apt-get install -y nginx && echo "Nginx 安装完成。" || echo "Nginx 安装失败。"

echo "启动 Nginx 服务..."
sudo systemctl start nginx && echo "Nginx 启动成功。" || echo "Nginx 启动失败。"

echo "启动 Amazon SSM Agent 服务..."
sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service && echo "Amazon SSM Agent 启动成功。" || echo "Amazon SSM Agent 启动失败。"

echo "设置 Nginx 和 Amazon SSM Agent 开机自启动..."
sudo systemctl enable nginx && echo "Nginx 设置为开机自启动。" || echo "Nginx 开机自启动设置失败。"
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service && echo "Amazon SSM Agent 设置为开机自启动。" || echo "Amazon SSM Agent 开机自启动设置失败。"

echo "检查 SSH 服务状态..."
if sudo systemctl is-active --quiet ssh; then
  echo "SSH 服务已运行。"
else
  echo "SSH 服务未运行，尝试启动..."
  sudo systemctl start ssh && echo "SSH 服务启动成功。" || echo "SSH 服务启动失败。"
fi
