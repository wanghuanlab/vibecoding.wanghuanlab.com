#!/usr/bin/env bash
#
# 自动更新全站呈现的年月日期为当前系统时间
# 格式 1: YYYY.MM (例如 2026.09)
# 格式 2: YYYY年M月 (例如 2026年9月)
#
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CURRENT_YEAR="$(date +%Y)"
CURRENT_MONTH_PAD="$(date +%m)"
CURRENT_MONTH_NUM="$(date +%-m 2>/dev/null || date +%m | sed 's/^0//')"

TARGET_DOT="${CURRENT_YEAR}.${CURRENT_MONTH_PAD}"
TARGET_CN="${CURRENT_YEAR}年${CURRENT_MONTH_NUM}月"

echo ">>> [日期同步] 检查并更新全站展示日期"
echo "  - 当前年月: $TARGET_DOT / $TARGET_CN"

UPDATED=false

# 1. 更新 index.html 中的 "Let's start vibe coding · YYYY.MM"
if grep -q -E "Let's start vibe coding · [0-9]{4}\.[0-9]{2}" "$PROJECT_ROOT/index.html"; then
  OLD_DOT="$(grep -o -E "Let's start vibe coding · [0-9]{4}\.[0-9]{2}" "$PROJECT_ROOT/index.html" | head -n 1)"
  if [[ "$OLD_DOT" != "Let's start vibe coding · $TARGET_DOT" ]]; then
    sed -i '' -E "s/Let's start vibe coding · [0-9]{4}\.[0-9]{2}/Let's start vibe coding · $TARGET_DOT/g" "$PROJECT_ROOT/index.html" 2>/dev/null || \
    sed -i -E "s/Let's start vibe coding · [0-9]{4}\.[0-9]{2}/Let's start vibe coding · $TARGET_DOT/g" "$PROJECT_ROOT/index.html"
    echo "  ✓ index.html: 更新标题副标 => Let's start vibe coding · $TARGET_DOT"
    UPDATED=true
  fi
fi

# 2. 更新 index.html 中的 "YYYY年M月" (培训时间)
if grep -q -E 'font-weight: 600;">[0-9]{4}年[0-9]{1,2}月<' "$PROJECT_ROOT/index.html"; then
  OLD_CN="$(grep -o -E 'font-weight: 600;">[0-9]{4}年[0-9]{1,2}月<' "$PROJECT_ROOT/index.html" | head -n 1)"
  if [[ "$OLD_CN" != "font-weight: 600;\">$TARGET_CN<" ]]; then
    sed -i '' -E "s/font-weight: 600;\">[0-9]{4}年[0-9]{1,2}月</font-weight: 600;\">$TARGET_CN</g" "$PROJECT_ROOT/index.html" 2>/dev/null || \
    sed -i -E "s/font-weight: 600;\">[0-9]{4}年[0-9]{1,2}月</font-weight: 600;\">$TARGET_CN</g" "$PROJECT_ROOT/index.html"
    echo "  ✓ index.html: 更新培训时间 => $TARGET_CN"
    UPDATED=true
  fi
fi

# 3. 更新 docs/index.html 中的 "READING ROOM · YYYY.MM"
if grep -q -E "READING ROOM · [0-9]{4}\.[0-9]{2}" "$PROJECT_ROOT/docs/index.html"; then
  OLD_DOC_DOT="$(grep -o -E "READING ROOM · [0-9]{4}\.[0-9]{2}" "$PROJECT_ROOT/docs/index.html" | head -n 1)"
  if [[ "$OLD_DOC_DOT" != "READING ROOM · $TARGET_DOT" ]]; then
    sed -i '' -E "s/READING ROOM · [0-9]{4}\.[0-9]{2}/READING ROOM · $TARGET_DOT/g" "$PROJECT_ROOT/docs/index.html" 2>/dev/null || \
    sed -i -E "s/READING ROOM · [0-9]{4}\.[0-9]{2}/READING ROOM · $TARGET_DOT/g" "$PROJECT_ROOT/docs/index.html"
    echo "  ✓ docs/index.html: 更新阅读室日期 => READING ROOM · $TARGET_DOT"
    UPDATED=true
  fi
fi

if [[ "$UPDATED" == false ]]; then
  echo "  - 所有文件日期已是最新 ($TARGET_DOT / $TARGET_CN)，无需调整。"
fi
