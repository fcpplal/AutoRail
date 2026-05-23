#!/bin/sh

# 替换配置文件中的 UUID
sed -i "s/PASTE_YOUR_UUID_HERE/$UUID/g" config.json

# ==========================================
# 🛠️ 新增：轻量级保活 Web 响应服务
# ==========================================
# 利用 nc 监听 8080 端口，如果收到非 /vless 的根目录请求，直接返回 HTTP 200 
# 这样既能应付 Koyeb 的健康检查，又不会堵塞真正的代理流量
# ==========================================
cat << 'EOF' > /app/web_server.sh
#!/bin/sh
RESPONSE="HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 20\r\n\r\nKeep-Alive Server OK"
while true; do
  echo -e "$RESPONSE" | nc -lp 8080
done
EOF
chmod +x /app/web_server.sh
/app/web_server.sh & # 在后台悄悄运行

# 1. 后台运行 sing-box
sing-box run -c config.json &

echo "=================================================================="
echo "🚀 专属容器部署成功！您的 VLESS 万能快捷导入节点如下："
echo "------------------------------------------------------------------"
if [ -n "$UUID" ] && [ -n "$DOMAIN" ]; then
    echo "vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=%2Fvless#🇸🇬🌍🇸🇬新加坡备用_Railway"
    echo "非TLS，用80端口，节点如下："
    echo "vless://${UUID}@www.shopify.com:80?encryption=none&security=none&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=%2Fvless#🇸🇬🌍🇸🇬新加坡备用_Railway"
else
    echo "[提示] 如果需要自动输出成品链接，请在环境变量里补全 DOMAIN 参数"
fi
echo "=================================================================="

# 2. 前台运行 Cloudflare Tunnel 阻塞主进程
if [ -n "$ARGO_TOKEN" ]; then
    echo "正在启动 Cloudflare Tunnel..."
    cloudflared tunnel --no-autoupdate run --token $ARGO_TOKEN
else
    echo "[警告] 未检测到 ARGO_TOKEN，寻求保持容器运行..."
    wait
fi
