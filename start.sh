#!/bin/sh

# 替换配置文件中的 UUID
sed -i "s/PASTE_YOUR_UUID_HERE/$UUID/g" config.json

# 后台运行 sing-box
sing-box run -c config.json &

echo "=================================================================="
echo "🚀 YouTube 大爷共享 恭喜您 专属容器部署成功！您的 VLESS 万能快捷导入节点如下："
echo "------------------------------------------------------------------"
if [ -n "$UUID" ] && [ -n "$DOMAIN" ]; then
    echo "vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=%2Fvless#🇸🇬🌍🇸🇬新加坡备用_Railway"
    echo "非TLS，用80端口，节点如下："
    echo "vless://${UUID}@www.shopify.com:80?encryption=none&security=none&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=%2Fvless#🇸🇬🌍🇸🇬新加坡备用_Railway"
else
    echo "[提示] 如果需要自动输出成品链接，请在环境变量里补全 DOMAIN 参数"
fi
echo "=================================================================="


# 运行 Cloudflare Tunnel
cloudflared tunnel --no-autoupdate run --token $ARGO_TOKEN
