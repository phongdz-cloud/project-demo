# Build stage
FROM maven:3.8.4-openjdk-17 AS builder

# Set working directory
WORKDIR /build

# Copy payment JAR
COPY libs/payment-*.jar /build/libs/

# Debug: List contents of libs directory
RUN ls -la libs/

# Debug: Check JAR file contents
RUN jar tf libs/payment-0.0.1-SNAPSHOT.jar

# Copy pom.xml and source code
COPY pom.xml .
COPY src ./src

# Create Maven local repository directory
RUN mkdir -p /root/.m2/repository

# Install payment JAR to local Maven repository
RUN mvn install:install-file \
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

# Build the application with debug logging
RUN mvn clean package -DskipTests -X -e

# Run stage
FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Copy payment JAR from builder
COPY --from=builder /build/libs/payment-*.jar /app/libs/

# Copy built JAR from builder
COPY --from=builder /build/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]