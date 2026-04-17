#!/usr/bin/env bash
# test_run.sh - 编译测试程序 + 运行
# 用法: ./test_run.sh [asn_file]
# 默认 asn_file: ../asn/mms.asn
# 注意: xer 需先通过 ../scripts/step3.sh 安装

set -e

cd "$(dirname "$0")"

ASN_FILE="${1:-../asn/mms.asn}"

echo "=== 复制 zlib1.dll ==="
cp /ucrt64/bin/zlib1.dll .

echo "=== 编译 test_xer ==="
gcc -o test_xer test_xer.c \
    -I/ucrt64/include/python3.14 \
    -I/ucrt64/include/python3.14/cpython \
    -L/ucrt64/lib \
    -lpython3.14 \
    -lz

echo "=== 运行测试 ($ASN_FILE) ==="
export PATH="/ucrt64/bin:/mingw64/bin:/usr/bin:$PATH"
./test_xer "$ASN_FILE"
