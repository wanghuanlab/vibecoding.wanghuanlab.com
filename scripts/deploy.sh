#!/usr/bin/env bash
#
# 部署 vibecoding.wanghuanlab.com 到生产服务器。
#
# 采用安全原子发布机制：
# 1. 本地打包静态文件（index.html, docs/, assets/, 404.html）
# 2. 上传到远端隔离暂存目录 index.upload-<TIMESTAMP>
# 3. 远端校验 index.html SHA256 哈希完整性
# 4. 原子重命名原 index 为 index.backup-<TIMESTAMP>，将暂存目录切换为 index
# 5. 自动保留最近 3 份历史备份，清理陈旧备份
# 6. 线上全链路 HTTPS 健康检查
#
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

SSH_HOST="vibecoding.wanghuanlab.com"
SSH_USER="root"
SSH_PORT="22"
REMOTE_SITE_DIR="/opt/1panel/www/sites/vibecoding.wanghuanlab.com"
REMOTE_INDEX_DIR="$REMOTE_SITE_DIR/index"
REMOTE_OWNER="1panel:1panel"
HEALTH_URL="https://vibecoding.wanghuanlab.com/"
DOCS_URL="https://vibecoding.wanghuanlab.com/docs/index.html"
KEEP_BACKUPS=3
DRY_RUN=false

usage() {
  cat <<'EOF'
用法：
  ./scripts/deploy.sh [选项]

选项：
  --host HOST        SSH 主机，默认 vibecoding.wanghuanlab.com
  --user USER        SSH 用户，默认 root
  --port PORT        SSH 端口，默认 22
  --remote-dir DIR   站点目录，默认 /opt/1panel/www/sites/vibecoding.wanghuanlab.com/index
  --owner USER:GROUP 远端文件属主，默认 1panel:1panel
  --health-url URL   部署后健康检查地址，默认 https://vibecoding.wanghuanlab.com/
  --keep-backups N   保留几份历史备份，默认 3
  --dry-run          只本地打包校验并打印流程，不连接服务器
  -h, --help         显示帮助
EOF
}

while (($# > 0)); do
  case "$1" in
    --host) SSH_HOST="${2:?--host 需要参数}"; shift 2 ;;
    --user) SSH_USER="${2:?--user 需要参数}"; shift 2 ;;
    --port) SSH_PORT="${2:?--port 需要参数}"; shift 2 ;;
    --remote-dir) REMOTE_INDEX_DIR="${2:?--remote-dir 需要参数}"; shift 2 ;;
    --owner) REMOTE_OWNER="${2:?--owner 需要参数}"; shift 2 ;;
    --health-url) HEALTH_URL="${2:?--health-url 需要参数}"; shift 2 ;;
    --keep-backups) KEEP_BACKUPS="${2:?--keep-backups 需要参数}"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数：$1" >&2; usage >&2; exit 2 ;;
  esac
done

cd "$PROJECT_ROOT"

if [[ ! -f "$PROJECT_ROOT/index.html" ]]; then
  echo "错误：未在 $PROJECT_ROOT 找到 index.html" >&2
  exit 1
fi

LOCAL_SHA="$(shasum -a 256 "$PROJECT_ROOT/index.html" | awk '{print $1}')"
FILE_COUNT="$(find "$PROJECT_ROOT/index.html" "$PROJECT_ROOT/docs" "$PROJECT_ROOT/assets" -type f | wc -l | tr -d ' ')"

echo ">>> [准备阶段] 本地代码校验"
echo "  - 项目根目录:   $PROJECT_ROOT"
echo "  - index.html SHA256: $LOCAL_SHA"
echo "  - 待发布文件总数:    $FILE_COUNT 个"

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo ">>> [Dry-Run] 模拟演练模式开启"
  echo "  - 目标主机: $SSH_USER@$SSH_HOST:$SSH_PORT"
  echo "  - 目标路径: $REMOTE_INDEX_DIR"
  echo "  - 属主权限: $REMOTE_OWNER"
  echo "  - 备份策略: 保留最近 $KEEP_BACKUPS 份"
  echo "  - 健康检查: $HEALTH_URL"
  echo "Dry-Run 完成，未向服务器推送任何改动。"
  exit 0
fi

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
PID="$$"
UPLOAD_NAME="index.upload-${TIMESTAMP}-${PID}"
BACKUP_NAME="index.backup-${TIMESTAMP}"

echo ""
echo ">>> [发布阶段] 建立 SSH 连接并上传静态站点"
echo "  - 目标主机: $SSH_USER@$SSH_HOST:$SSH_PORT"
echo "  - 目标目录: $REMOTE_INDEX_DIR"

# 本地打包需要上传的静态资源
TAR_STREAM="$(tar -czf - \
  --exclude='.DS_Store' \
  --exclude='.git' \
  --exclude='.claude' \
  --exclude='.playwright-cli' \
  --exclude='scripts' \
  --exclude='README.md' \
  --exclude='package.json' \
  index.html docs assets "${PROJECT_ROOT}/404.html" 2>/dev/null || tar -czf - index.html docs assets)"

