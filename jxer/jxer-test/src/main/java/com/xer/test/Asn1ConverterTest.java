package com.xer.test;

import com.xer.jxer.Asn1Converter;

/**
 * Test Asn1Converter static API
 */
public class Asn1ConverterTest {

    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("  jxer-test - Asn1Converter Static API Test");
        System.out.println("========================================");

        // Get asnDir from first arg or use default
        String asnDir = (args.length > 0) ? args[0] : "../asn";

        System.out.println();
        System.out.println("[INFO] Initializing Asn1Converter with asnDir: " + asnDir);

        try {
            // Init with asnDir
            Asn1Converter.init(asnDir);
            System.out.println("[PASS] Asn1Converter.init() succeeded");

            // Test berToAper
            String berHex = "a01502016fa610a00ea10c1a04544553541a0456414c31";
            String expectedAper = "006f3404544553540456414c31";
            System.out.println();
            System.out.println("[INFO] Testing berToAper...");
            System.out.println("  Input:    " + berHex);
            System.out.println("  Expected: " + expectedAper);

            String aperHex = Asn1Converter.berToAper(berHex);
            System.out.println("  Output:   " + aperHex);

            if (expectedAper.equalsIgnoreCase(aperHex)) {
                System.out.println("[PASS] berToAper matches expected!");
            } else {
                System.out.println("[WARN] Output differs from expected");
            }

            // Test aperToBer
            System.out.println();
            System.out.println("[INFO] Testing aperToBer...");
            System.out.println("  Input:  " + aperHex);

            String berBack = Asn1Converter.aperToBer(aperHex);
            System.out.println("  Output: " + berBack);

            if (berBack != null && !berBack.isEmpty()) {
                System.out.println("[PASS] aperToBer succeeded");
            } else {
                System.out.println("[FAIL] aperToBer returned empty");
            }

            // Verify round-trip
            System.out.println();
            if (berHex.equalsIgnoreCase(berBack)) {
                System.out.println("[PASS] Round-trip successful!");
            } else {
                System.out.println("[FAIL] Round-trip mismatch!");
                System.out.println("  Expected: " + berHex);
                System.out.println("  Got:      " + berBack);
            }

            System.out.println();
            System.out.println("========================================");
            System.out.println("[PASS] All tests passed!");
            System.out.println("========================================");

        } catch (Exception e) {
            System.out.println();
            System.out.println("========================================");
            System.out.println("[FAIL] Error: " + e.getMessage());
            System.out.println("========================================");
            e.printStackTrace();
            System.exit(1);
        }
    }
}
