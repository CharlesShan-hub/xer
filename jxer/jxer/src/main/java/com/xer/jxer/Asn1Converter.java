package com.xer.jxer;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import javax.xml.bind.DatatypeConverter;

/**
 * MMS BER <-> APER codec wrapper
 *
 * Automatically detects OS (Windows/Linux) and loads the appropriate
 * native binary from classpath resources.
 *
 * Expected JAR structure:
 *   /native/win32/origin.exe   (Windows)
 *   /native/linux/origin.bin  (Linux)
 */
public class Asn1Converter {

    private static Path nativePath;
    private static String asnDir;

    /**
     * Initialize converter with ASN.1 runtime directory.
     *
     * @param asnDir  directory containing mms_rt.py
     */
    public static void init(String asnDir) {
        Asn1Converter.asnDir = asnDir;
        try {
            nativePath = extractNative();
        } catch (IOException e) {
            throw new RuntimeException("Failed to extract native binary from JAR", e);
        }
    }

    /**
     * Detect OS and extract the appropriate binary from classpath.
     */
    private static Path extractNative() throws IOException {
        String osName = System.getProperty("os.name", "").toLowerCase();
        String resourcePath;
        String suffix;

        if (osName.contains("win")) {
            resourcePath = "/native/win32/origin.exe";
            suffix = ".exe";
        } else if (osName.contains("linux")) {
            resourcePath = "/native/linux/origin.bin";
            suffix = "";
        } else {
            throw new IOException("Unsupported OS: " + osName + " (supported: Windows, Linux)");
        }

        InputStream is = Asn1Converter.class.getResourceAsStream(resourcePath);
        if (is == null) {
            throw new IOException("Native binary not found in classpath: " + resourcePath);
        }

        // Extract to temp file
        Path tempNative = Files.createTempFile("origin", suffix);
        tempNative.toFile().deleteOnExit();

        // Set executable permission (effective on Linux; no-op on Windows)
        tempNative.toFile().setExecutable(true, false);

        try (OutputStream os = Files.newOutputStream(tempNative)) {
            byte[] buffer = new byte[8192];
            int len;
            while ((len = is.read(buffer)) != -1) {
                os.write(buffer, 0, len);
            }
        }
        is.close();

        return tempNative;
    }

    /**
     * Convert BER to APER.
     *
     * @param ber  BER encoded data as byte array
     * @return     APER encoded data as byte array
     * @throws IOException on error
     */
    public static byte[] berToAper(byte[] ber) throws IOException {
        String hex = DatatypeConverter.printHexBinary(ber);
        String aperHex = berToAper(hex);
        return DatatypeConverter.parseHexBinary(aperHex);
    }

    /**
     * Convert APER to BER.
     *
     * @param aper  APER encoded data as byte array
     * @return      BER encoded data as byte array
     * @throws IOException on error
     */
    public static byte[] aperToBer(byte[] aper) throws IOException {
        String hex = DatatypeConverter.printHexBinary(aper);
        String berHex = aperToBer(hex);
        return DatatypeConverter.parseHexBinary(berHex);
    }

    /**
     * Convert BER hex to APER hex.
     *
     * @param berHex  BER encoded data as hex string
     * @return        APER encoded data as hex string
     * @throws IOException on error
     */
    public static String berToAper(String berHex) throws IOException {
        checkInit();
        return exec("--ber-to-aper", berHex);
    }

    /**
     * Convert APER hex to BER hex.
     *
     * @param aperHex  APER encoded data as hex string
     * @return         BER encoded data as hex string
     * @throws IOException on error
     */
    public static String aperToBer(String aperHex) throws IOException {
        checkInit();
        return exec("--aper-to-ber", aperHex);
    }

    private static void checkInit() {
        if (asnDir == null) {
            throw new IllegalStateException(
                "Asn1Converter not initialized. Call Asn1Converter.init(asnDir) first.");
        }
    }

    private static String exec(String mode, String hexData) throws IOException {
        // Build runtime module path
        Path rtPath = Paths.get(asnDir, "mms_rt.py");

        ProcessBuilder pb = new ProcessBuilder(
            nativePath.toString(),
            mode, hexData,
            "--rt", rtPath.toString()
        );
        pb.environment().put("PYTHONPATH", asnDir);
        pb.redirectErrorStream(true);

        Process p = pb.start();

        StringBuilder output = new StringBuilder();
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(p.getInputStream()))) {
            String line;
            while ((line = br.readLine()) != null) {
                // Skip compilation messages, keep only hex output
                if (!line.startsWith("[") && !line.startsWith("---")) {
                    output.append(line.trim());
                }
            }
        }

        try {
            int exitCode = p.waitFor();
            if (exitCode != 0) {
                throw new IOException("origin exited with code: " + exitCode);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IOException("Interrupted", e);
        }

        return output.toString();
    }
}
