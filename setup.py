from setuptools import setup
from Cython.Build import cythonize

setup(
    name="xer",
    version="0.1.0",
    packages=["src.xer"],
    ext_modules=cythonize("src/xer/__init__.pyx", language_level=3),
)
