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


## Define Your Sources

In dbt, sources allow you to define and document the raw tables in your database. This is an important step that provides:
- Documentation of your source data
- Freshness checks
- Lineage tracking
- A clear reference for your models

### Step 1: Create the models directory

First, create a `models` directory in your dbt project if it doesn't already exist:

```bash
cd ~/dbt_projects/csc1142lab7
mkdir -p models
```

### Step 2: Copy the sources configuration file

We've provided a pre-configured `sources.yml` file that defines all the Northwind tables.

Using the JupyterLab file browser:
1. Navigate to the `lab_files/models/` directory
2. Open and examine the `sources.yml` file to understand its structure
3. Copy the entire contents of the file
4. Navigate to your `dbt_projects/csc1142lab7/models/` directory
5. Create a new file called `sources.yml`
6. Paste the contents into the new file and save it

This file defines 7 source tables from the Northwind database:
- **Customers** - Customer information including company details and contact info
- **Orders** - Order header information
- **Order Details** - Line items for each order with product and pricing details
- **Products** - Product catalog information
- **Categories** - Product category information
- **Suppliers** - Supplier company information
- **Employees** - Employee information including personal and job details

Take a moment to review the file structure and understand how sources are defined in dbt.

### Step 3: Verify your sources configuration

Run the following command to verify that dbt can see your sources:

```bash
cd ~/dbt_projects/csc1142lab7
dbt ls --resource-type source
```

**Expected output:**
```
source:csc1142lab7.northwind.Categories
source:csc1142lab7.northwind.Customers
source:csc1142lab7.northwind.Employees
source:csc1142lab7.northwind.Order Details
source:csc1142lab7.northwind.Orders
source:csc1142lab7.northwind.Products
source:csc1142lab7.northwind.Suppliers
```

### Step 4: Test querying a source

Now let's test that we can query a source.

Using the JupyterLab file browser:
1. Navigate to the `lab_files/models/` directory
2. Open and examine the `test_customers.sql` file
3. Notice how it uses the `{{ source('northwind', 'Customers') }}` syntax to reference the Customers table
4. Copy the entire contents of the file
5. Navigate to your `dbt_projects/csc1142lab7/models/` directory
6. Create a new file called `test_customers.sql`
7. Paste the contents into the new file and save it

This simple model queries US customers from the Northwind database using the `source()` function.

Run this model to verify everything works:

```bash
cd ~/dbt_projects/csc1142lab7
dbt run --select test_customers
```

**Expected output:**
```
Running with dbt=1.x.x
Found 1 model, 0 tests, 0 snapshots, 0 analyses, 0 macros, 0 operations, 7 sources

Completed successfully
Done. PASS=1 ERROR=0 SKIP=0 TOTAL=1
```

### Understanding Source References

Now that you've defined your sources, you can reference them in any dbt model using:

```sql
{{ source('source_name', 'table_name') }}
```

For example:
- `{{ source('northwind', 'Customers') }}` - references the Customers table
- `{{ source('northwind', 'Orders') }}` - references the Orders table
- `{{ source('northwind', 'Order Details') }}` - references the Order Details table

This is better than hardcoding table names because:
- dbt can track lineage
- You can run source freshness checks
- Changes to source names only need to be updated in one place
- Your documentation stays synchronized

## Create Your First Staging Model

Staging models are the first layer of transformation in dbt. They typically:
- Standardize column names (e.g., `CustomerID` → `customer_id`)
- Apply basic data quality filters (e.g., remove nulls)
- Perform light transformations (e.g., type casting, renaming)
- Create a clean foundation for downstream models

### Step 1: Create the staging model

Using the JupyterLab file browser:
1. Navigate to the `lab_files/models/` directory
2. Open and examine the `stg_customers.sql` file
3. Notice how it:
   - Renames columns to use snake_case naming convention
   - Filters out rows where `CustomerID` is NULL
   - References the source using `{{ source('northwind', 'Customers') }}`
4. Copy the entire contents of the file
5. Navigate to your `dbt_projects/csc1142lab7/models/` directory
6. Create a new file called `stg_customers.sql`
7. Paste the contents into the new file and save it

### Step 2: Run the staging model

```bash
cd ~/dbt_projects/csc1142lab7
dbt run --select stg_customers
```

**Expected output:**
```
Running with dbt=1.x.x
Found 2 models, 0 tests, 0 snapshots, 0 analyses, 0 macros, 0 operations, 7 sources

Completed successfully
Done. PASS=1 ERROR=0 SKIP=0 TOTAL=1
```

This creates a view in your database called `stg_customers` in the `dbo` schema.

### Step 3: Verify the model was created

You can verify the model exists by querying it directly in SQL Server:

```bash
docker exec -it sqlserver-northwind /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C -d Northwind -Q "SELECT TOP 5 * FROM dbo.stg_customers"
```

Or you can run all models to see both test_customers and stg_customers:

```bash
cd ~/dbt_projects/csc1142lab7
dbt run
```

**Expected output:**
```
Running with dbt=1.x.x
Found 2 models, 0 tests, 0 snapshots, 0 analyses, 0 macros, 0 operations, 7 sources

Completed successfully
Done. PASS=2 ERROR=0 SKIP=0 TOTAL=2
```

### Understanding Staging Models

Your `stg_customers` model demonstrates several dbt best practices:

1. **Naming convention**: Staging models are prefixed with `stg_`
2. **Column standardization**: Column names are converted to snake_case
3. **Data quality**: NULL values are filtered out at the staging layer
4. **Source references**: Uses `{{ source() }}` to reference raw tables
5. **Simplicity**: Staging models focus on light transformations only

Later models can now reference this staging model using `{{ ref('stg_customers') }}` instead of querying the raw source directly.

