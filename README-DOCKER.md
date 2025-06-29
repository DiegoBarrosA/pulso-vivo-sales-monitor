# RabbitMQ Price Monitor - Docker Deployment Guide

This guide provides instructions for running the RabbitMQ Price Monitor application using Docker and Docker Compose.

## 📋 Prerequisites

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher
- **Oracle Cloud Infrastructure (OCI) Wallet**: Downloaded and placed in the correct location
- **Java 21**: For local development (optional)
- **Maven**: For building the application (optional)

## 🏗️ Architecture Overview

The Docker setup includes:

- **Spring Boot Application**: Price monitoring service with Oracle database connectivity
- **RabbitMQ Primary**: Main message broker with management UI
- **RabbitMQ Secondary**: Clustered node for high availability
- **Persistent Volumes**: For RabbitMQ data persistence
- **Health Checks**: Automated service health monitoring

## 📁 Project Structure

```
rabbitmqavanzado/
├── src/main/resources/wallet/          # Oracle OCI wallet files
├── docker-compose.yml                 # Docker services configuration
├── Dockerfile                         # Application container definition
├── build-docker.sh                    # Build and deployment script
├── docker-manage.sh                   # Management utilities
└── README-DOCKER.md                   # This file
```

## 🚀 Quick Start

### 1. Prepare Oracle Wallet

Ensure your Oracle OCI wallet files are in the correct location:

```bash
ls -la src/main/resources/wallet/
```

Required files:
- `tnsnames.ora`
- `sqlnet.ora`
- `cwallet.sso`
- `ewallet.p12`
- `keystore.jks`
- `truststore.jks`

### 2. Build and Deploy

Use the automated build script:

```bash
./build-docker.sh
```

This script will:
- Clean previous builds
- Build the Spring Boot application
- Create Docker images
- Start all services
- Perform health checks

### 3. Verify Deployment

Check service status:

```bash
./docker-manage.sh status
```

Check health:

```bash
./docker-manage.sh health
```

## 🔧 Management Commands

Use the `docker-manage.sh` script for common operations:

### Basic Operations

```bash
# Start all services
./docker-manage.sh start

# Stop all services
./docker-manage.sh stop

# Restart all services
./docker-manage.sh restart

# Restart only the application
./docker-manage.sh restart-app
```

### Monitoring and Logs

```bash
# View all service logs
./docker-manage.sh logs

# View application logs only
./docker-manage.sh logs-app

# View RabbitMQ logs only
./docker-manage.sh logs-rabbitmq

# Monitor resource usage
./docker-manage.sh monitor
```

### Troubleshooting

```bash
# Check service health
./docker-manage.sh health

# Open shell in application container
./docker-manage.sh shell-app

# Open shell in RabbitMQ container
./docker-manage.sh shell-rabbitmq
```

### Maintenance

```bash
# Clean up all containers and volumes
./docker-manage.sh clean

# Rebuild everything from scratch
./docker-manage.sh rebuild

# Backup RabbitMQ data
./docker-manage.sh backup
```

## 🌐 Service URLs

Once deployed, the following services will be available:

| Service | URL | Credentials |
|---------|-----|-------------|
| **Spring Boot App** | http://localhost:8080 | - |
| **Health Check** | http://localhost:8080/actuator/health | - |
| **RabbitMQ Management** | http://localhost:15672 | guest/guest |
| **RabbitMQ Secondary** | http://localhost:15673 | guest/guest |

## 📡 API Endpoints

### Product Management

```bash
# List all products
GET http://localhost:8080/api/products

# Create a new product
POST http://localhost:8080/api/products
Content-Type: application/json
{
  "name": "Test Product",
  "description": "A test product",
  "price": 100.00,
  "quantity": 50,
  "category": "Electronics",
  "active": true
}

# Update product price
PATCH http://localhost:8080/api/products/{id}/price
Content-Type: application/json
{
  "price": 120.00
}
```

### Price Monitoring

```bash
# Check monitoring status
GET http://localhost:8080/api/products/monitoring/status

# Enable price monitoring
POST http://localhost:8080/api/products/monitoring/enable

# Disable price monitoring
POST http://localhost:8080/api/products/monitoring/disable

# Force full scan
POST http://localhost:8080/api/products/monitoring/force-scan
```

### Testing Price Changes

```bash
# Test price increase (10% increase)
POST http://localhost:8080/api/products/{id}/test-price-increase?percentage=10

# Test price decrease (5% decrease)
POST http://localhost:8080/api/products/{id}/test-price-decrease?percentage=5
```

## 🧪 Testing the Price Change System

### 1. Create a Test Product

```bash
curl -X POST http://localhost:8080/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "description": "Product for testing price changes",
    "price": 100.00,
    "quantity": 10,
    "category": "Test",
    "active": true
  }'
```

### 2. Update the Product Price

```bash
curl -X PATCH http://localhost:8080/api/products/1/price \
  -H "Content-Type: application/json" \
  -d '{"price": 150.00}'
```

### 3. Check RabbitMQ for Price Change Messages

1. Open RabbitMQ Management UI: http://localhost:15672
2. Login with `guest/guest`
3. Go to "Queues" tab
4. Look for the `price-changes` queue
5. Check messages in the queue

### 4. Monitor Application Logs

```bash
./docker-manage.sh logs-app
```

