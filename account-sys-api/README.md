# Account Data Integration System API

## Overview

The **account-sys-api** is a MuleSoft-based System API that provides seamless integration between Salesforce and PostgreSQL database systems. This API reads Account records from Salesforce and synchronizes them with a PostgreSQL database, implementing intelligent upsert operations (insert new records or update existing ones).

## Architecture

```
┌─────────────────┐    HTTP Request    ┌──────────────────┐    SOQL Query    ┌─────────────────┐
│   API Client    │ ──────────────────→ │  Account Sys API │ ──────────────→ │   Salesforce    │
│                 │                     │                  │                  │                 │
└─────────────────┘                     └──────────────────┘                  └─────────────────┘
                                                 │
                                                 │ SQL Upsert
                                                 ▼
                                        ┌─────────────────┐
                                        │   PostgreSQL    │
                                        │   (Customers)   │
                                        └─────────────────┘
```

### High-Level Flow Description

1. **HTTP Request**: Client sends GET/POST request to `/api/v1/accounts/sync`
2. **Salesforce Query**: API queries Salesforce Account objects using SOQL
3. **Data Transformation**: Account data is transformed using DataWeave to match database schema
4. **Database Upsert**: Records are inserted (new) or updated (existing) in PostgreSQL Customers table
5. **Response**: API returns summary with processing statistics

## Database Schema

The target PostgreSQL table `Customers` has the following structure:

| Column Name    | Data Type    | Description                          | Source Field        |
|---------------|--------------|--------------------------------------|---------------------|
| Salesforce_Id | VARCHAR      | Primary Key from Salesforce         | Account.Id          |
| First_Name    | VARCHAR      | Customer/Account Name                | Account.Name        |
| Phone         | VARCHAR      | Phone Number                         | Account.Phone       |
| Address       | VARCHAR      | Billing Address (City)               | Account.BillingCity |

## Configuration

### Prerequisites

- MuleSoft Runtime 4.9.3 or higher
- PostgreSQL database with `Customers` table created
- Valid Salesforce credentials with API access
- Maven 3.6+ for building the project

### Properties Configuration

Update the `src/main/resources/properties/dev.yaml` file with your environment-specific values:

```yaml
# Salesforce Configuration
salesforce:
  username: "your-salesforce-username@domain.com"
  password: "your-salesforce-password"
  securityToken: "your-security-token"

# PostgreSQL Database Configuration
database:
  url: "jdbc:postgresql://localhost:5432/YourDatabaseName"
  driver: "org.postgresql.Driver"
  user: "your-db-username"
  password: "your-db-password"

# HTTP Listener Configuration
http:
  listener:
    host: "0.0.0.0"
    port: "8081"
    protocol: "HTTP"
```

### Database Setup

Create the `Customers` table in your PostgreSQL database:

```sql
CREATE TABLE Customers (
    Salesforce_Id VARCHAR(18) PRIMARY KEY,
    First_Name VARCHAR(255),
    Phone VARCHAR(50),
    Address VARCHAR(255)
);
```

## API Documentation

### Endpoints

#### 1. Sync All Accounts

**Endpoint**: `GET /api/v1/accounts/sync`

**Description**: Synchronizes all Account records from Salesforce to PostgreSQL (limited to 1000 records for performance).

**Request Example**:
```bash
curl -X GET "http://localhost:8081/api/v1/accounts/sync" \
     -H "Content-Type: application/json"
```

**Response Example**:
```json
{
  "status": "SUCCESS",
  "message": "Account synchronization completed successfully",
  "correlationId": "12345678-1234-1234-1234-123456789abc",
  "timestamp": "2026-01-27T14:30:00Z",
  "summary": {
    "recordsProcessed": 25,
    "recordsInserted": 15,
    "recordsUpdated": 10,
    "recordsWithErrors": 0,
    "totalRecordsRetrievedFromSalesforce": 25
  }
}
```

#### 2. Sync Filtered Accounts (GET with Query Parameter)

**Endpoint**: `GET /api/v1/accounts/sync?lastModifiedDate=2026-01-20T00:00:00Z`

**Description**: Synchronizes Account records modified after the specified date.

**Query Parameters**:
- `lastModifiedDate` (optional): ISO 8601 formatted date-time string

**Request Example**:
```bash
curl -X GET "http://localhost:8081/api/v1/accounts/sync?lastModifiedDate=2026-01-20T00:00:00Z" \
     -H "Content-Type: application/json"
```

#### 3. Sync Filtered Accounts (POST with Body)

**Endpoint**: `POST /api/v1/accounts/sync`

**Description**: Synchronizes Account records with filters provided in the request body.

**Request Body**:
```json
{
  "lastModifiedDate": "2026-01-20T00:00:00Z"
}
```

**Request Example**:
```bash
curl -X POST "http://localhost:8081/api/v1/accounts/sync" \
     -H "Content-Type: application/json" \
     -d '{"lastModifiedDate": "2026-01-20T00:00:00Z"}'
```

