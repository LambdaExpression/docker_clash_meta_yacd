# Dockerfile
# 使用 Alpine Linux 作为基础镜像
FROM alpine:3.19

# 设置环境变量
ENV CLASH_META_VERSION=v1.19.19
ENV YACD_VERSION=v0.3.8
ENV CLASH_HTTP_PORT=7890
ENV CLASH_SOCKS_PORT=7891
ENV CLASH_MIXED_PORT=7893
ENV CLASH_API_PORT=9090
ENV WEB_UI_PORT=80
ENV TZ=Asia/Shanghai

# 安装依赖
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    tar \
    xz \
    gzip \
    ca-certificates \
    tzdata \
    su-exec \
    libc6-compat \
    nginx \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /run/nginx

# 创建必要的目录
RUN mkdir -p \
    /app/clash \
    /app/web \
    /config \
    /data \
    /var/log/nginx

# 安装 Clash.Meta (mihomo)
RUN ARCH=$(uname -m) && \
    case ${ARCH} in \
        x86_64)  ARCH="amd64" ;; \
        aarch64) ARCH="arm64" ;; \
        armv7l)  ARCH="armv7" ;; \
        *) echo "Unsupported architecture: ${ARCH}" && exit 1 ;; \
    esac && \
    wget -q "https://github.com/MetaCubeX/mihomo/releases/download/${CLASH_META_VERSION}/mihomo-linux-${ARCH}-${CLASH_META_VERSION}.gz" -O /tmp/mihomo.gz && \
    gzip -d /tmp/mihomo.gz && \
    mv /tmp/mihomo /app/clash/mihomo && \
    chmod +x /app/clash/mihomo

# 下载 Yacd Web UI
RUN wget -q "https://github.com/haishanh/yacd/releases/download/${YACD_VERSION}/yacd.tar.xz" -O /tmp/yacd.tar.xz && \
    tar -xf /tmp/yacd.tar.xz -C /app/web --strip-components=1 && \
    rm -rf /tmp/yacd.tar.xz

# 配置 nginx 为 Yacd 提供服务
COPY nginx.conf /etc/nginx/nginx.conf

# 创建启动脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 复制默认配置文件
COPY config.yaml.example /config/config.yaml.example

# 暴露端口
EXPOSE ${CLASH_HTTP_PORT} ${CLASH_SOCKS_PORT} ${CLASH_MIXED_PORT} ${CLASH_API_PORT} ${WEB_UI_PORT}

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${WEB_UI_PORT}/ || exit 1

# 设置工作目录
WORKDIR /config

# 启动命令
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
