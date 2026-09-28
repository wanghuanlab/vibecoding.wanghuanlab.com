#!/usr/bin/env bash
#
# 探测 vibecoding.wanghuanlab.com 生产服务器部署现状
#
set -Eeuo pipefail

SSH_HOST="vibecoding.wanghuanlab.com"
SSH_USER="root"
SSH_PORT="22"
REMOTE_SITE_DIR="/opt/1panel/www/sites/vibecoding.wanghuanlab.com"
REMOTE_INDEX_DIR="$REMOTE_SITE_DIR/index"
REMOTE_CONF="/opt/1panel/www/conf.d/vibecoding.wanghuanlab.com.conf"

echo "========================================================"
echo " 生产环境探测报告：$SSH_HOST"
echo "========================================================"

ssh -o BatchMode=yes -o ConnectTimeout=8 -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" bash -s -- "$REMOTE_SITE_DIR" "$REMOTE_INDEX_DIR" "$REMOTE_CONF" <<'EOF'
SITE_DIR="$1"
INDEX_DIR="$2"
CONF_FILE="$3"

echo "[1/5] 站点目录与 Nginx 配置："
if [[ -d "$INDEX_DIR" ]]; then
  echo "  ✓ 静态根目录存在: $INDEX_DIR"
  echo "  - 目录属主/权限: $(stat -c '%U:%G (%a)' "$INDEX_DIR" 2>/dev/null || stat -f '%Su:%Sg (%p)' "$INDEX_DIR")"
else
  echo "  ✗ 静态根目录不存在: $INDEX_DIR"
fi

if [[ -f "$CONF_FILE" ]]; then
  echo "  ✓ 1Panel Nginx 配置文件: $CONF_FILE"
else
  echo "  ! 配置文件未在默认路径发现: $CONF_FILE"
fi

echo ""
echo "[2/5] 当前线上版本哈希与更新时间："
if [[ -f "$INDEX_DIR/index.html" ]]; then
  SHA256=$(sha256sum "$INDEX_DIR/index.html" 2>/dev/null | awk '{print $1}' || shasum -a 256 "$INDEX_DIR/index.html" | awk '{print $1}')
  MOD_TIME=$(stat -c '%y' "$INDEX_DIR/index.html" 2>/dev/null || stat -f '%Sm' "$INDEX_DIR/index.html")
  FILE_COUNT=$(find "$INDEX_DIR" -type f | wc -l | tr -d ' ')
  echo "  - index.html SHA256: $SHA256"
  echo "  - 最后修改时间:      $MOD_TIME"
  echo "  - 站点文件总数:      $FILE_COUNT 个"
else
  echo "  ! 警告: $INDEX_DIR/index.html 不存在"
fi

echo ""
echo "[3/5] 历史备份目录列表："
BACKUPS=$(ls -1dt "$SITE_DIR"/index.backup-* 2>/dev/null || true)
if [[ -n "$BACKUPS" ]]; then
  echo "$BACKUPS" | while read -r b; do
    echo "  - $(basename "$b") ($(stat -c '%y' "$b" 2>/dev/null || stat -f '%Sm' "$b"))"
  done
else
  echo "  (暂无历史备份目录)"
fi

echo ""
echo "[4/5] 磁盘空间状态："
df -h "$SITE_DIR" | tail -n 1 | awk '{printf "  - 挂载点: %s | 总量: %s | 已用: %s (%s) | 可用: %s\n", $6, $2, $3, $5, $4}'

echo ""
echo "[5/5] 在线 HTTPS 服务检测："
HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 5 https://vibecoding.wanghuanlab.com/ || echo "000")
echo "  - https://vibecoding.wanghuanlab.com/ => HTTP $HTTP_CODE"
EOF
