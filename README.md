# EC2 to RDS MySQL Data Migration using AWS DMS

## 📌 Project Overview

This project demonstrates how to migrate a **MySQL database running on an EC2 instance** to **Amazon RDS for MySQL** using **AWS Database Migration Service (DMS)**.

The project covers:

* Installing MySQL on EC2
* Creating a sample database
* Creating tables and inserting data
* Creating an Amazon RDS MySQL database
* Configuring IAM roles
* Configuring Security Groups
* Creating AWS DMS replication resources
* Migrating database data
* Verifying the migrated database

---

# 🔄 Migration Flow

```text
        EC2 Instance
        MySQL Database
              │
              │
              ▼
      AWS DMS Replication
              │
              │ Full Load
              ▼
       Amazon RDS MySQL
              │
              ▼
      Verify Migrated Data
```

---

# 🛠️ AWS Services & Technologies

| Service / Technology | Purpose                         |
| -------------------- | ------------------------------- |
| Amazon EC2           | Hosts the source MySQL database |
| MySQL                | Source database                 |
| Amazon RDS           | Target MySQL database           |
| AWS DMS              | Migrates database data          |
| IAM                  | Provides DMS permissions        |
| Security Groups      | Controls network connectivity   |
| CloudWatch           | DMS monitoring and logs         |

---

# 1. Setup EC2 Instance

Launch an EC2 instance to act as the **source database server**.

### Example Configuration

```text
OS              : Linux / Red Hat
Instance Type   : t3.micro
Storage         : 20 GB
Database        : MySQL
```

Connect to the EC2 instance using SSH.

---

# 2. Install MySQL on EC2

Switch to root:

```bash
sudo -s
```

Update packages:

```bash
sudo yum update -y
```

Install MySQL:

```bash
sudo dnf install mysql8.4-server -y
```

Enable and start MySQL:

```bash
sudo systemctl enable --now mysqld.service
```

Check MySQL status:

```bash
sudo systemctl status mysqld
```

Run MySQL secure installation:

```bash
sudo mysql_secure_installation
```

Configure the MySQL root password.

Example:

```text
welcome123
```

> Use a strong password for real environments and never commit credentials to GitHub.

---

# 3. Create Source Database

Connect to MySQL:

```bash
mysql -u root -p
```

Create the database:

```sql
CREATE DATABASE IF NOT EXISTS company_test_db;
```

Select the database:

```sql
USE company_test_db;
```

---

# 4. Create Tables

Create the departments table:

```sql
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);
```

Create the employees table:

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    salary DECIMAL(10,2)
);
```

---

# 5. Insert Sample Data

Insert departments:

```sql
INSERT INTO departments
(department_id, department_name)
VALUES
(1, 'IT'),
(2, 'HR'),
(3, 'Finance');
```

Insert employees:

```sql
INSERT INTO employees
(employee_id, employee_name, department_id, salary)
VALUES
(101, 'Ajay', 1, 60000),
(102, 'Rahul', 2, 55000),
(103, 'Priya', 3, 65000);
```

Verify the data:

```sql
SELECT * FROM departments;
```

```sql
SELECT * FROM employees;
```

---

# 6. Create IAM Roles for AWS DMS

AWS DMS requires IAM permissions to interact with AWS services.

Create the required roles.

### Role 1: DMS VPC Role

```text
Role Name:
dms-vpc-role
```

Attach:

```text
AmazonDMSVPCManagementRole
```

This role allows DMS to manage required VPC networking resources.

---

### Role 2: DMS CloudWatch Logs Role

```text
Role Name:
dms-cloudwatch-logs-role
```

Attach:

```text
AmazonDMSCloudWatchLogsRole
```

CloudWatch permissions may also be required depending on the configuration.

> For production environments, use least-privilege IAM policies instead of broad permissions such as `CloudWatchFullAccess`.

---

# 7. Create Amazon RDS MySQL

Create the target RDS database.

Go to:

```text
AWS Console
   ↓
RDS
   ↓
Databases
   ↓
Create Database
```

Choose:

```text
Engine : MySQL
```

Example configuration:

```text
Username       : admin
Password       : <your-password>
Public Access  : No
Port           : 3306
```

For this project, RDS is configured as the **target database**.

Wait until the RDS instance status becomes:

```text
Available
```

Copy the RDS endpoint.

Example:

```text
mysqldb.xxxxxxxxx.ap-south-1.rds.amazonaws.com
```

---

# 8. Configure Security Groups

Network connectivity is required between:

```text
EC2
 ↓
AWS DMS
 ↓
RDS
```

Configure Security Groups appropriately.

### EC2 Security Group

Allow MySQL traffic where required.

```text
Port : 3306
Source : DMS / appropriate security group
```

### RDS Security Group

Allow:

```text
Type       : MySQL/Aurora
Port       : 3306
Source     : DMS replication instance security group
```

Avoid allowing:

```text
0.0.0.0/0
```

for database access in production.

---

# 9. AWS DMS Setup

Go to:

```text
AWS Console
   ↓
AWS DMS
```

Create the required DMS resources.

The main components are:

```text
Source Endpoint
        ↓
Replication Instance
        ↓
Target Endpoint
        ↓
Migration Task
```

---

# 10. Create DMS Replication Instance

Create a replication instance.

Example:

```text
Identifier:
ec2-to-rds-dms
```

Choose an appropriate instance class for your lab.

The replication instance is responsible for performing the migration.

Wait until:

```text
Status: Available
```

---

# 11. Create Source Endpoint

Create the source endpoint for the MySQL database running on EC2.

Configuration:

```text
Endpoint Type : Source
Engine        : MySQL
Server        : EC2 private IP / hostname
Port          : 3306
Username      : root
Password      : <source-password>
Database      : company_test_db
```

Example:

```text
Source
  ↓
