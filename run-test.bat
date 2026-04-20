cd D:/project/work/standard/xer/jxer/jxer-test
mvn compile -q
java -cp "target/classes;../jxer/target/jxer-1.0.0.jar" com.xer.test.Asn1ConverterTest "D:/project/work/standard/xer/asn"
