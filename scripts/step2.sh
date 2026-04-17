#!/usr/bin/env bash
# step2: Python 测试

set -e
cd "$(dirname "$0")/.."

echo "=== Step 2: Python 测试 ==="
uv run python main.py asn/mms.asn -o mms_rt.py
echo ""
echo "Done."
