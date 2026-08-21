**EC2 to RDS MySQL Data Migration using AWS DMS**
# Migrate-EC2-DB-Data-to-the-RDS-Instance
This project demonstrates how to set up a MySQL database on an EC2 instance, create sample tables and data, and then migrate that data into an Amazon RDS MySQL instance using AWS Database Migration Service (DMS). It covers IAM role setup, security group configuration, migration tasks, and verification of migrated data.

## Flow
1. Create an EC2 instance and install MySQL database, then create sample tables.
2. Create a MySQL RDS DB instance.
3. Create IAM Roles.
4. Migrate EC2 data to RDS.
## Step 1: Setup EC2 Instance
- Launch Linux EC2 instance (RedHat, t3.micro) with 20 GB volume.
- Install MySQL:
  ```bash
  sudo -s
  sudo yum update -y
  sudo dnf install mysql8.4-server -y
  sudo systemctl enable --now mysqld.service
  sudo systemctl status mysqld
  sudo mysql_secure_installation

Configure root password: welcome123
Create database and tables:
CREATE DATABASE IF NOT EXISTS company_test_db;
USE company_test_db;
CREATE TABLE departments (...);
CREATE TABLE employees (...);
INSERT INTO departments (...);
INSERT INTO employees (...);

**Step 2: Create IAM Roles**
Role 1: dms-vpc-role → Permissions: AmazonDMSVPCManagementRole
Role 2: dms-cloudwatch-logs-role → Permissions: AmazonDMSCloudWatchLogsRole, CloudWatchFullAccess
**Step 3: Setup RDS Instance**
-->Engine: MySQL
-->Username: admin
-->Password: root123456
-->Public Access: NO
-->Connect EC2 → RDS via security groups.
**Step 4: Migrate Database**
-->Source: EC2 MySQL (root/welcome123)
-->Target: RDS MySQL (admin/root123456)
-->IAM Roles: may18-source-role, may18-target-role, may18-dms-role
-->Migration type: Full Load
-->Adjust security groups to allow traffic from DMS.
**Step 5: Verify Migration**
mysql -h mysqdb.cdbmlufgqkjd.ap-south-1.rds.amazonaws.com -P 3306 -u admin -p
show databases;
use company_test_db;
show tables;
select * from departments;
select * from employees;

