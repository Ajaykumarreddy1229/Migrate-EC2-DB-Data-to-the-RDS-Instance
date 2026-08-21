1.sudo -s  
Switches to the root user shell. This gives you full administrative privileges so you can run installation and configuration commands without restrictions.
2.sudo yum update -y  
Updates all packages on the system to their latest versions using the yum package manager. The -y flag automatically answers "yes" to prompts.
3.sudo dnf install mysql8.4-server -y  
Installs the MySQL 8.4 server package using dnf (the modern replacement for yum). Again, -y confirms installation without asking.
4.sudo systemctl enable --now mysqld.service
enable → ensures MySQL starts automatically whenever the system boots.
--now → starts the MySQL service immediately without waiting for a reboot.
5.sudo systemctl status mysqld  
Shows the current status of the MySQL service (running, stopped, errors, etc.).
6.sudo mysql_secure_installation  
Runs a built‑in script to secure your MySQL installation. It helps you:
-->Set a root password.
-->Configure password validation policy.
-->Remove anonymous users.
-->Disable remote root login.
-->Remove test databases.
-->Reload privilege tables.
This step is critical because it hardens your database against unauthorized access.