### Error Responses

#### Salesforce Connectivity Error (HTTP 500)
```json
{
  "error": {
    "code": "SALESFORCE_CONNECTIVITY_ERROR",
    "message": "Unable to connect to Salesforce. Please check your credentials and network connectivity.",
    "correlationId": "12345678-1234-1234-1234-123456789abc",
    "timestamp": "2026-01-27T14:30:00Z"
  }
}
```

#### Database Connectivity Error (HTTP 500)
```json
{
  "error": {
    "code": "DATABASE_CONNECTIVITY_ERROR",
    "message": "Unable to connect to the database. Please check database connectivity.",
    "correlationId": "12345678-1234-1234-1234-123456789abc",
    "timestamp": "2026-01-27T14:30:00Z"
  }
}
```

#### Data Transformation Error (HTTP 400)
```json
{
  "error": {
    "code": "DATA_TRANSFORMATION_ERROR",
    "message": "Data transformation failed. Please check the data format and mapping.",
    "correlationId": "12345678-1234-1234-1234-123456789abc",
    "timestamp": "2026-01-27T14:30:00Z"
  }
}
```

## Project Structure

```
account-sys-api/
├── pom.xml                                    # Maven configuration
├── mule-artifact.json                         # Mule application configuration
├── src/
│   ├── main/
│   │   ├── mule/
│   │   │   ├── global.xml                     # Global configurations
│   │   │   ├── error.xml                      # Global error handler
│   │   │   ├── account-sys-api-interface.xml  # Main API interface flows
│   │   │   └── impl/
│   │   │       └── account-sys-api-impl.xml   # Business logic implementation
│   │   └── resources/
│   │       ├── properties/
│   │       │   └── dev.yaml                   # Environment properties
│   │       └── dwl/
│   │           └── mag-account-to-db-payload.dwl # DataWeave transformation
│   └── test/
│       └── munit/
│           └── account-sys-api-test-suite.xml # MUnit test cases
└── README.md                                  # This documentation
```

## Development

### Building the Project

```bash
cd account-sys-api
mvn clean compile
```

### Running Tests

```bash
mvn test
```

### Running the Application Locally

```bash
mvn mule:run
```

The API will be available at `http://localhost:8081`

### Packaging for Deployment

```bash
mvn clean package
```

This creates a deployable JAR file in the `target/` directory.

## Deployment

### CloudHub Deployment

1. Package the application: `mvn clean package`
2. Deploy via Anypoint Platform Runtime Manager
3. Configure environment-specific properties
4. Monitor application health and performance

### On-Premises Deployment

1. Install Mule Runtime 4.9.3+
2. Deploy the packaged JAR to `apps/` directory
3. Configure properties in `conf/` directory
4. Start/restart Mule Runtime

## Monitoring and Logging

The API provides comprehensive logging at key integration points:

- **Info Level**: API invocations, successful operations, record counts
- **Error Level**: Connection failures, data transformation errors, database errors
- **Correlation ID**: All logs include correlation ID for request tracing

### Key Log Messages

- `Account Sync API invoked` - API request received
- `Starting Salesforce query for Account records` - Before Salesforce query
- `Salesforce query completed successfully` - After successful Salesforce query  
- `Starting database upsert operations` - Before database operations
- `Database operations completed` - After database operations with statistics

## Performance Considerations

- **Batch Size**: Default limit of 1000 records per sync to prevent timeout
- **Connection Pooling**: Database connections include reconnection strategy
- **Error Handling**: Graceful degradation with detailed error responses
- **Logging**: Structured logging for monitoring and troubleshooting

## Security

- **Credentials**: All sensitive information stored in properties files
- **SQL Injection Prevention**: Parameterized SQL queries used throughout
- **HTTPS**: Configure HTTPS in production environments
- **Authentication**: Consider adding API authentication for production use

## Testing

The project includes comprehensive MUnit test cases:

1. **Positive Scenario**: Successful account synchronization
2. **Salesforce Error**: Salesforce connectivity failure handling
3. **Database Error**: Database connectivity failure handling
4. **Update Scenario**: Existing record update functionality

Run tests with: `mvn test`

## Support and Troubleshooting

### Common Issues

1. **Salesforce Authentication**: Verify username, password, and security token
2. **Database Connection**: Check database URL, credentials, and network connectivity
3. **Field Mapping**: Ensure Salesforce fields exist and are accessible
4. **Performance**: Monitor record counts and consider implementing pagination

### Debugging

Enable DEBUG logging by updating log4j2.xml:
```xml
<Logger name="org.mule.extension.salesforce" level="DEBUG"/>
<Logger name="org.mule.extension.db" level="DEBUG"/>
```

## Version History

- **v1.0.0**: Initial release with basic account synchronization
  - Salesforce to PostgreSQL integration
  - Upsert functionality (insert/update)
  - Comprehensive error handling
  - MUnit test coverage

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
