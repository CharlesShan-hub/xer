#!/usr/bin/env bash
#===============================================================================
# pxer_env.sh - Python 环境检测与配置脚本
# 用于 xer 项目的 Python 环境准备
#
# 功能：
#   1. 检测 MSYS2 UCRT64 Python 是否存在
#   2. 如果不存在，提示安装 MSYS2
#   3. 验证 Python 版本（精确到补丁版本）
#   4. 安装所需 Python 包（pycrate）
#
# 使用：
#   bash scripts/pxer_env.sh
#===============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# MSYS2 配置
MSYS2_ROOT="${MSYS2_ROOT:-/d/program/msys64}"
MSYS2_UCRT="${MSYS2_ROOT}/UCRT64"
PYTHON_BIN="${MSYS2_UCRT}/bin/python.exe"

# 设置 Python 环境变量（MSYS2 bash 里 sys.path 可能不完整）
export PYTHONHOME="${MSYS2_UCRT}"
export PYTHONPATH="${MSYS2_UCRT}/lib/python3.14:${MSYS2_UCRT}/lib/python3.14/site-packages"
export PATH="${MSYS2_UCRT}/bin:${MSYS2_ROOT}/usr/bin:${PATH}"

# requirements.txt 路径
REQUIREMENTS_FILE="${SCRIPT_DIR}/../pxer/requirements.txt"