Look for log entries like:
```
=== CAMBIO DE PRECIO DETECTADO ===
Producto ID: 1
Nombre: Test Product
Precio anterior: $100.00
Precio nuevo: $150.00
Cambio: $50.00
Porcentaje de cambio: 50.00%
```

## 🔧 Configuration

### Environment Variables

The Docker setup uses the following key environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `SPRING_PROFILES_ACTIVE` | Active Spring profile | `docker` |
| `SPRING_RABBITMQ_HOST` | RabbitMQ hostname | `rabbitmq` |
| `SPRING_DATASOURCE_URL` | Oracle database URL | Auto-configured |
| `PRICE_MONITORING_ENABLED` | Enable price monitoring | `true` |
| `PRICE_MONITORING_POLL_INTERVAL` | Polling interval (ms) | `30000` |

### Volume Mounts

- **Oracle Wallet**: `./src/main/resources/wallet:/app/wallet:ro`
- **RabbitMQ Data**: `rabbitmq_data:/var/lib/rabbitmq`

## 🛠️ Troubleshooting

### Common Issues

#### 1. Database Connection Errors

**Symptoms**: Application fails to start with Oracle connection errors

**Solutions**:
- Verify wallet files are in `src/main/resources/wallet/`
- Check Oracle database credentials in `docker-compose.yml`
- Ensure network connectivity to Oracle Cloud

```bash
# Check wallet files
ls -la src/main/resources/wallet/

# Test database connectivity from container
./docker-manage.sh shell-app
# Inside container:
ping adb.sa-santiago-1.oraclecloud.com
```

#### 2. RabbitMQ Connection Issues

**Symptoms**: Application can't connect to RabbitMQ

**Solutions**:
- Check RabbitMQ service status
- Verify network connectivity

```bash
# Check RabbitMQ status
./docker-manage.sh health

# Check RabbitMQ logs
./docker-manage.sh logs-rabbitmq
```

#### 3. Port Conflicts

**Symptoms**: Services fail to start due to port already in use

**Solutions**:
- Stop conflicting services
- Modify ports in `docker-compose.yml`

```bash
# Check what's using the ports
netstat -tlnp | grep -E ':(8080|5672|15672)'

# Kill processes using the ports
sudo kill -9 <PID>
```

#### 4. Memory Issues

**Symptoms**: Containers crash or become unresponsive

**Solutions**:
- Increase Docker memory limits
- Reduce JVM heap size in `docker-compose.yml`

```bash
# Monitor resource usage
./docker-manage.sh monitor

# Check available system resources
free -h
df -h
```

### Debugging Commands

```bash
# View detailed service status
docker-compose ps -a

# Check container logs with timestamps
docker-compose logs -t -f rabbitmq-app

# Inspect network configuration
docker network ls
docker network inspect rabbitmqavanzado_app-network

# Check volume usage
docker volume ls
docker volume inspect rabbitmqavanzado_rabbitmq_data
```

## 📊 Monitoring and Health Checks

### Application Health

The application exposes several health check endpoints:

```bash
# Overall health
curl http://localhost:8080/actuator/health

# Database health
curl http://localhost:8080/actuator/health/db

# RabbitMQ health
curl http://localhost:8080/actuator/health/rabbit
```

### RabbitMQ Monitoring

Access the RabbitMQ Management UI at http://localhost:15672

Key metrics to monitor:
- Queue lengths
- Message rates
- Connection status
- Memory usage

### Resource Monitoring

```bash
# Real-time resource usage
./docker-manage.sh monitor

# Container statistics
docker stats --no-stream
```

## 🔄 Updates and Maintenance

### Updating the Application

```bash
# Pull latest code
git pull origin main

# Rebuild and redeploy
./docker-manage.sh rebuild
```

### Database Migrations

The application uses Hibernate auto-DDL with `update` mode. Schema changes are applied automatically when the application starts.

### Backup and Recovery

```bash
# Backup RabbitMQ data
./docker-manage.sh backup

# Restore from backup (manual process)
# 1. Stop services
./docker-manage.sh stop

# 2. Restore volume data
docker run --rm -v rabbitmqavanzado_rabbitmq_data:/data -v $(pwd)/backups:/backup alpine tar xzf /backup/rabbitmq_backup_TIMESTAMP.tar.gz -C /data

# 3. Start services
./docker-manage.sh start
```

## 📝 Development Tips

### Local Development with Docker

1. Use `spring.profiles.active=docker` for Docker environment
2. Mount source code for hot reloading (development only)
3. Use separate database for development testing

### Debugging the Application

```bash
# Enable debug mode
export JAVA_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=*:5005"

# Rebuild with debug settings
./docker-manage.sh rebuild
```

### Performance Tuning

1. **JVM Settings**: Adjust heap size based on container memory
2. **Connection Pools**: Tune database connection pool settings
3. **RabbitMQ**: Configure appropriate queue and exchange settings

## 🤝 Support

For issues and questions:

1. Check this documentation
2. Review application logs: `./docker-manage.sh logs-app`
3. Check service health: `./docker-manage.sh health`
4. Consult the main project README for additional information

## 📚 Additional Resources

- [Spring Boot Docker Documentation](https://spring.io/guides/gs/spring-boot-docker/)
- [RabbitMQ Docker Documentation](https://hub.docker.com/_/rabbitmq)
- [Oracle JDBC Docker Setup](https://docs.oracle.com/en/database/oracle/oracle-database/21/jjdbc/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)