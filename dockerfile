# Build stage
FROM maven:3.8.4-openjdk-17 AS builder

# Set working directory
WORKDIR /build

# Copy payment JAR and project files
COPY libs/payment-*.jar /build/libs/
COPY pom.xml .
COPY src ./src

# Debug: List contents of libs directory
RUN ls -la libs/

# Debug: Check JAR file contents
RUN jar tf libs/payment-0.0.1-SNAPSHOT.jar

# Create Maven local repository directory and install payment JAR
RUN mkdir -p /root/.m2/repository && \
    mvn install:install-file \
    -Dfile=libs/payment-0.0.1-SNAPSHOT.jar \
    -DgroupId=com.example \
    -DartifactId=payment \
    -Dversion=0.0.1-SNAPSHOT \
    -Dpackaging=jar \
    -DgeneratePom=true \
    -DlocalRepositoryPath=/root/.m2/repository \
    -DcreateChecksum=true

# Debug: Check if JAR was installed correctly
RUN ls -la /root/.m2/repository/com/example/payment/0.0.1-SNAPSHOT/

# Debug: Check Maven settings
RUN cat /root/.m2/settings.xml || echo "No settings.xml found"

# Debug: Check project structure
RUN ls -la /build
RUN ls -la /build/src/main/java/com/example/project/

# Build the application with debug logging
RUN mvn clean package -DskipTests -X -e -Dmaven.test.skip=true -Dmaven.compiler.failOnError=false

# Run stage
FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Copy payment JAR and built application
COPY --from=builder /build/libs/payment-*.jar /app/libs/
COPY --from=builder /build/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Set JVM options for better performance
ENV JAVA_OPTS="-Xms512m -Xmx512m -XX:+UseG1GC"

# Run the application with JVM options
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]