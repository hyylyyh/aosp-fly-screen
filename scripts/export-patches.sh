#!/bin/bash
# 一键导出飞屏项目的 AOSP 修改 patch
# 用法：cd /path/to/aosp && bash /path/to/aosp-fly-screen/scripts/export-patches.sh

AOSP_ROOT=${1:-$(pwd)}
PATCH_DIR="$(dirname $0)/../patches"
REPOS_FILE="$(dirname $0)/../repos.txt"

echo "AOSP 根目录: $AOSP_ROOT"
echo "Patch 输出目录: $PATCH_DIR"

mkdir -p "$PATCH_DIR"

# 清空 repos.txt
> "$REPOS_FILE"

cd "$AOSP_ROOT"

# 遍历所有 git 仓库
repo forall -c '
    if ! git diff --cached --quiet HEAD 2>/dev/null || ! git diff --quiet 2>/dev/null; then
        REPO_NAME=$(basename $REPO_PATH)
        echo "发现修改: $REPO_PATH"
        echo "$REPO_PATH" >> '"$REPOS_FILE"'
        
        # 导出所有未提交的修改
        git add -A
        git diff HEAD > '"$PATCH_DIR"'/$(echo $REPO_PATH | tr / _).diff
        echo "  → 已导出 patch"
    fi
'

echo ""
echo "导出完成！"
echo "Patch 文件: $PATCH_DIR"
echo "仓库清单: $REPOS_FILE"
