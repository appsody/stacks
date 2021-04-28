wget -nv https://repo1.maven.org/maven2/org/osgi/org.osgi.core/6.0.0/org.osgi.core-6.0.0.jar
javac -cp .:org.osgi.core-6.0.0.jar incubator/java-openliberty/image/project/util/RangeIncludesVersion.java
javac -cp .:org.osgi.core-6.0.0.jar incubator/java-microprofile/image/project/util/RangeIncludesVersion.java
javac -cp .:org.osgi.core-6.0.0.jar incubator/java-spring-boot2/image/project/util/RangeIncludesVersion.java
javac -cp .:org.osgi.core-6.0.0.jar experimental/java-spring-boot2-liberty/image/project/util/RangeIncludesVersion.java