# 在远端执行安全原子部署脚本
ssh -o BatchMode=yes -o ConnectTimeout=10 -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" \
  bash -s -- "$REMOTE_SITE_DIR" "$UPLOAD_NAME" "$BACKUP_NAME" "$LOCAL_SHA" "$REMOTE_OWNER" "$KEEP_BACKUPS" <<'EOF'
set -Eeuo pipefail

SITE_DIR="$1"
UPLOAD_NAME="$2"
BACKUP_NAME="$3"
EXPECTED_SHA="$4"
TARGET_OWNER="$5"
KEEP_BACKUPS="$6"

INDEX_DIR="$SITE_DIR/index"
UPLOAD_DIR="$SITE_DIR/$UPLOAD_NAME"
BACKUP_DIR="$SITE_DIR/$BACKUP_NAME"

mkdir -p "$SITE_DIR"
rm -rf "$UPLOAD_DIR"
mkdir -p "$UPLOAD_DIR"

# 解压传入的 tar 流
tar -xzf - -C "$UPLOAD_DIR"

# 如果原 index 存在 panorama 图片且暂存目录没有，同步补充
if [[ -f "$INDEX_DIR/vibecoding-panorama.png" && ! -f "$UPLOAD_DIR/vibecoding-panorama.png" ]]; then
  cp "$INDEX_DIR/vibecoding-panorama.png" "$UPLOAD_DIR/vibecoding-panorama.png" 2>/dev/null || true
fi

# 校验 SHA256
ACTUAL_SHA="$(sha256sum "$UPLOAD_DIR/index.html" 2>/dev/null | awk '{print $1}' || shasum -a 256 "$UPLOAD_DIR/index.html" | awk '{print $1}')"
if [[ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]]; then
  echo "错误：远端 index.html SHA256 ($ACTUAL_SHA) 与本地 ($EXPECTED_SHA) 不匹配！" >&2
  rm -rf "$UPLOAD_DIR"
  exit 3
fi
echo "  ✓ 远端文件完整性校验通过 (SHA256 一致)"

# 设置属主与权限
chown -R "$TARGET_OWNER" "$UPLOAD_DIR" 2>/dev/null || true
find "$UPLOAD_DIR" -type d -exec chmod 755 {} + 2>/dev/null || true
find "$UPLOAD_DIR" -type f -exec chmod 644 {} + 2>/dev/null || true

# 原子替换：备份当前版本，将暂存目录换为 index
ROLLBACK_NEEDED=false
trap '
  if [[ "$ROLLBACK_NEEDED" == true ]]; then
    echo "警告：部署中途发生异常，正在紧急回滚..." >&2
    if [[ -d "$BACKUP_DIR" ]]; then
      rm -rf "$INDEX_DIR"
      mv "$BACKUP_DIR" "$INDEX_DIR"
      echo "已回滚至原版本 $BACKUP_DIR" >&2
    fi
  fi
' ERR

if [[ -d "$INDEX_DIR" ]]; then
  mv "$INDEX_DIR" "$BACKUP_DIR"
  ROLLBACK_NEEDED=true
fi

mv "$UPLOAD_DIR" "$INDEX_DIR"
ROLLBACK_NEEDED=false

echo "  ✓ 原子替换成功，旧版本已备份为: $BACKUP_NAME"

# 轮转历史备份：仅保留最近 KEEP_BACKUPS 份
cd "$SITE_DIR"
OLD_BACKUPS=$(ls -1dt index.backup-* 2>/dev/null | tail -n +"$((KEEP_BACKUPS + 1))" || true)
if [[ -n "$OLD_BACKUPS" ]]; then
  echo "$OLD_BACKUPS" | while read -r old; do
    echo "  - 清理陈旧备份: $old"
    rm -rf "$old"
  done
fi
EOF <<< "$TAR_STREAM"

echo ""
echo ">>> [验收阶段] 在线全链路健康检查"
HTTP_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 10 "$HEALTH_URL" || echo "000")
DOCS_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 10 "$DOCS_URL" || echo "000")

echo "  - 首页检查: $HEALTH_URL => HTTP $HTTP_STATUS"
echo "  - 文章目录: $DOCS_URL => HTTP $DOCS_STATUS"

if [[ "$HTTP_STATUS" == "200" && "$DOCS_STATUS" == "200" ]]; then
  echo ""
  echo "========================================================"
  echo " ✓ 部署成功！线上状态正常 (HTTP 200)"
  echo " 线上地址: $HEALTH_URL"
  echo " 部署版本: $LOCAL_SHA"
  echo "========================================================"
else
  echo ""
  echo "========================================================"
  echo " ! 部署完成但线上健康检查异常 (首页: $HTTP_STATUS, 文档: $DOCS_STATUS)"
  echo " 请检查 Nginx 或证书配置"
  echo "========================================================"
  exit 4
fi
