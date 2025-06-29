
# Build stage
FROM docker.io/library/maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src/ ./src/
RUN mvn package -DskipTests

# Runtime stage
FROM docker.io/library/eclipse-temurin:21-jre-jammy

# Install required libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends libaio1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create app directory and user
WORKDIR /app
RUN mkdir -p /app/wallet

# Copy application first
COPY --from=build /app/target/*.jar app.jar

# Copy wallet files and set proper ownership/permissions BEFORE switching user
COPY src/main/resources/wallet/* /app/wallet/

# Set proper ownership and permissions for wallet files
RUN chown -R 1001:0 /app && \
    chmod -R 644 /app/wallet/* && \
    chmod 755 /app/wallet && \
    chmod 644 /app/app.jar && \
    ls -la /app/wallet/

# Environment variables
ENV TNS_ADMIN=/app/wallet
ENV ORACLE_WALLET_LOCATION=/app/wallet

# Switch to non-root user AFTER setting permissions
USER 1001

# Runtime configuration
EXPOSE 8081
CMD ["java", "-Doracle.net.tns_admin=/app/wallet", "-Doracle.net.ssl_server_dn_match=yes", "-Doracle.net.ssl_version=1.2", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
