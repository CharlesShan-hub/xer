# jxer - MMS ASN.1 编解码库

## 1. 功能概述

jxer 是一个轻量级的 Java 库，封装了 MMS 协议的 BER ↔ APER 编解码功能。

**核心能力：**
- `Asn1Converter.berToAper(hex)` — BER hex → APER hex
- `Asn1Converter.aperToBer(hex)` — APER hex → BER hex

**技术实现：**
- 将 `origin.exe`（Python + pycrate）打包进 JAR
- 运行时释放 exe 到临时目录，通过进程调用
- 用户只需 Java 环境，无需安装 Python

## 2. 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| Java | 8+ | 运行 Java 应用 |
| Maven | 3.x | 构建项目 |

**无需安装：**
- Python
- asn1c
- pycrate

## 3. 工作流程

### 3.1 检查环境

```powershell
.\jxer_env.ps1
```

验证 Java 和 Maven 是否可用。

### 3.2 构建 jxer 库

```powershell
.\jxer_build.ps1
```

执行步骤：
1. 复制 `cxer/origin.exe` 到 `jxer/src/main/resources/`
2. `mvn clean install` — 打包并安装到本地 Maven 仓库

### 3.3 运行测试

```powershell
.\jxer_test.ps1 [asnDir]
```

- 可选参数：`asnDir` — ASN.1 运行时目录（默认：`../asn`）
- 构建 jxer-test 项目并运行测试

### 3.4 在其他项目中使用

```xml
<dependency>
    <groupId>com.xer</groupId>
    <artifactId>jxer</artifactId>
    <version>1.0.0</version>
</dependency>
```

```java
// 初始化（需要 mms_rt.py）
Asn1Converter.init("D:/path/to/asn");

// BER → APER
String aperHex = Asn1Converter.berToAper("a01502016fa610...");

// APER → BER
String berHex = Asn1Converter.aperToBer("006f34045445...");
```

## 4. 项目结构

```
jxer/
├── jxer/                    # 库模块
│   ├── src/main/java/       Asn1Converter.java
│   ├── src/main/resources/  origin.exe
│   └── pom.xml
│
└── jxer-test/               # 测试模块
    └── pom.xml              # dependency: com.xer:jxer:1.0.0
```

## 5. 测试数据

| 方向 | 输入 | 输出 |
|------|------|------|
| BER → APER | `a01502016fa610a00ea10c1a04544553541a0456414c31` | `006f3404544553540456414c31` |
| APER → BER | `006f3404544553540456414c31` | `a01502016fa610a00ea10c1a04544553541a0456414c31` |
