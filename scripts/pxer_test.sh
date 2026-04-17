#!/usr/bin/env bash
#===============================================================================
# pxer_test.sh - 测试 xer Python 模块
#
# 功能：
#   运行 test.py 测试 BER <-> APER 编解码功能
#
# 使用：
#   bash scripts/pxer_test.sh
#===============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# MSYS2 配置
MSYS2_ROOT="${MSYS2_ROOT:-/d/program/msys64}"
MSYS2_UCRT="${MSYS2_ROOT}/UCRT64"
PYTHON_BIN="${MSYS2_UCRT}/bin/python.exe"

# 设置 Python 环境变量
export PYTHONHOME="${MSYS2_UCRT}"
export PYTHONPATH="${SCRIPT_DIR}/../pxer:${MSYS2_UCRT}/lib/python3.14:${MSYS2_UCRT}/lib/python3.14/site-packages"
export PATH="${MSYS2_UCRT}/bin:${MSYS2_ROOT}/usr/bin:${PATH}"

# 路径配置
PXER_DIR="${SCRIPT_DIR}/../pxer"
ASN_DIR="${SCRIPT_DIR}/../asn"
ASN_FILE="${ASN_DIR}/mms.asn"
RT_FILE="${ASN_DIR}/mms_rt.py"

# 检查 ASN 文件
if [[ ! -f "${ASN_FILE}" ]]; then
    log_error "ASN 文件不存在: ${ASN_FILE}"
    exit 1
fi

# 运行测试
log_info "运行 xer 测试..."
echo ""

"${PYTHON_BIN}" "${PXER_DIR}/test.py" "${ASN_FILE}" -o "${RT_FILE}"
