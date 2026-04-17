# xer - MMS BER ↔ APER 转换工具集

## 1. 项目概述

xer 是一个用于 MMS 协议 ASN.1 编解码的工具集，核心功能是 **BER ↔ APER 格式转换**。

### 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        用户（Java）                          │
│                   Asn1Converter.berToAper()                  │
└─────────────────────────┬───────────────────────────────────┘
                          │ Maven Dependency
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     jxer (JAR)                              │
│  ┌─────────────────┐    ┌─────────────────────────────────┐ │
│  │ Asn1Converter   │───▶│ origin.exe                      │ │
│  │ (Java 封装)     │    │ (Python + pycrate, 打包在JAR里) │ │
│  └─────────────────┘    └─────────────────────────────────┘ │
└─────────────────────────┬───────────────────────────────────┘
                          │ PYTHONPATH + asnDir
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                     asn/ 目录（外部输入，可替换）             │
│  ┌─────────────┐    ┌─────────────────────────────────────┐ │
│  │ mms.asn     │    │ mms_rt.py                          │ │
│  │ (ASN.1定义) │    │ (pycrate 生成的运行时模块)            │ │
│  └─────────────┘    └─────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 技术选型对比

| 方案 | 语言 | 依赖 | 复杂度 | 可维护性 |
|------|------|------|--------|----------|
| **jxer（本项目）** | Java + Python exe | 仅 Java | 低 | ⭐⭐⭐⭐⭐ |
| asn1c + JNI | C + Java | Java + C编译器 | 高 | ⭐⭐ |
| pycrate (Python) | Python | Python + pycrate | 中 | ⭐⭐⭐ |

**jxer 优势：** 用户只需 Java 环境，exe 打包在 JAR 里，无需配置 Python。

## 2. 模块说明

```
xer/
├── asn/                     # ASN.1 运行时（外部输入，可替换）
│   ├── mms.asn              # ASN.1 定义文件
│   └── mms_rt.py            # pycrate 生成的运行时模块
│
├── scripts/                 # 构建脚本
│   ├── jxer_env.ps1        # 检查 Java/Maven 环境
│   ├── jxer_build.ps1      # 构建 jxer JAR
│   └── jxer_test.ps1       # 运行测试
│
├── pxer/                    # origin.py 源码（Python 版本）
│   ├── origin.py            # 主程序
│   ├── main.py              # 入口
│   ├── mms_rt.py            # 运行时（复制到 asn/ 使用）
│   └── pyproject.toml       # 项目配置
│
├── cxer/                    # origin.exe 源码（C 版本，编译后打包到 jxer）
│   ├── origin.dist/         # 编译产物
│   │   └── origin.exe       # 可执行文件
│   └── origin.build/        # 编译中间文件
│
├── jxer/                    # Java 封装库
│   ├── jxer/               # 库模块
│   │   ├── src/main/java/  Asn1Converter.java
│   │   ├── src/main/resources/ origin.exe
│   │   └── pom.xml
│   └── jxer-test/          # 测试模块
│       └── pom.xml         # dependency: com.xer:jxer
│
└── README.md               # 本文档
```

## 3. 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| Java | 8+ | 运行 Java 应用 |
| Maven | 3.x | 构建项目 |

### 仅构建时需要

| 组件 | 版本 | 说明 |
|------|------|------|
| Python | 3.x | 编译 origin.exe（已编译好则不需要） |
| pycrate | 最新 | ASN.1 运行时（已生成 mms_rt.py 则不需要） |

**最终用户只需 Java 环境！**

## 4. 工作流程

### 4.1 检查环境

```powershell
cd xer/scripts
.\jxer_env.ps1
```

**输出示例：**
```
========================================
  xer - Java/Maven Environment Check
========================================

[INFO] Checking Java...
[PASS] Java found: openjdk version "1.8.0_482"
[INFO] Checking Maven...
[PASS] Maven found: Apache Maven 3.9.11

========================================
[PASS] All checks passed!
========================================
```

### 4.2 构建 jxer 库

```powershell
.\jxer_build.ps1
```

**执行步骤：**
1. 检查 Java/Maven 环境
2. 复制 `cxer/origin.exe` → `jxer/jxer/src/main/resources/`
3. `mvn clean install` — 打包 + 安装到本地 Maven 仓库