## Create a Fact Model Using Model References

Now that you have a staging model, you can create downstream models that reference it. Fact models typically contain business events or transactions with associated dimensions.

In this step, you'll create a fact table for orders that joins order data with customer information from your staging model.

### Step 1: Create the fact model

Using the JupyterLab file browser:
1. Navigate to the `lab_files/models/` directory
2. Open and examine the `fct_orders.sql` file
3. Notice how it:
   - Uses `{{ source('northwind', 'Orders') }}` to get order data
   - Uses `{{ ref('stg_customers') }}` to reference the staging model you created earlier
   - Joins the two together to create a denormalized fact table
   - Standardizes column names to snake_case
4. Copy the entire contents of the file
5. Navigate to your `dbt_projects/csc1142lab7/models/` directory
6. Create a new file called `fct_orders.sql`
7. Paste the contents into the new file and save it

### Step 2: Run the fact model

```bash
cd ~/dbt_projects/csc1142lab7
dbt run --select fct_orders
```

**Expected output:**
```
Running with dbt=1.x.x
Found 3 models, 0 tests, 0 snapshots, 0 analyses, 0 macros, 0 operations, 7 sources

Completed successfully
Done. PASS=1 ERROR=0 SKIP=0 TOTAL=1
```

Notice that dbt automatically runs `stg_customers` first (if needed) because `fct_orders` depends on it!

### Step 3: Run models with dependencies

You can also run a model and all its upstream dependencies:

```bash
cd ~/dbt_projects/csc1142lab7
dbt run --select +fct_orders
```

The `+` prefix tells dbt to run all upstream models that `fct_orders` depends on.

Or run all models in your project:

```bash
cd ~/dbt_projects/csc1142lab7
dbt run
```

**Expected output:**
```
Running with dbt=1.x.x
Found 3 models, 0 tests, 0 snapshots, 0 analyses, 0 macros, 0 operations, 7 sources

Completed successfully
Done. PASS=3 ERROR=0 SKIP=0 TOTAL=3
```

### Step 4: View the lineage

You can see the dependency graph dbt created:

```bash
cd ~/dbt_projects/csc1142lab7
dbt ls --select +fct_orders
```

**Expected output:**
```
model.csc1142lab7.stg_customers
model.csc1142lab7.fct_orders
```

This shows that `fct_orders` depends on `stg_customers`.

### Understanding the `ref()` Function

The `{{ ref('stg_customers') }}` function is crucial in dbt:

1. **Dependency tracking**: dbt knows `fct_orders` depends on `stg_customers`
2. **Correct build order**: dbt runs `stg_customers` before `fct_orders`
3. **Environment awareness**: `ref()` resolves to the correct schema/database
4. **Lineage documentation**: dbt can visualize your model dependencies

**Key differences**:
- `{{ source() }}` - references raw tables in your database
- `{{ ref() }}` - references other dbt models you've created

### Understanding Fact Models

Your `fct_orders` model demonstrates several concepts:

1. **Naming convention**: Fact models are prefixed with `fct_`
2. **Model references**: Uses `{{ ref() }}` to reference the staging model
3. **Joining data**: Combines order data with customer information
4. **Denormalization**: Creates a wide table suitable for analytics
5. **Dependency management**: dbt ensures models run in the correct order

## Generate and View Documentation

One of dbt's most powerful features is automatic documentation generation. dbt can create a website with interactive documentation of your entire data pipeline.

### Step 1: Generate the documentation

From the terminal in JupyterLab:

```bash
cd ~/dbt_projects/csc1142lab7
dbt docs generate
```

**Expected output:**
```
Running with dbt=1.x.x
Building catalog
Catalog written to target/catalog.json
```

This creates documentation files in the `target/` directory, including:
- `manifest.json` - Complete representation of your dbt project
- `catalog.json` - Metadata about your database tables and columns
- `index.html` - The documentation website

### Step 2: Serve the documentation

Start the documentation web server:

```bash
cd ~/dbt_projects/csc1142lab7
dbt docs serve --port 8080
```

**Expected output:**
```
Serving docs at 0.0.0.0:8080
To access from your system, navigate to http://localhost:8080
```

**Important:** The server will keep running in your terminal. Don't close this terminal window!

### Step 3: View the documentation

Open your web browser and navigate to:
```
http://localhost:8080
```

You should see an interactive documentation website with:

1. **Project Overview** - Summary of your dbt project
2. **Model Lineage Graph** - Visual representation of dependencies
   - Click on any model to see its details
   - Use the graph to understand data flow
3. **Model Documentation** - Detailed info for each model
   - SQL code
   - Column descriptions (from sources.yml)
   - Upstream and downstream dependencies
4. **Source Documentation** - Details about your raw tables

### Exploring the Lineage Graph

The lineage graph (DAG - Directed Acyclic Graph) shows:
- **Green nodes**: Source tables (from your database)
- **Blue nodes**: dbt models you created
- **Arrows**: Dependencies between models

Click on `fct_orders` in the graph to see:
- It depends on `stg_customers` (upstream)
- The SQL code that creates it
- Column-level documentation

### Step 4: Stop the documentation server

When you're done viewing the docs, go back to the terminal and press:
```
Ctrl + C
```

This will stop the documentation server.

### Understanding dbt Documentation

The documentation dbt generates includes:

1. **Automatic**: All models, sources, and their relationships are documented automatically
2. **Column-level**: Descriptions from your YAML files appear in the docs
3. **Interactive**: Click through the lineage graph to explore dependencies
4. **Version-controlled**: Documentation stays in sync with your code
5. **Shareable**: The generated website can be hosted for your team

This makes it easy for analysts and stakeholders to understand:
- What data is available
- Where it comes from
- How it's transformed
- What each column means

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
