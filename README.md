# xer - MMS BER ↔ APER 转换工具集

## 1. 项目结构

```
xer/
├── asn/                          # ASN.1 定义文件（外部输入，可替换）
│   └── mms.asn
├── pxer/                         # Python 源码
│   ├── origin.py                 # BER ↔ APER 核心
│   ├── main.py                   # CLI 入口
│   └── pyproject.toml
├── cxer/                         # 编译后的原生二进制
│   ├── windows/origin.exe        # Windows 版（MSVC + Nuitka）
│   └── linux/origin.bin          # Linux 版（GCC + Nuitka + Docker）
├── jxer/                         # Java 封装库
│   ├── jxer/                     # 库模块（pom.xml + Asn1Converter.java）
│   └── jxer-test/                # 测试模块
├── docker/                       # Linux Docker 构建环境
└── scripts/                      # 构建脚本
```

## 2. 构建脚本结构

```
scripts/
├── build.ps1                    # 一键构建（全平台）
├── build-win.ps1                # Windows exe（5 步）
│   ├── windows-pxer-env.ps1
│   ├── windows-pxer-test.ps1
│   ├── windows-cxer-env.ps1
│   ├── windows-cxer-build.ps1
│   └── windows-cxer-test.ps1
├── build-linux.ps1              # Linux bin（3 步）
│   ├── linux-docker-pxer-env.ps1
│   ├── linux-docker-cxer-build.ps1
│   └── linux-docker-cxer-test.ps1
└── build-jar.ps1                # JAR 打包（3 步）
    ├── jar-env.ps1
    ├── jar-build.ps1
    └── jar-test.ps1
```

## 3. 快速开始

```powershell
# 一键全量构建（Developer Command Prompt for VS 2022）
cd D:\project\work\standard\xer
.\scripts\build.ps1
```

输出：
- `cxer/windows/origin.exe`
- `cxer/linux/origin.bin`
- `jxer/jxer/target/jxer-1.0.0.jar`（包含两个平台的二进制）

单独构建：
```powershell
.\scripts\build-win.ps1      # Windows exe
.\scripts\build-linux.ps1     # Linux bin（需 Docker）
.\scripts\build-jar.ps1       # JAR 打包
```

安装到本地 Maven：
```powershell
cd jxer\jxer; mvn install
```

## 4. 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| Python | 3.12 | uv 虚拟环境用 |
| Java | 8+ | 运行 Java 应用 |
| Maven | 3.x | 构建项目 |
| MSVC | VS 2022 | 构建 Windows exe（可选） |
| Docker | Desktop | 构建 Linux bin（可选） |

## 5. Java 使用示例

```java
// 初始化（指定 asn 目录）
Asn1Converter.init("D:/path/to/asn");

// BER -> APER
String aper = Asn1Converter.berToAper("a01502016fa610...");

// APER -> BER
String ber = Asn1Converter.aperToBer("006f340454...");
```

运行时 Asn1Converter 自动检测操作系统，加载对应二进制。

## 6. 更新日志

### v1.1.0 (2026-04-20)
- 支持 Linux Docker 交叉编译（`origin.bin`，ELF 格式）
- 分离 cxer 输出目录：`cxer/windows/` 和 `cxer/linux/`
- Asn1Converter 自动识别系统加载对应二进制
- jxer 支持 `byte[]` 输入/输出（简化与 TConnection 的集成）
- 重构构建脚本体系：`build.ps1` 一键全量构建，下属三层独立（build-win / build-linux / build-jar）

### v1.0.0 (2026-04-17)
- 初始版本
- 支持 BER ↔ APER 转换
- origin.exe 打包进 JAR
- 静态 API 设计（Asn1Converter）
