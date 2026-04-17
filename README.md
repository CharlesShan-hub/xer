# xer - MMS BER ↔ APER 转换工具集

## 1. 项目概述

### 1. 项目简介

xer 是一个用于 MMS 协议 ASN.1 编解码的工具集，核心功能是 **BER ↔ APER 格式转换**。

### 2.项目结构

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

### 3. 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| Java | 8+ | 运行 Java 应用 |
| Maven | 3.x | 构建项目 |

## 2. 工作流程

### 1.1 python部分：检查python环境

通过uv管理python，会自动安装需要的库。注意要用3.12，太新了不支持。

```powershell
PS D:\project\work\standard\xer\scripts> .\pxer_env.ps1
========================================
  xer - Python Environment Setup (uv)
========================================

[INFO] Checking uv...
[INFO] uv installed: uv 0.10.10 (8c730aaad 2026-03-13)
[INFO] Checking Python 3.12...
[INFO] Python 3.12 available
[INFO] Checking virtualenv...
[INFO] Virtualenv exists: D:\project\work\standard\xer\pxer\.venv
[INFO] Installing dependencies...
Resolved 6 packages in 1ms
Checked 5 packages in 0.43ms
[INFO] Dependencies installed

========================================
[INFO] Python environment ready!
========================================

Project dir : D:\project\work\standard\xer\pxer
Virtualenv  : D:\project\work\standard\xer\pxer\.venv
Python path :

Run test:
  cd D:\project\work\standard\xer\pxer
  .\.venv\Scripts\Activate.ps1
  python test.py
```

### 1.2 python部分：验证功能正确

需要指定asn1文件，核心代码就一行：`& $VenvPython test.py $AsnFile`

```powershell
PS D:\project\work\standard\xer\scripts> .\pxer_test.ps1
========================================
  xer - Run Test
========================================

[INFO] Running test.py with ASN file: D:\project\work\standard\xer\scripts\..\asn\mms.asn

=== Step 1: Init xer package ===
=== Step 1.1: Compile ASN.1 ===
[proc] [D:\project\work\standard\xer\scripts\..\asn\mms.asn] module ASN1 (oid: [1, 0, 9506, 2, 2]): 69 ASN.1 assignments found
--- compilation cycle ---
--- compilation cycle ---
--- verifications ---
[proc] ASN.1 modules processed: ['ASN1']
[proc] ASN.1 objects compiled: 68 types, 0 sets, 0 values
[proc] done
Compilation successful!

=== Step 1.2: Generate Python Runtime Code ===
Generated file: mms_rt.py

=== Step 1.3: Load Runtime Module ===
Module loaded: mms_rt.py

=== Step 2: Construct Read-Request PDU ===
Constructed PDU:
confirmed-RequestPDU : {
  invokeID 123,
  service read : {
    variableAccessSpecification listOfVariable : {
      {
        variableSpecification name : domain-specific : {
          domainID "TEST",
          itemID "VAL1"
        }
      }
    }
  }
}

=== Step 3: Generate Test Data ===
APER data (hex): 007b10012004544553540456414c31
APER length: 15 bytes
BER data (hex): a01b02017ba416a114a0123010a00ea10c1a04544553541a0456414c31
BER length: 29 bytes

=== Step 4: Verify APER to BER Conversion ===
Using xer.aper_to_ber()...
BER decode result:
confirmed-RequestPDU : {
  invokeID 123,
  service read : {
    variableAccessSpecification listOfVariable : {
      {
        variableSpecification name : domain-specific : {
          domainID "TEST",
          itemID "VAL1"
        }
      }
    }
  }
}
APER to BER and decode result:
confirmed-RequestPDU : {
  invokeID 123,
  service read : {
    specificationWithResult FALSE,
    variableAccessSpecification listOfVariable : {
      {
        variableSpecification name : domain-specific : {
          domainID "TEST",
          itemID "VAL1"
        }
      }
    }
  }
}

=== Step 5: Verify BER to APER Conversion ===
Using xer.ber_to_aper()...
APER decode result:
confirmed-RequestPDU : {
  invokeID 123,
  service read : {
    specificationWithResult FALSE,
    variableAccessSpecification listOfVariable : {
      {
        variableSpecification name : domain-specific : {
          domainID "TEST",
          itemID "VAL1"
        }
      }
    }
  }
}
BER to APER and decode result:
confirmed-RequestPDU : {
  invokeID 123,
  service read : {
    specificationWithResult FALSE,
    variableAccessSpecification listOfVariable : {
      {
        variableSpecification name : domain-specific : {
          domainID "TEST",
          itemID "VAL1"
        }
      }
    }
  }
}
APER data (hex): 006f3404544553540456414c31
APER length: 13 bytes
BER data (hex): a01502016fa610a00ea10c1a04544553541a0456414c31
BER length: 23 bytes
Using xer.aper_to_ber()...
BER decode result:
confirmed-RequestPDU : {
  invokeID 111,
  service getVariableAccessAttributes : name : domain-specific : {
    domainID "TEST",
    itemID "VAL1"
  }
}
APER to BER and decode result:
confirmed-RequestPDU : {
  invokeID 111,
  service getVariableAccessAttributes : name : domain-specific : {
    domainID "TEST",
    itemID "VAL1"
  }
}
Using xer.ber_to_aper()...
APER decode result:
confirmed-RequestPDU : {
  invokeID 111,
  service getVariableAccessAttributes : name : domain-specific : {
    domainID "TEST",
    itemID "VAL1"
  }
}
BER to APER and decode result:
confirmed-RequestPDU : {
  invokeID 111,
  service getVariableAccessAttributes : name : domain-specific : {
    domainID "TEST",
    itemID "VAL1"
  }
}

=== Done ===

========================================
[INFO] Test complete!
========================================
```

