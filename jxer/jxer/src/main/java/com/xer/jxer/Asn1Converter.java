package com.xer.jxer;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * MMS BER <-> APER codec wrapper
 *
 * Loads origin.exe from classpath resources,
 * expects asnDir to be provided at runtime.
 */
public class Asn1Converter {

    private static Path exePath;
    private static String asnDir;

    /**
     * Initialize converter with ASN.1 runtime directory.
     *
     * @param asnDir  directory containing mms_rt.py
     */
    public static void init(String asnDir) {
        Asn1Converter.asnDir = asnDir;
        try {
            exePath = extractExe();
        } catch (IOException e) {
            throw new RuntimeException("Failed to extract origin.exe from JAR", e);
        }
    }

    /**
     * Extract origin.exe from classpath to temp directory.
     */
    private static Path extractExe() throws IOException {
        // Try to extract from JAR resources
        String resourcePath = "/origin.exe";
        InputStream is = Asn1Converter.class.getResourceAsStream(resourcePath);

        if (is == null) {
            throw new IOException("origin.exe not found in classpath: " + resourcePath);
        }

        // Extract to temp file
        Path tempExe = Files.createTempFile("origin", ".exe");
        tempExe.toFile().deleteOnExit();

        try (OutputStream os = Files.newOutputStream(tempExe)) {
            byte[] buffer = new byte[8192];
            int len;
            while ((len = is.read(buffer)) != -1) {
                os.write(buffer, 0, len);
            }
        }
        is.close();

        return tempExe;
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
            exePath.toString(),
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
                throw new IOException("origin.exe exited with code: " + exitCode);
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new IOException("Interrupted", e);
        }

        return output.toString();
    }
}
