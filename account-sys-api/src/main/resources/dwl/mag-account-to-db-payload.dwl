%dw 2.0
output application/java
---
/**
 * Transforms Salesforce Account records to database-ready format
 * Maps Salesforce fields to PostgreSQL Customers table columns
 * 
 * Input: Array of Salesforce Account objects
 * Output: Array of database payload objects
 * 
 * Field Mappings:
 * - Salesforce Id -> Salesforce_Id (Primary Key)
 * - Salesforce Name -> First_Name 
 * - Salesforce Phone -> Phone
 * - Salesforce BillingCity -> Address
 */

payload map (account, index) -> {
    // Primary key - Salesforce ID (required)
    Salesforce_Id: account.Id default "",
    
    // Customer name - handle null values and trim whitespace
    First_Name: if (account.Name != null) 
                    trim(account.Name as String) 
                else 
                    "Unknown",
    
    // Phone number - handle various formats and null values
    Phone: if (account.Phone != null and account.Phone != "") 
               trim(account.Phone as String) 
           else 
               null,
    
    // Address from BillingCity - handle null values
    Address: if (account.BillingCity != null and account.BillingCity != "") 
                 trim(account.BillingCity as String) 
             else 
                 null
}
// Filter out records with empty or null Salesforce IDs
filter (record) -> (record.Salesforce_Id != null and record.Salesforce_Id != "")