### 2.1 c部分：验证环境

使用了windows的c，而且必须要安装微软的那个VS才能构建。我用了msys32不行。另外需要去windows安全那里关掉App & browser control的Smart App Control

```powershell
PS D:\project\work\standard\xer\scripts> .\cxer_env.ps1
========================================
  xer - C Build Environment Check
========================================

[INFO] Checking Visual Studio Build Tools...
[PASS] Visual Studio found: C:\Program Files\Microsoft Visual Studio\18\Community
[INFO] Checking MSVC compiler...
[PASS] MSVC cl.exe found: C:\Program Files\Microsoft Visual Studio\18\Community\VC\Tools\MSVC\14.50.35717\bin\Hostx64\x64\cl.exe
[INFO]   Version:
Microsoft (R) C/C++ Optimizing Compiler Version 19.50.35729 for x64
Copyright (C) Microsoft Corporation.  All rights reserved.

                         C/C++ COMPILER OPTIONS

========================================
[PASS] All checks passed! C build environment is ready.
========================================
```

### 2.2 c部分：构建exe

```powershell
PS D:\project\work\standard\xer\scripts> .\cxer_build.ps1
========================================
  xer - Nuitka Build
========================================

[INFO] Checking files...
[INFO]   origin.py exists

[INFO] Running Nuitka...

Nuitka-Options: Used command line options:
Nuitka-Options:   --standalone --onefile --msvc=latest --include-package=pycrate_asn1rt
Nuitka-Options:   --include-data-dir=D:\project\work\standard\xer\scripts\..\asn=asn
Nuitka-Options:   --output-dir=D:\project\work\standard\xer\scripts\..\cxer D:\project\work\standard\xer\pxer\origin.py
Nuitka: Starting Python compilation with:
Nuitka:   Version '4.0.8' on Python 3.12 (flavor 'Unknown') commercial grade 'not installed'.
Nuitka-Onefile:WARNING: Onefile mode cannot compress without 'zstandard' package installed You probably should depend on
Nuitka-Onefile:WARNING: 'Nuitka[onefile]' rather than 'Nuitka' which among other things depends on it.
Nuitka: Completed Python level compilation and optimization.
Nuitka: Generating source code for C backend compiler.
Nuitka: Running data composer tool for optimal constant value handling.
Nuitka: Running C compilation via Scons.
Nuitka-Scons: MSVC version resolved to 14.5.
Nuitka-Scons: Backend C compiler: cl (cl 14.5).
Nuitka-Scons: Backend C linking with 40 files (no progress information available for this stage).
Nuitka-Scons: Compiled 40 C files using clcache with 40 cache hits and 0 cache misses.
Nuitka-Options: Included data file 'asn\mms.asn' due to specified data dir 'D:\project\work\standard\xer\asn' on command
Nuitka-Options: line.
Nuitka-Onefile: Creating single file from dist folder, this may take a while.
Nuitka-Onefile: Running bootstrap binary compilation via Scons.
Nuitka-Onefile:WARNING: Onefile mode cannot compress without 'zstandard' package installed You probably should depend on
Nuitka-Onefile:WARNING: 'Nuitka[onefile]' rather than 'Nuitka' which among other things depends on it.
Nuitka-Inclusion: Including Windows Runtime DLLs, which increases distribution size. Use
Nuitka-Inclusion: '--include-windows-runtime-dlls=no' to disable, or make explicit with
Nuitka-Inclusion: '--include-windows-runtime-dlls=yes'.
Nuitka-Scons: MSVC version resolved to 14.5.
Nuitka-Scons: Onefile C compiler: cl (cl 14.5).
Nuitka-Scons: Onefile C linking.
Nuitka-Scons: Compiled 1 C files using clcache with 1 cache hits and 0 cache misses.
Nuitka-Onefile: Keeping onefile build directory 'D:\project\work\standard\xer\cxer\origin.onefile-build'.
Nuitka: Keeping dist folder 'D:\project\work\standard\xer\cxer\origin.dist' for inspection, no need to use it.
Nuitka: Keeping build directory 'D:\project\work\standard\xer\cxer\origin.build'.
Nuitka: Successfully created 'D:\project\work\standard\xer\cxer\origin.exe'.

========================================
[INFO] Build complete!
========================================

Output dir: D:\project\work\standard\xer\scripts\..\cxer
```

