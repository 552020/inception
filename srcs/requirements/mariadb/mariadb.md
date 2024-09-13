# MariaDB

MariaDB is an open-source RDMS (Relational Database Managment System). It is a fork of MySQL after Oracle's acquisition of MySQL.
https://mariadb.org/
https://en.wikipedia.org/wiki/MariaDB

- **`mariadb-client`** is the command-line tool for interacting with a MariaDB or MySQL server. It’s essential if you need to interact with MariaDB from the container itself. In a minimal production environment, if the MariaDB container is solely for running the database, the client is not strictly necessary. However, it's useful for testing and manual database management within the container.

## How to install it

https://mariadb.com/kb/en/installing-system-tables-mariadb-install-db/

### Syncing Databases Between Droplet, Local Machine, and VM for Evaluation

To sync the databases between environments (e.g., the production droplet, your local machine, and the VM for evaluation), follow these steps:

1. **Export the Database from the Droplet**:
   Use the `mysqldump` command to create a backup of the database on the droplet:

   ```bash
   mysqldump -u [user] -p [database_name] > wordpress_backup.sql
   ```

2. **Transfer the Backup**:
   Copy the backup file from the droplet to your local machine or VM using `scp` or other file transfer methods:

   ```bash
   scp user@your_droplet_ip:/path/to/wordpress_backup.sql /path/to/local/folder
   ```

3. **Import the Database Locally or in VM**:
   Restore the backup into the local or VM MariaDB instance:

   ```bash
   mysql -u [user] -p [database_name] < wordpress_backup.sql
   ```

4. **Automate the Syncing Process (Optional)**:
   You can create a script to automate this backup, transfer, and restore process if frequent syncing is required. Alternatively, cloud services like Google Cloud Storage or AWS S3 can be used to store and access database dumps.

### What is the "WordPress Database"?

The **WordPress database** is a **MySQL/MariaDB** database that stores all the essential data for a WordPress site. This includes:

- Posts, pages, and other content.
- User information, including credentials.
- Site settings and configurations.
- Plugin and theme settings.

The database itself is not a file in the typical sense (like a `.docx` or `.png`), but rather a collection of **structured data** that is stored and managed by a **DBMS (Database Management System)** like MySQL or MariaDB. The database is composed of tables where all this data is organized. Each table consists of rows and columns, similar to a spreadsheet.

### Why is the Database Outside of the Docker Container?

In Docker, it’s common practice to store the database outside of the container for several reasons:

1. **Separation of Concerns**: The **MariaDB container** hosts the **DBMS (Database Management System)**, which is the software that manages the database operations (querying, updating, etc.). The actual **database** (the structured data) is stored on the host machine in a volume.

2. **Persistence**: Containers are stateless, meaning if the MariaDB container is restarted, any data stored inside it would be lost. By storing the database externally in a **Docker volume**, the data is preserved across container restarts or re-builds.

3. **Backup and Access**: Storing the database outside the container makes it easier to perform backups, manage scaling, and share the data between different containers or environments without the risk of losing it during container maintenance.

In summary:

- **DBMS** (like MariaDB) is the software that manages databases.
- The **database** (like WordPress's database) is the structured data stored and managed by the DBMS.
- By keeping the database outside the container, you ensure its persistence and accessibility across environments.

Here's a detailed breakdown of the message from running `mysql_install_db` for MariaDB, along with explanations for each part:

---

### **Full Output:**

```
 # mysql_install_db --user=mysql --datadir=/var/lib/mysql
Installing MariaDB/MySQL system tables in '/var/lib/mysql' ...
OK

To start mariadbd at boot time you have to copy
support-files/mariadb.service to the right place for your system

Two all-privilege accounts were created.
One is root@localhost, it has no password, but you need to be system 'root' user to connect. Use, for example, sudo mysql
The second is mysql@localhost, it has no password either, but
you need to be the system 'mysql' user to connect.
After connecting you can set the password, if you would need to be
able to connect as any of these users with a password and without sudo

See the MariaDB Knowledgebase at https://mariadb.com/kb

You can start the MariaDB daemon with:
cd '/usr' ; /usr/bin/mariadb-safe --datadir='/var/lib/mysql'

You can test the MariaDB daemon with mysql-test-run.pl
cd '/usr/mysql-test' ; perl mariadb-test-run.pl

Please report any problems at https://mariadb.org/jira

The latest information about MariaDB is available at https://mariadb.org/.

Consider joining MariaDB's strong and vibrant community:
https://mariadb.org/get-involved/
```

---

### **Breakdown and Commentary:**

1. **`Installing MariaDB/MySQL system tables in '/var/lib/mysql' ... OK`**

   This message indicates that MariaDB has successfully initialized its internal system tables. These tables include critical structures like user accounts, privileges, and various metadata essential for the database engine to function. The data directory specified here (`/var/lib/mysql`) is the default location where MariaDB will store its database files.

   **Comment**: The system tables are the core of the MariaDB database. Without this initialization, the database wouldn't be able to handle queries or store data.

---

2. **`To start mariadbd at boot time you have to copy support-files/mariadb.service to the right place for your system`**

   This step suggests enabling the MariaDB service to start automatically at system boot. The `mariadb.service` file is a systemd service file that manages the MariaDB process on modern Linux systems. Copying this file to `/etc/systemd/system/` (or a similar directory depending on the system) allows the operating system to manage the MariaDB service.

   **Comment**: This step is typically handled automatically by package managers like `apt` or `apk`. However, when manually installing MariaDB (as in this case), you may need to manually enable the service. It's optional for Docker containers, as you usually don't rely on system services within a container environment.

---

3. **`Two all-privilege accounts were created...`**

   MariaDB creates two default accounts:

   - `root@localhost`: The superuser account without a password by default. To connect as this user, you need to use `sudo mysql` or run the command as the system `root` user.
   - `mysql@localhost`: Another account, also without a password, but only accessible if you are logged in as the system `mysql` user.

   **Comment**: By default, MariaDB sets up these accounts with no passwords for security purposes during setup. The recommendation is to set a password for these accounts as soon as possible using the `mysql_secure_installation` command. This avoids leaving your database open to unauthorized access.

---

4. **`See the MariaDB Knowledgebase at https://mariadb.com/kb`**

   This message refers you to the MariaDB Knowledgebase, which contains extensive documentation and guides on how to manage and configure your MariaDB instance.

   **Comment**: If you're new to MariaDB, it's helpful to explore this resource for detailed explanations and examples.

---

5. **`You can start the MariaDB daemon with: cd '/usr' ; /usr/bin/mariadb-safe --datadir='/var/lib/mysql'`**

   This line provides a direct command to start MariaDB in safe mode using `mysqld_safe`. This is a recommended way to start MariaDB in environments where stability and security are critical. The `--datadir` option ensures that MariaDB reads the correct directory for its data.

   **Comment**: In a Docker environment, you would generally use `CMD` or `ENTRYPOINT` to start the MariaDB daemon when the container launches. This command is useful for manual testing or one-off runs.

---

6. **`You can test the MariaDB daemon with mysql-test-run.pl`**

   This message suggests a way to test the MariaDB installation using a Perl script that runs several database tests to ensure everything is working as expected.

   **Comment**: In most production setups or Dockerized environments, running this test isn't necessary. It's more useful in a development or testing environment to verify MariaDB's installation.

---

7. **`Please report any problems at https://mariadb.org/jira`**

   MariaDB invites users to report any issues they encounter. This link leads to their issue-tracking system.

   **Comment**: This is useful if you encounter bugs or problems with the installation process or the software itself.

---

8. **`Consider joining MariaDB's strong and vibrant community...`**

   This is an invitation to participate in MariaDB's community, where you can find support, contribute, and stay informed about updates and developments.

   **Comment**: This is typical of open-source projects, and joining such communities can be beneficial for staying updated and troubleshooting issues.

---

This breakdown explains each part of the initialization output and provides the context needed for manual MariaDB installation. After this step, you should be ready to start MariaDB and access your configuration files for further setup.