EC2 MySQL
```

Test the connection.

Expected result:

```text
Connection successful
```

---

# 12. Create Target Endpoint

Create the target endpoint for Amazon RDS.

Configuration:

```text
Endpoint Type : Target
Engine        : MySQL
Server        : RDS Endpoint
Port          : 3306
Username      : admin
Password      : <target-password>
Database      : company_test_db
```

Example:

```text
Target
  ↓
Amazon RDS MySQL
```

Test the connection.

Expected result:

```text
Connection successful
```

---

# 13. Create DMS Migration Task

Go to:

```text
AWS DMS
   ↓
Database Migration Tasks
   ↓
Create Task
```

Example configuration:

```text
Task Identifier:
ec2-to-rds-migration
```

Select:

```text
Replication Instance:
ec2-to-rds-dms
```

Source:

```text
EC2 MySQL
```

Target:

```text
RDS MySQL
```

Migration type:

```text
Migrate existing data
```

This is also known as a **Full Load** migration.

---

# 14. Configure Table Mappings

Configure which tables should be migrated.

Example:

```text
Schema:
company_test_db

Table:
%

Action:
Include
```

This tells DMS to include the required tables.

For example:

```text
company_test_db
      │
      ├── departments
      │
      └── employees
```

---

# 15. Start the Migration

Create the migration task.

Start the task.

The status will progress through stages such as:

```text
Creating
   ↓
Starting
   ↓
Running
   ↓
Load complete
```

Monitor the task from the AWS DMS console.

---

# 16. DMS Migration Architecture

```text
┌────────────────────────┐
│      EC2 Instance      │
│                        │
│    MySQL Database      │
│                        │
│  company_test_db       │
│     ├── departments    │
│     └── employees      │
└───────────┬────────────┘
            │
            │ MySQL : 3306
            ▼
┌────────────────────────┐
│     AWS DMS            │
│                        │
│ Replication Instance   │
│                        │
│      Full Load         │
└───────────┬────────────┘
            │
            │ MySQL : 3306
            ▼
┌────────────────────────┐
│     Amazon RDS         │
│       MySQL            │
│                        │
│  company_test_db       │
│     ├── departments    │
│     └── employees      │
└────────────────────────┘
```

---

# 17. Verify Migration

After the DMS task reaches:

```text
Load complete
```

connect to the RDS MySQL database.

Example:

```bash
mysql -h <RDS-ENDPOINT> -P 3306 -u admin -p
```

---

# 18. Check Databases

Run:

```sql
SHOW DATABASES;
```

Select the migrated database:

```sql
USE company_test_db;
```

---

# 19. Check Tables

Run:

```sql
SHOW TABLES;
```

Expected tables:

```text
departments
employees
```

---

# 20. Verify Departments Data

Run:

```sql
SELECT * FROM departments;
```

Expected example:

```text
1   IT
2   HR
3   Finance
```

---

# 21. Verify Employees Data

Run:

```sql
SELECT * FROM employees;
```

Expected example:

```text
101   Ajay    1   60000
102   Rahul   2   55000
103   Priya   3   65000
```

---

# 22. Compare Row Counts

On the source EC2 MySQL:

```sql
SELECT COUNT(*) FROM departments;
```

```sql
SELECT COUNT(*) FROM employees;
```

Run the same commands on RDS:

```sql
SELECT COUNT(*) FROM departments;
```

```sql
SELECT COUNT(*) FROM employees;
```

The counts should match after a successful full-load migration.

---

# 🔄 Complete Migration Workflow

```text
EC2
 │
 │ MySQL Source Database
 │
 ▼
AWS DMS Source Endpoint
 │
 ▼
DMS Replication Instance
 │
 │ Full Load
 ▼
DMS Target Endpoint
 │
 ▼
Amazon RDS MySQL
 │
 ▼
Verify Tables
 │
 ▼
Verify Records
```

---

# 📚 Key Concepts Learned

Through this project, I practiced:

* Installing MySQL on EC2
* Creating MySQL databases
* Creating tables and records
* Amazon RDS MySQL
* AWS Database Migration Service
* DMS source endpoints
* DMS target endpoints
* DMS replication instances
* DMS migration tasks
* Full Load migration
* IAM roles
* Security Groups
* MySQL connectivity
* Database verification
* Row-count validation

---

# 🎯 Key Takeaway

This project helped me understand how **AWS DMS can migrate data from a MySQL database running on EC2 to Amazon RDS MySQL**.

The main workflow is:

```text
EC2 MySQL
    ↓
DMS Source Endpoint
    ↓
DMS Replication Instance
    ↓
DMS Target Endpoint
    ↓
RDS MySQL
```

AWS DMS reduces the need for manual database export/import operations and provides a managed service for database migration.

---

# 🔐 Security Notes

For a real production migration:

* Keep RDS private whenever possible.
* Avoid public database access.
* Use Security Groups instead of open IP ranges.
* Do not use simple passwords such as `welcome123` or `root123456`.
* Do not commit database credentials to GitHub.
* Use AWS Secrets Manager where appropriate.
* Apply least-privilege IAM permissions.
* Restrict port `3306` to only the required sources.
* Enable encryption and backups according to the application's requirements.
* Monitor DMS tasks using CloudWatch.
