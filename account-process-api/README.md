# Account Process API - RAML Specification

## Overview
This is a RAML 1.0 API specification for the Account Process API (Account-handling-api) version 1.0.0.

## API Details
- **API Name**: Account-process-api
- **Description**: Account-handling-api
- **Version**: 1.0.0
- **Base URI**: http://internal-domain.net
- **Protocol**: HTTPS
- **Business Group**: internal
- **API Type**: internal

## Project Structure

```
account-process-api/
├── api.raml                                    # Main API specification
├── act-common.raml                            # Common traits and headers fragment
├── README.md                                  # This documentation file
├── types/                                     # Data type definitions
│   ├── customers-post-request-datatype.raml   # POST /customers request schema
│   ├── customers-post-response-datatype.raml  # POST /customers response schema
│   └── status-get-response-datatype.raml      # GET /status response schema
└── examples/                                  # Example data files
    ├── post-customers-request-example.raml     # POST /customers request example
    ├── post-customers-response-example.raml    # POST /customers response example
    └── get-status-response-example.raml        # GET /status response example
```

## API Resources

### 1. POST /customers
Creates a new customer account.

**Request Body:**
- `name` (string): Customer name
- `type` (string): Account type (e.g., saving, current)
- `address` (string): Customer address

**Response (200):**
- `status` (string): Processing status (max 32 chars)
- `id` (string): Account ID (max 30 chars)

### 2. GET /status/{id}
Retrieves account status by ID.

**Path Parameter:**
- `id` (string): Account ID

**Response (200):**
- `status` (string): Account processing status

## Headers and Traits

The API uses common traits defined in `act-common.raml`:

### Request Headers (All Methods)
- `x-api-correlationId` (mandatory): Unique correlation ID for request tracking
- `x-api-transaction-id` (mandatory): Transaction identifier
- `x-source-system` (optional): Source system identifier
- `x-api-client-id` (mandatory): Client application identifier

### Response Headers (All Methods)
- `x-api-correlationId` (mandatory): Correlation ID returned from request
- `x-api-transaction-id` (mandatory): Transaction ID returned from request
- `x-response-system` (optional): Response system identifier

### Traits Used
- `postMethod`: Applied to POST operations
- `getMethod`: Applied to GET operations

## File Naming Conventions

The project follows these naming conventions:

**Examples:** `<method>-<resourcename>-<request/response>-example.raml`
- `post-customers-request-example.raml`
- `post-customers-response-example.raml`
- `get-status-response-example.raml`

**Datatypes:** `<resourcename>-<method>-<request/response>-datatype.raml`
- `customers-post-request-datatype.raml`
- `customers-post-response-datatype.raml`
- `status-get-response-datatype.raml`

## Usage

1. Extract the ZIP file to your desired location
2. Open `api.raml` in your RAML editor or IDE
3. The API specification includes all necessary dependencies and references
4. All datatypes, examples, and traits are properly linked and ready for use

## Dependencies

This API specification uses:
- RAML 1.0 specification
- Local fragment `act-common.raml` for shared traits and headers
- Modular structure with separate files for datatypes and examples

## Validation

All RAML files follow proper syntax and structure:
- Main API file references all required components
- Datatypes define proper object structures with validation rules
- Examples provide valid sample data matching the defined schemas
- Traits properly define request and response headers for different HTTP methods
