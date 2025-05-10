# Build stage
FROM maven:3.8.4-openjdk-17-slim AS builder

# Set working directory
WORKDIR /build

# Copy project files and payment JAR
COPY pom.xml .
COPY libs/payment-0.0.1-SNAPSHOT.jar /build/libs/

# Create Maven local repository directory
RUN mkdir -p /root/.m2/repository

# Install payment JAR with specific parameters
RUN mvn install:install-file \
    -Dfile=/build/libs/payment-0.0.1-SNAPSHOT.jar \
    -DgroupId=com.example \
    -DartifactId=payment \
    -Dversion=0.0.1-SNAPSHOT \
    -Dpackaging=jar \
    -DgeneratePom=true \
    -DlocalRepositoryPath=/root/.m2/repository

# Now we can safely run dependency:go-offline
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build the application with optimized settings
RUN mvn clean package \
    -DskipTests \
    -Dmaven.test.skip=true \
    -Dmaven.compiler.fork=true \
    -Dmaven.compiler.threads=4

# Run stage
FROM openjdk:17-slim

# Set working directory
WORKDIR /app

# Copy built application
COPY --from=builder /build/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Set JVM options for better performance
ENV JAVA_OPTS="-Xms512m -Xmx512m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Run the application with JVM options
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]