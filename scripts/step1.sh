#!/usr/bin/env bash
# step1: 初始化项目（uv init 已完成，此脚本仅作备忘）

set -e
cd "$(dirname "$0")/.."

echo "=== Step 1: 确认依赖已安装 ==="
uv sync
echo "Done."
