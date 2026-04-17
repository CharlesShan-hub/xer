#!/usr/bin/env bash
# step3: Cython 编译 + wheel（使用 MSYS2 原生 Python + GCC）
# 注意还是用的原生python
#  pacman -Ss mingw-w64-ucrt-x86_64-python
set -e
cd "$(dirname "$0")/.."

# 1. 清理旧构建产物 + 卸载旧 xer
rm -rf dist/ build/ src/xer/__init__.c src/xer/__init__.pyd src/xer/__init__.pyx xer.egg-info/
pip uninstall xer -y 2>/dev/null || true

# 2. 复制源文件
cp origin.py src/xer/__init__.pyx

# 3. 安装编译依赖
pip install --break-system-packages cython setuptools build

# 4. Cython 生成 C 文件
python -c 'from Cython.Build import cythonize; cythonize("src/xer/__init__.pyx", language_level=3, output_dir="src/xer")'

# 5. 打包 wheel
python -m build --wheel --no-isolation

# 6. 安装新 wheel
pip install --force-reinstall --break-system-packages dist/xer-*.whl

# 7. 验证安装
python -c "import xer; print('xer OK:', xer.__file__)"
