# Clash Meta + Yacd Docker 镜像

一个集成了 **Clash.Meta**（原Mihomo）核心和 **Yacd** Web管理界面的Docker容器解决方案。一键部署，轻松管理您的代理服务。

## ✨ 特性

- 🐳 **一体化容器**：Clash.Meta核心 + Yacd Web界面
- 🔧 **简单配置**：只需挂载配置文件目录即可使用
- 📱 **响应式界面**：支持电脑和手机端管理
- 🔒 **安全可靠**：自动生成随机密钥，支持自定义
- 🚀 **高性能**：基于Alpine Linux，资源占用低
- 🔄 **热重载**：支持配置热更新，无需重启服务

## 📦 快速开始

### 方法一：使用 Docker Compose（推荐）

```bash
# 1. 创建目录
mkdir -p clash-meta-yacd && cd clash-meta-yacd

# 2. 下载必要文件
mkdir -p ./clash-config/ruleset && \
wget https://raw.githubusercontent.com/LambdaExpression/docker_clash_meta_yacd/refs/heads/main/clash-config/config.yaml -O ./clash-config/config.yaml && \
wget https://raw.githubusercontent.com/LambdaExpression/docker_clash_meta_yacd/refs/heads/main/clash-config/Country.mmdb -O ./clash-config/Country.mmdb  && \
wget https://raw.githubusercontent.com/LambdaExpression/docker_clash_meta_yacd/refs/heads/main/clash-config/ruleset/proxy.yaml -O ./clash-config/ruleset/proxy.yaml && \
wget https://raw.githubusercontent.com/LambdaExpression/docker_clash_meta_yacd/refs/heads/main/clash-config/ruleset/reject.yaml -O ./clash-config/ruleset/reject.yaml

# 3. 下载容器镜像
docker pull lambdaexpression/clash-meta-yacd:latest

# 4. 运行容器
docker run -d \
  --name=clash-meta-yacd \
  --restart=unless-stopped \
  -p 7890:7890 \
  -p 7891:7891 \
  -p 7893:7893 \
  -p 9090:9090 \
  -p 8080:80 \
  -v ./clash-config:/config \
  -e TZ=Asia/Shanghai \
  --cap-add=NET_ADMIN \
  lambdaexpression/clash-meta-yacd:latest
  
# 5. 按实际情况配置 config.yaml, 配置完成后重启容器
```

### 方法二：使用 Docker 命令

```bash
# 1. 克隆或下载项目
git clone <repository-url>
cd docker_clash_meta_yacd

# 2. 构建镜像
docker build -t clash-meta-yacd:latest .

# 3. 运行容器
docker run -d \
  --name=clash-meta-yacd \
  --restart=unless-stopped \
  -p 7890:7890 \
  -p 7891:7891 \
  -p 7893:7893 \
  -p 9090:9090 \
  -p 8080:80 \
  -v ./clash-config:/config \
  -e TZ=Asia/Shanghai \
  --cap-add=NET_ADMIN \
  clash-meta-yacd:latest
  
# 4. 按实际情况配置 config.yaml, 配置完成后重启容器
```

### 方法三：使用一键脚本

```bash
# 给予执行权限
chmod +x build-and-run.sh

# 运行脚本（自动构建和启动）
./build-and-run.sh
```

## 🔧 配置文件

### 配置文件目录结构
```
./clash-config/
├── config.yaml          # 主配置文件
├── Country.mmdb         # IP地理数据库（自动下载）
└── ruleset/             # 规则集目录（自动创建）
```

### 配置文件示例

编辑 `./clash-config/config.yaml` 文件：

```yaml
port: 7890
socks-port: 7891
mixed-port: 7893
allow-lan: true
mode: rule
log-level: info
external-controller: 0.0.0.0:9090
#secret: "${SECRET}"
#external-ui: "/app/web"

# 代理节点配置
proxies:
  - name: "your-proxy"
    type: ss
    server: your-server
    port: 443
    cipher: chacha20-ietf-poly1305
    password: "your-password"

# 代理组
proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - DIRECT
      - your-proxy

# 规则
rules:
  - GEOIP,CN,DIRECT
  - MATCH,PROXY
```

> **注意**：如果不提供配置文件，容器将使用示例配置文件启动。

## 🌐 访问地址

容器启动后，可以通过以下地址访问：

| 服务 | 地址 | 说明 |
|------|------|------|
| **Yacd Web界面** | http://localhost:8080 | 管理界面（默认端口8080） |
| **Clash API** | http://localhost:9090 | REST API接口 |
| **HTTP代理** | localhost:7890 | HTTP/HTTPS代理 |
| **SOCKS5代理** | localhost:7891 | SOCKS5代理 |
| **混合端口** | localhost:7893 | 同时支持HTTP和SOCKS5 |

**需要访问密钥的话，请自行修改 config.yaml 添加**

## ⚙️ 端口映射说明

