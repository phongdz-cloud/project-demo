# project/Dockerfile
FROM openjdk:17-jdk-slim

# Tạo thư mục cho ứng dụng
WORKDIR /app

# Copy JAR file của payment service
COPY libs/payment-*.jar /app/libs/

# Copy JAR file của project
COPY target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]