# init_db.md

# 1. MySQL user check

```bash
if id "mysql" >/dev/null 2>&1; then
    echo "User 'mysql' exists."
else
    echo "Error: User 'mysql' does not exist. Exiting."
    exit 1
fi
```

The mysql user is important because:

- It's the system user under which the MariaDB server runs
- It's created automatically when installing MariaDB/MySQL
- It's a security measure to avoid running the database as root

It needs specific permissions to:

- Read/write database files
- Access the data directory
- Create socket files
- Write to log files

## 2. MySQL group check

```bash
if getent group mysql >/dev/null 2>&1; then
    echo "Group 'mysql' exists."
else
    echo "Error: Group 'mysql' does not exist. Exiting."
    exit 1
fi
```

The mysql group is important because:

- It provides group-level permissions for database files
- Multiple processes/users that need database access can be added to this group
- It's part of Linux's security model for file permissions

The data directory **/var/lib/mysql** is typically owned by mysql:mysql (user:group)\

Note: These checks might be redundant because the MariaDB installation create them automatically

## 3. Initialize MariaDB is not initialized yet

```bash
# Set the path to the MariaDB data directory
DATA_DIR="/var/lib/mysql"

if [ -d "$DATA_DIR/mysql" ]; then
    echo "MariaDB data directory already exists. Skipping initialization."
else
    echo "MariaDB data directory not found. Initializing..."
    # Initialize the MariaDB database
    mysql_install_db --user=mysql --datadir="$DATA_DIR" || { echo "Error: Failed to initialize MariaDB data directory."; exit 1; }
fi
```

- `/var/lib/mysql` is the standard data directory for MariaDB
- `/var/lib/mysql/mysql` is a subdirectory that contains system tables

**mysql_install_db**:

- Initializes the MariaDB system tables
- Creates the necessary system databases
- Sets up the basic structure needed for MariaDB to function
- Creates two default users (root@localhost and mysql@localhost)

**/var/lib/mysql/mysql** is not redundant - it's the standard structure where:

- /var/lib/mysql is the data directory
- /var/lib/mysql/mysql contains the actual system tables

## Starting MaridDB service with **mysqld_safe**

```bash
# Start MySQL/MariaDB service
echo "Starting MariaDB service..."
mysqld_safe &
sleep 5  # Give MariaDB some time to start

```

**mysql_install_db** vs **mysqld_safe**

_mysql_install_

- is a one-time **initialization** tool
- creates the initial system databases and tables
- creates the system databases
- Sets up initial privilege tables
- creates the root account
- establishes the basic directory structure

_mysqld_safe_

- is the server **startup script**
- is used to actually start and run the MariaDB server process
- starts the actual database server (mysqld)
- monitors the server process
- restarts it if it crashes
- logs operations and errors
- sets up important runtime parameters