**输出示例：**
```
========================================
  xer - Build jxer JAR
========================================

[INFO] Copying origin.exe to resources...
[PASS] Copied origin.exe
[INFO] Building jxer...
[PASS] Build + Install successful!

JAR: jxer\jxer\target\jxer-1.0.0.jar
Installed to local Maven repository

========================================
[PASS] Done!
========================================
```

### 4.3 运行测试

```powershell
.\jxer_test.ps1 [asnDir]
```

- **可选参数：** `asnDir` — ASN.1 运行时目录
- **默认值：** `../asn`（即 `xer/asn/`）

**输出示例：**
```
========================================
  xer - Build & Run Asn1Converter Test
========================================

[INFO] Using asnDir: D:\project\work\standard\xer\asn
[INFO] Building jxer-test...
[PASS] Build successful
[INFO] Running Asn1ConverterTest...
========================================
  jxer-test - Asn1Converter Static API Test
========================================

[INFO] Initializing Asn1Converter with asnDir: D:\project\work\standard\xer\asn
[PASS] Asn1Converter.init() succeeded

[INFO] Testing berToAper...
  Input:    a01502016fa610a00ea10c1a04544553541a0456414c31
  Expected: 006f3404544553540456414c31
  Output:   006f3404544553540456414c31
[PASS] berToAper matches expected!

[INFO] Testing aperToBer...
  Input:  006f3404544553540456414c31
  Output: a01502016fa610a00ea10c1a04544553541a0456414c31
[PASS] aperToBer succeeded

[PASS] Round-trip successful!

========================================
[PASS] All tests passed!
========================================
```

## 5. 在其他项目中使用 jxer

### 5.1 添加 Maven 依赖

```xml
<dependency>
    <groupId>com.xer</groupId>
    <artifactId>jxer</artifactId>
    <version>1.0.0</version>
</dependency>
```

### 5.2 Java 代码示例

```java
import com.xer.jxer.Asn1Converter;

public class MyApp {
    public static void main(String[] args) {
        // 初始化（需要 mms_rt.py 所在的目录）
        Asn1Converter.init("D:/path/to/asn");

        // BER → APER
        String aperHex = Asn1Converter.berToAper(
            "a01502016fa610a00ea10c1a04544553541a0456414c31"
        );
        System.out.println("APER: " + aperHex);
        // 输出: 006f3404544553540456414c31

        // APER → BER
        String berHex = Asn1Converter.aperToBer(
            "006f3404544553540456414c31"
        );
        System.out.println("BER: " + berHex);
        // 输出: a01502016fa610a00ea10c1a04544553541a0456414c31
    }
}
```

### 5.3 依赖说明

| 文件 | 来源 | 说明 |
|------|------|------|
| `origin.exe` | 打包在 jxer JAR 中 | 无需手动管理 |
| `mms_rt.py` | asn/ 目录（用户提供） | ASN.1 运行时，必须存在 |
| `mms.asn` | asn/ 目录（用户提供） | ASN.1 定义文件（origin.exe 内部使用） |

> **注意：** `asn/` 目录是外部输入，可以替换为其他 ASN.1 模块，只需确保 `mms.asn` 和 `mms_rt.py` 存在于指定目录。

## 6. API 参考

### Asn1Converter

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `init(asnDir)` | `String` - mms_rt.py 所在目录 | `void` | 初始化，必须先调用 |
| `berToAper(hex)` | `String` - BER hex | `String` - APER hex | BER 转 APER |
| `aperToBer(hex)` | `String` - APER hex | `String` - BER hex | APER 转 BER |

### 异常处理

```java
try {
    Asn1Converter.init("/path/to/asn");
    String aper = Asn1Converter.berToAper(berHex);
} catch (IllegalStateException e) {
    // 未调用 init()
} catch (IOException e) {
    // origin.exe 执行失败
}
```

## 7. 测试数据

| 测试 | 输入 | 预期输出 | 状态 |
|------|------|----------|------|
| BER → APER | `a01502016fa610a00ea10c1a04544553541a0456414c31` | `006f3404544553540456414c31` | ✅ |
| APER → BER | `006f3404544553540456414c31` | `a01502016fa610a00ea10c1a04544553541a0456414c31` | ✅ |
| 往返测试 | `a015...` → APER → BER | `a015...` | ✅ |

## 8. 更新日志

### v1.0.0 (2026-04-17)
- 初始版本
- 支持 BER ↔ APER 转换
- origin.exe 打包进 JAR
- 静态 API 设计（Asn1Converter）
