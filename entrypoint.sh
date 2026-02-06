#!/bin/bash
# entrypoint.sh

set -e

# 如果未设置 SECRET，生成一个随机字符串
if [ -z "${SECRET}" ]; then
    export SECRET=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
    echo "Generated random secret: ${SECRET}"
fi

# 函数：启动 Clash.Meta
start_clash() {
    echo "Starting Clash.Meta..."
    
    # 复制示例配置（如果配置文件不存在）
    if [ ! -f "/config/config.yaml" ]; then
        echo "No config.yaml found, using example config..."
        cp /config/config.yaml.example /config/config.yaml
    fi
    
    # 检查配置语法
    /app/clash/mihomo -d /config -t
    
    # 启动 Clash.Meta 在后台
    nohup /app/clash/mihomo -d /config &
    
    # 等待 API 就绪
    echo "Waiting for Clash API to be ready..."
    for i in {1..30}; do
        if curl -s http://127.0.0.1:9090 >/dev/null 2>&1; then
            echo "Clash API is ready!"
            break
        fi
        sleep 1
    done
}

# 函数：启动 Nginx
start_nginx() {
    echo "Starting Nginx..."
    nginx -g "daemon off;" &
}

# 函数：停止所有服务
stop_services() {
    echo "Stopping services..."
    nginx -s stop 2>/dev/null || true
    pkill -f "mihomo" 2>/dev/null || true
}

# 处理信号
trap 'stop_services; exit 0' SIGTERM SIGINT

# 主逻辑
case "$1" in
    start)
        start_clash
        start_nginx
        
        # 输出访问信息
        echo "=========================================="
        echo "Clash Meta + Yacd Container Started!"
        echo "=========================================="
        echo "Clash Meta API: http://localhost:9090"
        echo "Web UI (Yacd): http://localhost:${WEB_UI_PORT:-80}"
        echo "HTTP Proxy: localhost:${CLASH_HTTP_PORT:-7890}"
        echo "SOCKS5 Proxy: localhost:${CLASH_SOCKS_PORT:-7891}"
        echo "Mixed Port: localhost:${CLASH_MIXED_PORT:-7893}"
        echo "Secret: ${SECRET}"
        echo "=========================================="
        
        # 保持容器运行
        wait
        ;;
    stop)
        stop_services
        ;;
    reload)
        echo "Reloading Clash configuration..."
        curl -X PUT "http://127.0.0.1:9090/configs" \
            -H "Content-Type: application/json" \
            -d "{\"path\": \"/config/config.yaml\"}"
        ;;
    check)
        /app/clash/mihomo -d /config -t
        ;;
    shell)
        exec /bin/bash
        ;;
    *)
        echo "Usage: $0 {start|stop|reload|check|shell}"
        exit 1
        ;;
esac