### 2.3 c部分：验证功能正确

现在已经不用写c代码了，可以直接用shell命令就好了

```powershell
PS D:\project\work\standard\xer\scripts> .\cxer_test.ps1
========================================
  xer - Test BER <-> APER Conversion
========================================

[INFO] Exe   : D:\project\work\standard\xer\scripts\..\cxer\origin.exe
[INFO] ASN   : D:\project\work\standard\xer\scripts\..\asn\mms.asn

--- Test 1: BER -> APER ---
  Input (BER hex)   : a01502016fa610a00ea10c1a04544553541a0456414c31
  Expected (APER)  : 006f3404544553540456414c31
  Result (APER hex): 006f3404544553540456414c31
  [PASS]

--- Test 2: APER -> BER ---
  Input (APER hex) : 006f3404544553540456414c31
  Expected (BER)   : a01502016fa610a00ea10c1a04544553541a0456414c31
  Result (BER hex)  : a01502016fa610a00ea10c1a04544553541a0456414c31
  [PASS]

========================================
[INFO] Test complete!
========================================
```

### 3.1 java部分：检查环境

就是看看java和maven

```powershell
PS D:\project\work\standard\xer\scripts> .\jxer_env.ps1
========================================
  xer - Java/Maven Environment Check
========================================

[INFO] Checking Java...
[PASS] Java found: openjdk version "1.8.0_482"
[INFO] Checking Maven...
[PASS] Maven found: Apache Maven 3.9.11 (3e54c93a704957b63ee3494413a2b544fd3d825b)

========================================
[PASS] All checks passed!
========================================
```

### 3.2 java部分：打包工具包

这里会打包并上传到本地的maven仓库

```powershell
PS D:\project\work\standard\xer\scripts> .\jxer_build.ps1

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

### 3.3 java部分:使用

```powershell
PS D:\project\work\standard\xer\scripts> .\jxer_test.ps1

========================================
  xer - Build & Run Asn1Converter Test
========================================

[INFO] Using asnDir: D:\project\work\standard\xer\asn
[INFO] Building jxer-test...
[PASS] Build successful
[INFO] Running XerCodecTest...
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



## 8. 更新日志

### v1.0.0 (2026-04-17)
- 初始版本
- 支持 BER ↔ APER 转换
- origin.exe 打包进 JAR
- 静态 API 设计（Asn1Converter）
