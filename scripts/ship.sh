#!/usr/bin/env bash
#
# 一体化发布脚本：代码审查与规范提交 + Git 推送 + 生产服务器 SSH 智能部署
#
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMIT_MSG=""
SKIP_GIT=false
SKIP_DEPLOY=false
INSPECT_ONLY=false
DRY_RUN=false

usage() {
  cat <<'HELP'
用法：
  ./scripts/ship.sh [选项]

选项：
  -m, --message MSG   Git 提交信息（若工作区有改动时使用）
  --skip-git          跳过 Git 提交与推送，仅执行部署
  --skip-deploy       跳过服务器部署，仅执行 Git 提交与推送
  --inspect-only      仅探测服务器老版本与运行状态，不执行发布
  --dry-run           只进行模拟演练，不修改远端服务器
  -h, --help          显示帮助
HELP
}

while (($# > 0)); do
  case "$1" in
    -m|--message) COMMIT_MSG="${2:?--message 需要参数}"; shift 2 ;;
    --skip-git) SKIP_GIT=true; shift ;;
    --skip-deploy) SKIP_DEPLOY=true; shift ;;
    --inspect-only) INSPECT_ONLY=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知选项：$1" >&2; usage >&2; exit 2 ;;
  esac
done

cd "$PROJECT_ROOT"

echo "========================================================"
echo " VibeCoding 站点发布流水线"
echo " 时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================================"

if [[ "$INSPECT_ONLY" == true ]]; then
  "$PROJECT_ROOT/scripts/inspect-server.sh"
  echo "探测完成（--inspect-only），退出。"
  exit 0
fi

# 步骤 0: 自动更新全站呈现日期
if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo ">>> [步骤 0/4] 模拟检查全站展示日期"
else
  echo ""
  echo ">>> [步骤 0/4] 自动更新全站呈现日期"
  "$PROJECT_ROOT/scripts/update-dates.sh"
fi

# 步骤 1: Git 提交与推送
if [[ "$SKIP_GIT" == true ]]; then
  echo ""
  echo ">>> [步骤 1/4] 跳过 Git 提交与推送 (--skip-git)"
else
  echo ""
  echo ">>> [步骤 1/4] 检查并执行 Git 提交与推送"
  
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "  工作区发现未提交改动："
    git status -s

    if [[ "$DRY_RUN" == true ]]; then
      echo "  [Dry-Run] 模拟执行: git add . && git commit -m '${COMMIT_MSG:-chore(release): update site content}'"
    else
      if [[ -z "$COMMIT_MSG" ]]; then
        # 智能分析改动
        CHANGED_DOCS=$(git status -s | grep -E 'docs/.*\.html' | awk '{print $2}' || true)
        if [[ -n "$CHANGED_DOCS" ]]; then
          COMMIT_MSG="feat(docs): update article content and reading catalog"
        else
          COMMIT_MSG="chore(release): update site content and assets $(date +%Y-%m-%d)"
        fi
      fi
      echo "  执行规范提交: $COMMIT_MSG"
      git add .
      git commit -m "$COMMIT_MSG"
    fi
  else
    echo "  工作区干净，无需提交。"
  fi

  # 检查是否有未推送的提交
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  
  if [[ -n "$UPSTREAM" ]]; then
    AHEAD_COMMITS="$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)"
  else
    AHEAD_COMMITS="1"
  fi

  if [[ "$AHEAD_COMMITS" -gt 0 || -z "$UPSTREAM" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "  [Dry-Run] 模拟执行: git push origin $CURRENT_BRANCH"
    else
      echo "  正在安全推送至远端分支 origin/$CURRENT_BRANCH ..."
      git push origin "$CURRENT_BRANCH"
      echo "  ✓ Git 推送完成"
    fi
  else
    echo "  本地分支与远端已同步，无需推送。"
  fi
fi

# 步骤 2: 部署前环境探测
echo ""
echo ">>> [步骤 2/4] 探测服务器老版本现状"
if [[ "$DRY_RUN" == true ]]; then
  echo "  [Dry-Run] 跳过实际探测"
else
  "$PROJECT_ROOT/scripts/inspect-server.sh"
fi

# 步骤 3: 生产部署
if [[ "$SKIP_DEPLOY" == true ]]; then
  echo ""
  echo ">>> [步骤 3/4] 跳过服务器部署 (--skip-deploy)"
else
  echo ""
  echo ">>> [步骤 3/4] 执行生产服务器原子更新部署"
  if [[ "$DRY_RUN" == true ]]; then
    "$PROJECT_ROOT/scripts/deploy.sh" --dry-run
  else
    "$PROJECT_ROOT/scripts/deploy.sh"
  fi
fi

echo ""
echo "========================================================"
echo " ✓ 全流程执行完毕！"
echo "========================================================"
