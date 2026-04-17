/*
 * test_xer.c - 测试 xer 扩展（C 调用 Python 字节串接口）
 *
 * 编译: gcc -o test_xer test_xer.c
 *       -I/ucrt64/include/python3.14 -I/ucrt64/include/python3.14/cpython
 *       -L/ucrt64/lib -lpython3.14 -lz
 *
 * 运行: ./test_xer ../asn/mms.asn
 */

#define PY_SSIZE_T_CLEAN
#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <stdio.h>
#include <stdlib.h>
#ifdef MS_WIN32
#include <windows.h>
#endif

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <asn_file>\n", argv[0]);
        return 1;
    }

    const char *asn_file = argv[1];

    /* 设置 DLL 搜索路径（MinGW Python 需要） */
    #ifdef MS_WIN32
    {
        HMODULE hPython = GetModuleHandle("python3.14");
        if (hPython) {
            BOOL (WINAPI *Py_AddLibrary)(LPCWSTR) = 
                (void *)GetProcAddress(hPython, "PyWin_AddLibrary");
            if (Py_AddLibrary) {
                Py_AddLibrary(L"ucrtbase");
                Py_AddLibrary(L"libz");
                Py_AddLibrary(L"libgcc_s_seh-1");
                Py_AddLibrary(L"libstdc++-6");
            }
        }
    }
    #endif

    /* 初始化 Python 解释器 */
    Py_Initialize();
    if (!Py_IsInitialized()) {
        fprintf(stderr, "Python init failed\n");
        return 1;
    }

    /* 添加 site-packages 路径（xer 安装位置） */
    PyObject *sysPath = PySys_GetObject("path");
    PyObject *sitePkg = PyUnicode_FromString("D:/program/msys64/ucrt64/lib/python3.14/site-packages");
    PyList_Insert(sysPath, 0, sitePkg);
    Py_DECREF(sitePkg);

    /* 备用: 当前目录 */
    PyObject *curDir = PyUnicode_FromString(".");
    PyList_Insert(sysPath, 0, curDir);
    Py_DECREF(curDir);

    /* 导入 xer 模块 */
    PyObject *xer_mod = PyImport_ImportModule("xer");
    if (!xer_mod) {
        fprintf(stderr, "Import xer failed\n");
        PyErr_Print();
        Py_Finalize();
        return 1;
    }
    printf("xer module loaded OK\n");

    /* 获取 xer.init 函数 */
    PyObject *init_fn = PyObject_GetAttrString(xer_mod, "init");
    if (!init_fn || !PyCallable_Check(init_fn)) {
        fprintf(stderr, "xer.init not callable\n");
        Py_XDECREF(init_fn);
        Py_DECREF(xer_mod);
        Py_Finalize();
        return 1;
    }

    /* 调用 xer.init(asn_file, "mms_rt.py") */
    PyObject *rt_file = PyUnicode_FromString("mms_rt.py");
    PyObject *init_args = PyTuple_Pack(2,
        PyUnicode_FromString(asn_file), rt_file);
    Py_DECREF(rt_file);

    PyObject *init_result = PyObject_CallObject(init_fn, init_args);
    Py_DECREF(init_args);
    Py_DECREF(init_fn);

    if (!init_result) {
        fprintf(stderr, "xer.init() failed\n");
        PyErr_Print();
        Py_DECREF(xer_mod);
        Py_Finalize();
        return 1;
    }
    printf("xer.init() OK: asn=%s\n", asn_file);
    Py_DECREF(init_result);

    /* 调用 example1() 设置测试数据 */
    PyObject *example1_fn = PyObject_GetAttrString(xer_mod, "example1");
    if (!example1_fn || !PyCallable_Check(example1_fn)) {
        fprintf(stderr, "xer.example1 not callable\n");
        Py_XDECREF(example1_fn);
        Py_DECREF(xer_mod);
        Py_Finalize();
        return 1;
    }
    PyObject *example1_result = PyObject_CallObject(example1_fn, NULL);
    Py_DECREF(example1_fn);
    if (!example1_result) {
        fprintf(stderr, "xer.example1() failed\n");
        PyErr_Print();
        Py_DECREF(xer_mod);
        Py_Finalize();
        return 1;
    }
    Py_DECREF(example1_result);
    printf("example1() OK\n");

    /* 获取 BER 和 APER 测试数据 */
    PyObject *get_ber_fn = PyObject_GetAttrString(xer_mod, "get_ber");
    PyObject *get_aper_fn = PyObject_GetAttrString(xer_mod, "get_aper");
    PyObject *ber_to_aper_fn = PyObject_GetAttrString(xer_mod, "ber_to_aper");
    PyObject *aper_to_ber_fn = PyObject_GetAttrString(xer_mod, "aper_to_ber");
    if (!get_ber_fn || !get_aper_fn || !ber_to_aper_fn || !aper_to_ber_fn) {
        fprintf(stderr, "xer helper functions not found\n");
        Py_DECREF(xer_mod);
        Py_Finalize();
        return 1;
    }

    /* 获取原始 BER */
    PyObject *ber_result = PyObject_CallObject(get_ber_fn, NULL);
    if (!ber_result) {
        fprintf(stderr, "xer.get_ber() failed\n");
        PyErr_Print();
        Py_DECREF(xer_mod);
        Py_Finalize();
        return 1;
    }
    char *ber_data;
    Py_ssize_t ber_len;
    PyBytes_AsStringAndSize(ber_result, &ber_data, &ber_len);
    printf("BER data (%d bytes): ", (int)ber_len);
    for (Py_ssize_t i = 0; i < ber_len; i++)
        printf("%02x ", (unsigned char)ber_data[i]);
    printf("\n");

    /* 测试 ber_to_aper */
    printf("Testing ber_to_aper()...\n");
    PyObject *aper_from_ber = PyObject_CallFunctionObjArgs(ber_to_aper_fn, ber_result, NULL);
    if (!aper_from_ber) {
        fprintf(stderr, "xer.ber_to_aper() failed\n");
        PyErr_Print();
        Py_DECREF(ber_result);
        Py_DECREF(xer_mod);
        Py_Finalize();
        return 1;
    }
    char *aper_data;
    Py_ssize_t aper_len;
    PyBytes_AsStringAndSize(aper_from_ber, &aper_data, &aper_len);
    printf("APER result (%d bytes): ", (int)aper_len);
    for (Py_ssize_t i = 0; i < aper_len; i++)
        printf("%02x ", (unsigned char)aper_data[i]);
    printf("\n");

    /* 测试 aper_to_ber */
    printf("Testing aper_to_ber()...\n");
    PyObject *ber_from_aper = PyObject_CallFunctionObjArgs(aper_to_ber_fn, aper_from_ber, NULL);
    if (!ber_from_aper) {
        fprintf(stderr, "xer.aper_to_ber() failed\n");
        PyErr_Print();
        Py_DECREF(aper_from_ber);
        Py_DECREF(ber_result);
        Py_DECREF(xer_mod);
        Py_Finalize();
        return 1;
    }
    char *ber_data2;
    Py_ssize_t ber_len2;
    PyBytes_AsStringAndSize(ber_from_aper, &ber_data2, &ber_len2);
    printf("BER result (%d bytes): ", (int)ber_len2);
    for (Py_ssize_t i = 0; i < ber_len2; i++)
        printf("%02x ", (unsigned char)ber_data2[i]);
    printf("\n");

    /* 验证一致性 */
    if (ber_len == ber_len2 && memcmp(ber_data, ber_data2, ber_len) == 0) {
        printf("SUCCESS: ber_to_aper -> aper_to_ber roundtrip matches!\n");
    } else {
        printf("MISMATCH: Original and roundtrip BER differ\n");
    }

    /* 清理 */
    Py_DECREF(ber_from_aper);
    Py_DECREF(aper_from_ber);
    Py_DECREF(ber_result);
    Py_DECREF(xer_mod);
    Py_Finalize();

    printf("All done.\n");
    return 0;
}
