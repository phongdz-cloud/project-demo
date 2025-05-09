# Build stage
FROM maven:3.8.4-openjdk-17 AS builder

# Set working directory
WORKDIR /build

# Copy payment JAR and project files
COPY libs/payment-*.jar /build/libs/
COPY pom.xml .
COPY src ./src

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

# Build the application
RUN mvn clean package -DskipTests

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

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]