| 容器端口 | 主机端口（默认） | 协议 | 说明 |
|----------|------------------|------|------|
| 80 | 8080 | HTTP | Yacd Web管理界面 |
| 7890 | 7890 | HTTP/HTTPS | HTTP代理端口 |
| 7891 | 7891 | TCP | SOCKS5代理端口 |
| 7893 | 7893 | TCP | 混合代理端口 |
| 9090 | 9090 | HTTP | Clash REST API |

如需修改端口映射，在运行容器时调整 `-p` 参数，例如：
```bash
-p 8880:80      # 将Web界面端口改为8880
-p 8888:7890    # 将HTTP代理端口改为8888
```

## 🔧 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `TZ` | Asia/Shanghai | 时区设置 |
| `CLASH_HTTP_PORT` | 7890 | HTTP代理端口 |
| `CLASH_SOCKS_PORT` | 7891 | SOCKS5代理端口 |
| `CLASH_MIXED_PORT` | 7893 | 混合代理端口 |
| `CLASH_API_PORT` | 9090 | REST API端口 |
| `WEB_UI_PORT` | 80 | Nginx监听端口 |

## 📁 数据持久化

| 目录 | 说明 | 挂载示例 |
|------|------|----------|
| `/config` | 配置文件目录 | `-v ./clash-config:/config` |
| `/data` | 运行时数据目录 | `-v ./clash-data:/data` |

## 🛠️ 容器管理命令

```bash
# 查看日志
docker logs clash-meta-yacd

# 查看实时日志
docker logs -f clash-meta-yacd

# 进入容器
docker exec -it clash-meta-yacd /bin/sh

# 重启容器
docker restart clash-meta-yacd

# 停止容器
docker stop clash-meta-yacd

# 删除容器
docker rm -f clash-meta-yacd
```

## 🔄 配置热重载

修改配置文件后，无需重启容器：

```bash
# 方法一：通过容器内脚本
docker exec clash-meta-yacd /entrypoint.sh reload

# 方法二：通过API（需要密钥）
curl -X PUT "http://localhost:9090/configs" \
  -H "Content-Type: application/json" \
  -d "{\"path\": \"/config/config.yaml\"}"
```

## 🐳 项目构建

### 构建 Docker 镜像

```bash
# 从源码构建
docker build -t clash-meta-yacd:latest .

# 指定版本标签
docker build -t clash-meta-yacd:v1.0 .

# 多架构构建（需要buildx）
docker buildx build --platform linux/amd64,linux/arm64 -t yourname/clash-meta-yacd:latest --push .
```

### 项目文件结构

```
clash-meta-yacd/
├── Dockerfile              # Docker构建文件
├── docker-compose.yml      # Docker Compose配置
├── nginx.conf             # Nginx配置文件
├── entrypoint.sh          # 容器启动脚本
├── config.yaml.example    # 示例配置文件
├── .dockerignore          # Docker忽略文件
├── build-and-run.sh       # 一键构建运行脚本
├── README.md              # 本文档
├── clash-config/          # 配置文件目录（外部挂载）
└── clash-data/            # 数据目录（外部挂载）
```

## 🔧 高级功能

### 1. 启用 TUN 模式
在 `docker-compose.yml` 中添加：
```yaml
cap_add:
  - NET_ADMIN
sysctls:
  - net.ipv4.ip_forward=1
  - net.ipv6.conf.all.forwarding=1
```

### 2. 自定义 Nginx 配置
如需修改 Web 服务器配置，可以：
1. 修改 `nginx.conf` 文件
2. 重新构建镜像

### 3. 使用自定义规则集
在配置文件中添加规则集提供者：
```yaml
rule-providers:
  reject:
    type: http
    behavior: domain
    url: "https://example.com/reject.txt"
    path: ./ruleset/reject.yaml
    interval: 86400
```

## 🔍 故障排除

### 1. 容器启动失败
```bash
# 查看详细日志
docker logs clash-meta-yacd

# 检查端口占用
netstat -tulpn | grep :7890
```

### 2. Web 界面无法访问
```bash
# 检查容器状态
docker ps | grep clash-meta-yacd

# 检查端口映射
docker port clash-meta-yacd

# 检查容器内服务
docker exec clash-meta-yacd ps aux
```

### 3. 代理不工作
```bash
# 测试代理连接
curl -x http://localhost:7890 https://httpbin.org/ip

# 查看Clash日志
docker logs clash-meta-yacd | grep -i "proxy\|error"
```

## 📄 许可证

本项目基于 MIT 许可证开源。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## ⭐ 相关项目

- [Clash.Meta](https://github.com/MetaCubeX/mihomo) - 代理核心
- [Yacd](https://github.com/haishanh/yacd) - Web管理界面

## 📞 支持

如有问题，请：
1. 查看 [FAQ](#) 部分
2. 提交 [Issue](issues-url)
3. 查看日志文件：`docker logs clash-meta-yacd`


