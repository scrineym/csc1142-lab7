# SQL Server with Northwind Database + JupyterLab DBT Environment

This project provides a Docker-based development environment with:
- Microsoft SQL Server with the Northwind sample database pre-installed
- JupyterLab with dbt-core and dbt-sqlserver pre-configured

## Architecture

The setup consists of two Docker containers:
1. **sqlserver-northwind**: SQL Server 2022 with Northwind database
2. **jupyter-dbt**: JupyterLab with DBT and all necessary dependencies

Both containers are connected via a Docker network, allowing seamless communication.

## Quick Start

Build and start both containers:
```bash
docker compose up -d
```

This will:
- Build and start the SQL Server container with Northwind database
- Build and start the JupyterLab container with DBT installed
- Create shared volumes for your DBT projects and notebooks

## Accessing the Services

### JupyterLab
Simply open your browser and navigate to:
```
http://localhost:8888
```

No password or token required!

### SQL Server
- **Host:** sqlserver-northwind (from within JupyterLab) or localhost (from your machine)
- **Port:** 1433
- **Username:** sa
- **Password:** YourStrong!Passw0rd
- **Database:** Northwind

## Using DBT in JupyterLab

### Option 1: Using DBT in a Jupyter Notebook

Create a new notebook in JupyterLab and run:

```python
# Test DBT connection
!dbt --version

# Initialize a new DBT project
!cd dbt_projects && dbt init my_project
```

### Option 2: Using the Terminal in JupyterLab

1. In JupyterLab, click File → New → Terminal
2. Navigate to the dbt_projects folder:
```bash
cd dbt_projects
dbt init my_project
```

### DBT Connection Configuration

When initializing your DBT project, use these connection settings:
- **Database type:** sqlserver (option 2)
- **Server:** sqlserver-northwind
- **Port:** 1433
- **Database:** Northwind
- **Schema:** dbo
- **Authentication:** sql
- **User:** sa
- **Password:** YourStrong!Passw0rd

## Verifying Installation

### Check if container is running and view logs
```bash
docker ps
```

View container logs to verify Northwind installation:
```bash
docker logs sqlserver-northwind
```

You should see "Northwind database installed successfully!" in the logs.

### Method 1: Execute SQL queries from outside the container

List all databases:
```bash
docker exec -it sqlserver-northwind /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C -Q "SELECT name FROM sys.databases"
```

List Northwind tables:
```bash
docker exec -it sqlserver-northwind /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C -d Northwind -Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES"
```

Query sample data from Customers table:
```bash
docker exec -it sqlserver-northwind /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C -d Northwind -Q "SELECT TOP 5 * FROM Customers"
```

### Method 2: Interactive shell inside the container

Enter the container:
```bash
docker exec -it sqlserver-northwind /bin/bash
```

Once inside, start sqlcmd:
```bash
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C
```

Then run SQL commands:
```sql
USE Northwind;
GO

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES;
GO

SELECT TOP 5 * FROM Customers;
GO

SELECT TOP 5 * FROM Products;
GO

EXIT
```

### Verify record counts
```bash
docker exec -it sqlserver-northwind /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C -d Northwind -Q "SELECT 'Customers' AS TableName, COUNT(*) AS RecordCount FROM Customers UNION ALL SELECT 'Products', COUNT(*) FROM Products UNION ALL SELECT 'Orders', COUNT(*) FROM Orders"
```

## Troubleshooting

If the Northwind database is not accessible:

1. Check the container logs:
```bash
docker logs sqlserver-northwind
```

2. Rebuild the container (this will recreate everything):
```bash
docker compose down -v
docker compose up -d --build
```

3. Wait a minute for SQL Server to start and the database to be installed, then check logs again.

## Stopping and Removing

Stop both containers:
```bash
docker compose down
```

Stop and remove volumes (deletes all data):
```bash
docker compose down -v
```

Restart containers:
```bash
docker compose restart
```

# Lab Instructions

## Working with the Pre-configured DBT Project

The environment comes with a pre-configured DBT project called `csc1142lab7` that is ready to use.

1. Access JupyterLab at `http://localhost:8888`

2. Open a new Terminal (File → New → Terminal)

3. Navigate to the pre-configured dbt project:
```bash
cd ~/dbt_projects/csc1142lab7
```

4. Verify the project structure:
```bash
ls -la
```

**Expected:** You should see:
```
dbt_project.yml
models/
README.md
tests/
macros/
snapshots/
analyses/
seeds/
```

## DBT Configuration

Both the DBT project and profiles.yml are pre-configured:

- **Project configuration:** `~/dbt_projects/csc1142lab7/dbt_project.yml`
- **Connection profile:** `~/.dbt/profiles.yml` (contains all SQL Server connection settings)

The profiles.yml includes:
- SQL Server connection details (host, port, database)
- ODBC Driver 18 encryption settings (encrypt: true, trust_cert: true)
- Schema configuration (dbo)

**No manual configuration is required!**

## Test the Connection

**IMPORTANT:** You must be inside your dbt project directory to run dbt commands!

The profiles.yml file is already pre-configured in the container. Now test the connection:

```bash
# Navigate to your dbt project directory
cd ~/dbt_projects/csc1142lab7

# Test the connection
dbt debug
```

**Expected output:**
You should see:
```
Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]

Required dependencies:
 - git [OK found]

Connection:
  host: sqlserver-northwind
  database: Northwind
  schema: dbo
  user: sa
  Connection test: [OK connection ok]

All checks passed!
```

If you see any errors:
- Make sure you're in the `~/dbt_projects/csc1142lab7` directory (not `~/dbt_projects`)
- Check that you added `encrypt: true` and `trust_cert: true` to profiles.yml
- Verify the SQL Server container is running: `docker ps`


## Notes

- The container takes about 30-60 seconds to fully start and install the database
- Data is persisted in a Docker volume named `sqlserver-data`
- The SA password must meet SQL Server complexity requirements (uppercase, lowercase, numbers, symbols)
- Make sure the SQL Server container is running before attempting to connect with DBT

## Complete Environment Reset

To delete everything and start from scratch:

```bash
./restart.sh
```

This will:
- Remove all Docker containers and volumes
- Reset all changes to `dbt_projects/csc1142lab7/` (using git checkout)
- Rebuild images from scratch
- Restart fresh containers

The Northwind database and DBT project will be restored to their original state.
