#!/usr/bin/env python3
"""
pycrate ASN.1 Compiler Tool
For IEC 61850 MMS protocol (DL/T 8211)

Usage:
    python main.py asn/mms.asn -o mms_rt.py
"""

import argparse
import sys
import origin as xer

def example1():
    """Example 1: Construct a Read-Request PDU with test data"""
    xer.req.set_val((
        'confirmed-RequestPDU',
        {
            'invokeID': 123,
            'service': (
                'read',
                {
                    'variableAccessSpecification': (
                        'listOfVariable',
                        [{
                            'variableSpecification': (
                                'name',
                                ('domain-specific', {'domainID': 'TEST', 'itemID': 'VAL1'})
                            )
                        }]
                    )
                }
            )
        }
    ))

def example2():
    """Example 2: GetVariableAccessAttributes request"""
    xer.req.set_val((
        'confirmed-RequestPDU',
        {
            'invokeID': 111,
            'service': (
                'getVariableAccessAttributes',
                ('name', ('domain-specific', {'domainID': 'TEST', 'itemID': 'VAL1'}))
            )
        }
    ))


def encode_aper() -> bytes:
    """Encode PDU to APER format"""
    return xer.req.to_aper()


def encode_ber() -> bytes:
    """Encode PDU to BER format"""
    return xer.req.to_ber()


def verify_aper_to_ber(aper_data: bytes, ber_data: bytes) -> bool:
    """
    Verify APER to BER conversion using xer library
    """
    xer.req.from_ber(ber_data)
    print("BER decode result:")
    print(xer.req.to_asn1())
    xer.req.from_ber(xer.aper_to_ber(aper_data))
    print("APER to BER and decode result:")
    print(xer.req.to_asn1())

def verify_ber_to_aper(ber_data: bytes, aper_data: bytes) -> bool:
    """
    Verify BER to APER conversion using xer library
    """
    xer.req.from_aper(aper_data)
    print("APER decode result:")
    print(xer.req.to_asn1())
    
    xer.req.from_aper(xer.ber_to_aper(ber_data))
    print("BER to APER and decode result:")
    print(xer.req.to_asn1())

def main():
    parser = argparse.ArgumentParser(description='MMS ASN.1 Compiler')
    parser.add_argument('asn_file', help='ASN.1 file path')
    parser.add_argument('-o', '--output', default='mms_rt.py',
                        help='Output Python file path (default: mms_rt.py)')
    args = parser.parse_args()

    # Step 1: Init xer package
    print("=== Step 1: Init xer package ===")
    xer.init(args.asn_file, args.output)

    # Step 1.1: Compile ASN.1
    print("=== Step 1.1: Compile ASN.1 ===")
    xer.compile_asn(args.asn_file)
    print("Compilation successful!")

    # Step 1.2: Generate Python Runtime Code
    print("\n=== Step 1.2: Generate Python Runtime Code ===")
    xer.generate_runtime(args.output)
    print(f"Generated file: {args.output}")

    # Step 1.3: Load Runtime Module
    print("\n=== Step 1.3: Load Runtime Module ===")
    xer.load_runtime_module(args.output)
    print(f"Module loaded: {args.output}")

    # Step 2: Construct Read-Request PDU
    print("\n=== Step 2: Construct Read-Request PDU ===")
    example1()
    print(f"Constructed PDU:\n{xer.req.to_asn1()}")

    # Step 3: Generate test data
    print("\n=== Step 3: Generate Test Data ===")
    aper_data = encode_aper()
    ber_data = encode_ber()
    
    print(f"APER data (hex): {aper_data.hex()}")
    print(f"APER length: {len(aper_data)} bytes")
    print(f"BER data (hex): {ber_data.hex()}")
    print(f"BER length: {len(ber_data)} bytes")

    # Step 4: Verify APER to BER conversion
    print("\n=== Step 4: Verify APER to BER Conversion ===")
    print("Using xer.aper_to_ber()...")
    verify_aper_to_ber(aper_data,ber_data)

    # Step 5: Verify BER to APER conversion
    print("\n=== Step 5: Verify BER to APER Conversion ===")
    print("Using xer.ber_to_aper()...")
    verify_ber_to_aper(ber_data,aper_data)

    # Step 6: Test Reuse req object
    example2()

    aper_data = encode_aper()
    ber_data = encode_ber()
    
    print(f"APER data (hex): {aper_data.hex()}")
    print(f"APER length: {len(aper_data)} bytes")
    print(f"BER data (hex): {ber_data.hex()}")
    print(f"BER length: {len(ber_data)} bytes")

    print("Using xer.aper_to_ber()...")
    verify_aper_to_ber(aper_data,ber_data)

    print("Using xer.ber_to_aper()...")
    verify_ber_to_aper(ber_data,aper_data)


    print("\n=== Done ===")


if __name__ == '__main__':
    main()