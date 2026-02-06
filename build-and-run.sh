#!/bin/bash
# build-and-run.sh

set -e

# 创建必要的目录
mkdir -p ./clash-config ./clash-data

# 构建 Docker 镜像
echo "Building Docker image..."
docker build -t clash-meta-yacd:latest .

# 运行容器
echo "Starting container..."
docker run -d \
  --name=clash-meta-yacd \
  --restart=unless-stopped \
  -p 7890:7890 \
  -p 7891:7891 \
  -p 7893:7893 \
  -p 9090:9090 \
  -p 8080:80 \
  -v $(pwd)/clash-config:/config \
  -v $(pwd)/clash-data:/data \
  -e TZ=Asia/Shanghai \
  --cap-add=NET_ADMIN \
  clash-meta-yacd:latest

echo "=========================================="
echo "Clash Meta + Yacd 已启动！"
echo "=========================================="
echo "Web UI: http://localhost:8080"
echo "HTTP 代理: localhost:7890"
echo "SOCKS5 代理: localhost:7891"
echo "配置文件目录: ./clash-config"
echo "=========================================="
echo "查看日志: docker logs clash-meta-yacd"
echo "进入容器: docker exec -it clash-meta-yacd /entrypoint.sh shell"
echo "重新加载配置: docker exec clash-meta-yacd /entrypoint.sh reload"
echo "=========================================="