# 从 requirements.txt 读取包列表
REQUIRED_PACKAGES=()
read_requirements() {
    if [[ -f "${REQUIREMENTS_FILE}" ]]; then
        while IFS= read -r line; do
            # 跳过空行和注释
            [[ -z "${line}" || "${line}" =~ ^# ]] && continue
            # 移除版本号，只要包名
            pkg=$(echo "${line}" | sed 's/[[:space:]]*[[:space:]]*#.*//' | xargs)
            [[ -n "${pkg}" ]] && REQUIRED_PACKAGES+=("${pkg}")
        done < "${REQUIREMENTS_FILE}"
        log_info "从 requirements.txt 加载了 ${#REQUIRED_PACKAGES[@]} 个包"
    else
        log_error "requirements.txt 未找到: ${REQUIREMENTS_FILE}"
        return 1
    fi
}

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 MSYS2 是否存在
check_msys2() {
    log_info "检查 MSYS2 安装..."

    if [[ ! -d "${MSYS2_ROOT}" ]]; then
        log_error "MSYS2 未安装！"
        echo ""
        echo "请先安装 MSYS2："
        echo "  1. 下载 MSYS2: https://www.msys2.org/"
        echo "  2. 安装到 C:/msys64 或 D:/program/msys64"
        echo "  3. 打开 MSYS2 UCRT64 终端，运行："
        echo "     pacman -Syu"
        echo "     pacman -S mingw-w64-ucrt-x86_64-python mingw-w64-ucrt-x86_64-gcc"
        return 1
    fi

    log_info "MSYS2 目录存在: ${MSYS2_ROOT}"
}

# 检查 Python 是否存在
check_python() {
    log_info "检查 Python 安装..."

    if [[ ! -f "${PYTHON_BIN}" ]]; then
        log_error "Python 未安装！"
        echo ""
        echo "请在 MSYS2 UCRT64 终端中运行："
        echo "  pacman -S mingw-w64-ucrt-x86_64-python"
        return 1
    fi

    log_info "Python 可执行文件存在: ${PYTHON_BIN}"
}

# 获取精确的 Python 版本（关键修复：之前是 3.14 导致路径错误）
get_python_version() {
    log_info "获取 Python 版本..."

    # 方法1：从 VERSION.txt 读取（如 3.14.2）
    # 先找到 python lib 目录
    PYTHON_LIB_DIR=$(ls -d "${MSYS2_UCRT}/lib"/python3.* 2>/dev/null | head -1 || echo "")
    if [[ -n "${PYTHON_LIB_DIR}" ]]; then
        PYTHON_VER_FILE="${PYTHON_LIB_DIR}/VERSION.txt"
        if [[ -f "${PYTHON_VER_FILE}" ]]; then
            PYTHON_VERSION=$(cat "${PYTHON_VER_FILE}" | head -1 | tr -d '\r\n')
            log_info "从 VERSION.txt 获取版本: ${PYTHON_VERSION}"
        fi
    fi

    if [[ -z "${PYTHON_VERSION}" ]]; then
        # 方法2：运行 python --version
        # 注意：使用 MSYS2 的 python（不是 uv）
        PYTHON_VERSION=$("${PYTHON_BIN}" --version 2>&1 | awk '{print $2}')
        log_info "从 --version 获取版本: ${PYTHON_VERSION}"
    fi

    # 验证版本格式
    if [[ ! "${PYTHON_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "无法解析 Python 版本，尝试备用方法..."
        # 备用：从 python.exe 的路径推断
        if [[ -f "${PYTHON_BIN}" ]]; then
            # 尝试从 lib 目录查找
            LIB_PYTHON_DIR=$(ls -d "${MSYS2_UCRT}/lib"/python3.* 2>/dev/null | head -1)
            if [[ -n "${LIB_PYTHON_DIR}" ]]; then
                PYTHON_VERSION=$(basename "${LIB_PYTHON_DIR}" | sed 's/python//')
                log_info "从目录名推断版本: ${PYTHON_VERSION}"
            fi
        fi
    fi

    log_info "Python 版本: ${PYTHON_VERSION}"

    # 提取主版本号（用于路径）
    PYTHON_MAJOR_MINOR=$(echo "${PYTHON_VERSION}" | cut -d. -f1,2)
    log_info "Python 主版本（用于路径）: ${PYTHON_MAJOR_MINOR}"

    # 检查版本是否有效
    if [[ ! "${PYTHON_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "无法确定 Python 版本！"
        return 1
    fi
}

# 检查 Python 包是否已安装
check_package() {
    local pkg=$1
    log_info "检查 ${pkg}..."

    # 使用 pip show 检查包是否安装（避免 sys.path 问题）
    local pip_bin="${MSYS2_UCRT}/bin/pip.exe"
    if "${pip_bin}" show "${pkg}" >/dev/null 2>&1; then
        local version=$("${pip_bin}" show "${pkg}" 2>/dev/null | grep "^Version:" | awk '{print $2}')
        log_info "  ${pkg} 已安装 (version: ${version})"
        return 0
    else
        log_warn "  ${pkg} 未安装"
        return 1
    fi
}

# 安装 Python 包
install_package() {
    local pkg=$1
    log_info "安装 ${pkg}..."

    # 使用 --break-system-packages 绕过 externally-managed-environment 限制
    if "${MSYS2_UCRT}/bin/pip.exe" install --no-input --break-system-packages "${pkg}"; then
        log_info "  ${pkg} 安装成功"
    else
        log_error "  ${pkg} 安装失败"
        return 1
    fi
}

# 主流程
main() {
    echo "========================================"
    echo "  xer 项目 - Python 环境检测"
    echo "========================================"
    echo ""

    # 1. 检查 MSYS2
    check_msys2 || exit 1

    # 2. 检查 Python
    check_python || exit 1

    # 3. 获取精确版本
    get_python_version

    # 4. 读取 requirements.txt
    echo ""
    log_info "读取依赖列表..."
    read_requirements || exit 1

    # 5. 检查并安装所需包
    echo ""
    log_info "检查所需 Python 包..."
    echo ""

    ALL_INSTALLED=true
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if ! check_package "${pkg}"; then
            ALL_INSTALLED=false
            break
        fi
    done

    if [[ "${ALL_INSTALLED}" == "false" ]]; then
        echo ""
        log_warn "部分包未安装，正在安装..."
        for pkg in "${REQUIRED_PACKAGES[@]}"; do
            if ! check_package "${pkg}"; then
                install_package "${pkg}" || {
                    log_error "安装 ${pkg} 失败"
                    exit 1
                }
            fi
        done
    fi

    # 6. 验证安装
    echo ""
    log_info "最终验证..."
    echo ""

    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        check_package "${pkg}" || {
            log_error "${pkg} 验证失败"
            exit 1
        }
    done

    echo ""
    echo "========================================"
    log_info "Python 环境准备完成！"
    echo "========================================"
    echo ""
    echo "Python 路径: ${PYTHON_BIN}"
    echo "Python 版本: ${PYTHON_VERSION}"
    echo "MSYS2 路径:  ${MSYS2_UCRT}"
    echo ""
}

# 运行
main "$@"
