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

### Step 1: Copy the sources configuration file

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

### Step 2: Verify your sources configuration

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

### Step 3: Test querying a source

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

Start the documentation web server in the background:

```bash
cd ~/dbt_projects/csc1142lab7
nohup dbt docs serve --host 0.0.0.0 --port 8080 > /dev/null 2>&1 &
```

This starts the server in the background so you can continue using your terminal. The server will keep running until you stop it or restart the container.

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

When you're done viewing the docs, you can stop the server:

```bash
# Find the process ID
ps aux | grep "dbt docs serve"

# Kill the process (replace <PID> with the actual process ID)
kill <PID>
```

Or to kill all dbt docs servers:
```bash
pkill -f "dbt docs serve"
```

The server will also automatically stop when you restart the Docker container.

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

## Understanding Materialization: Tables vs Views

By default, all your dbt models are materialized as **views** (as configured in `dbt_project.yml`). Views are virtual tables that run the SQL query every time they're queried. For frequently accessed or complex models, you may want to materialize them as **tables** instead.

### Step 1: Update fct_orders to use table materialization

Open your `fct_orders.sql` file in the `dbt_projects/csc1142lab7/models/` directory and add this configuration at the very top of the file:

```sql
{{ config(materialized='table') }}

SELECT
    o.OrderID as order_id,
    o.OrderDate as order_date,
    o.CustomerID as customer_id,
    c.company_name,
    c.country,
    o.Freight as freight_cost
FROM {{ source('northwind', 'Orders') }} o
LEFT JOIN {{ ref('stg_customers') }} c
    ON o.CustomerID = c.customer_id
```

The `{{ config(materialized='table') }}` line tells dbt to create a physical table instead of a view.

### Step 2: Run the model with table materialization

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

Notice in the logs that dbt will now:
1. Drop the existing view (if it exists)
2. Create a physical table instead
3. Insert the data into the table

### Step 3: Verify the table was created

You can verify that `fct_orders` is now a table (not a view) by querying SQL Server:

```bash
docker exec -it sqlserver-northwind /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C -d Northwind -Q "SELECT TABLE_NAME, TABLE_TYPE FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'fct_orders'"
```

**Expected output:**
```
TABLE_NAME    TABLE_TYPE
fct_orders    BASE TABLE
```

If it were still a view, it would show `VIEW` instead of `BASE TABLE`.

### Understanding Materialization Types

dbt supports several materialization strategies:

1. **View** (default)
   - Creates a virtual table
   - Query runs every time the view is queried
   - **Pros**: Always up-to-date, no storage overhead
   - **Cons**: Can be slow for complex queries
   - **Best for**: Simple transformations, infrequently queried models

2. **Table**
   - Creates a physical table with data stored on disk
   - Query runs once during `dbt run`, results are stored
   - **Pros**: Fast query performance
   - **Cons**: Takes up storage, can become stale
   - **Best for**: Complex transformations, frequently queried models, fact tables

3. **Incremental** (not covered in this lab)
   - Only processes new/changed data
   - **Best for**: Very large datasets, append-only data

4. **Ephemeral** (not covered in this lab)
   - No database object created, only used in CTEs
   - **Best for**: Intermediate transformations

### When to Use Tables vs Views

**Use tables for:**
- Fact tables with complex joins or aggregations
- Models queried frequently by end users
- Models with expensive computations
- Final models in your DAG

**Use views for:**
- Staging models (simple transformations)
- Models that need to always reflect current data
- Intermediate models only used by other dbt models
- When storage is a concern

### Performance Comparison

Try querying both models to see the performance difference:

```bash
# Query the view (stg_customers)
docker exec -it sqlserver-northwind /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C -d Northwind -Q "SELECT COUNT(*) FROM dbo.stg_customers"

# Query the table (fct_orders)
docker exec -it sqlserver-northwind /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C -d Northwind -Q "SELECT COUNT(*) FROM dbo.fct_orders"
```

For simple models like these, the difference may be negligible. But for complex models with multiple joins and aggregations, tables can be significantly faster.

## Create a Data Mart for Analytics

Data marts are the final layer in your dbt project - they're business-specific datasets designed for end users and BI tools. They often contain aggregations, metrics, and derived calculations that answer specific business questions.

In this step, you'll create a customer summary mart that aggregates order information by customer.

### Step 1: Create the customer summary mart

Using the JupyterLab file browser:
1. Navigate to the `lab_files/models/marts/` directory
2. Open and examine the `customer_summary.sql` file
3. Notice how it:
   - Uses `{{ config(materialized='table') }}` because it's a final output table
   - References `{{ ref('fct_orders') }}` - building on top of your fact table
   - Aggregates data using GROUP BY to create customer-level metrics
   - Calculates useful business metrics: total orders, freight costs, date ranges
4. Copy the entire contents of the file
5. Navigate to your `dbt_projects/csc1142lab7/models/marts/` directory
6. Create a new file called `customer_summary.sql`
7. Paste the contents into the new file and save it

### Step 2: Run the data mart

```bash
cd ~/dbt_projects/csc1142lab7
dbt run --select customer_summary
```

**Expected output:**
```
Running with dbt=1.x.x
Found 4 models, 0 tests, 0 snapshots, 0 analyses, 0 macros, 0 operations, 7 sources

Completed successfully
Done. PASS=1 ERROR=0 SKIP=0 TOTAL=1
```

dbt will automatically build the entire dependency chain:
1. `stg_customers` (if not already built)
2. `fct_orders` (if not already built)
3. `customer_summary` (the new mart)

### Step 3: Query the customer summary

Let's see the results:

```bash
docker exec -it sqlserver-northwind /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -C -d Northwind -Q "SELECT TOP 10 * FROM dbo.customer_summary ORDER BY total_orders DESC"
```

This shows the top 10 customers by number of orders, with all their aggregated metrics.

### Step 4: View the complete lineage

Now you can see the full data pipeline:

```bash
cd ~/dbt_projects/csc1142lab7
dbt ls --select +customer_summary
```

**Expected output:**
```
model.csc1142lab7.stg_customers
model.csc1142lab7.fct_orders
model.csc1142lab7.customer_summary
```

This shows the complete dependency chain from source → staging → fact → mart.

You can also visualize this in the dbt docs. If you still have the docs server running, refresh your browser and click on the lineage graph to see how `customer_summary` connects to the entire pipeline.

### Understanding Data Marts

Your `customer_summary` mart demonstrates several key concepts:

1. **Aggregation Layer**: Transforms row-level data into summary metrics
2. **Business Logic**: Encodes business rules (e.g., what makes a "customer summary")
3. **Performance**: Pre-aggregated data for fast BI tool queries
4. **Dependency Chain**: Builds on top of `fct_orders`, which builds on `stg_customers`
5. **Materialization**: Always a table for fast query performance

### Typical dbt Project Structure

Your project now follows a common dbt pattern:

```
models/
├── sources.yml           # Raw data definitions
├── stg_customers.sql     # Staging: Light transformations
├── fct_orders.sql        # Fact: Business events with joins
└── marts/
    └── customer_summary.sql  # Mart: Aggregated metrics for analytics
```

This layered approach (staging → facts → marts) is a best practice because:
- **Staging**: Standardizes raw data
- **Facts**: Joins and combines data
- **Marts**: Aggregates for specific use cases
- Each layer builds on the previous one
- Changes ripple through the dependency graph automatically

### Business Use Cases for Data Marts

The `customer_summary` mart can answer questions like:
- Which customers order most frequently?
- What's the average shipping cost per customer?
- Who are our newest vs. oldest customers?
- Which countries have the highest freight costs?

BI tools (like Tableau, Power BI, Looker) would typically connect directly to this mart rather than the raw tables or staging models.

## Add Data Quality Tests

Data quality testing is crucial for ensuring your transformations produce reliable data. dbt makes it easy to add tests directly in your YAML schema files.

In this step, you'll add tests to ensure data quality in your staging models.

### Step 1: Create the staging schema file

Using the JupyterLab file browser:
1. Navigate to the `lab_files/models/staging/` directory
2. Open and examine the `schema.yml` file
3. Notice how it defines:
   - Model name (`stg_customers`)
   - Column descriptions
   - Tests on specific columns:
     - `unique` - ensures no duplicate values
     - `not_null` - ensures no NULL values
4. Copy the entire contents of the file
5. Navigate to your `dbt_projects/csc1142lab7/models/staging/` directory
6. Create a new file called `schema.yml`
7. Paste the contents into the new file and save it

### Step 2: Move stg_customers to the staging folder

For better organization, move your `stg_customers.sql` file into the `staging` folder:

1. In JupyterLab file browser, locate `dbt_projects/csc1142lab7/models/stg_customers.sql`
2. Drag and drop it into the `staging` folder (or cut and paste)
3. Your file should now be at `dbt_projects/csc1142lab7/models/staging/stg_customers.sql`

### Step 3: Run the tests

Now run dbt tests to validate your data:

```bash
cd ~/dbt_projects/csc1142lab7
dbt test
```

**Expected output:**
```
Running with dbt=1.x.x
Found 4 models, 3 tests, 0 snapshots, 0 analyses, 0 macros, 0 operations, 7 sources

Running tests...
Completed successfully
Done. PASS=3 ERROR=0 SKIP=0 TOTAL=3
```

This runs all 3 tests:
1. `customer_id` is unique
2. `customer_id` is not null
3. `country` is not null

### Step 4: Run tests for a specific model

You can run tests for just one model:

```bash
cd ~/dbt_projects/csc1142lab7
dbt test --select stg_customers
```

### Step 5: View test results in detail

To see more details about what tests are running:

```bash
cd ~/dbt_projects/csc1142lab7
dbt test --select stg_customers --verbose
```

### Step 6: Run both build and test together

You can run models and tests in one command:

```bash
cd ~/dbt_projects/csc1142lab7
dbt build
```

This command:
1. Runs all models in dependency order
2. Runs all tests after each model is built
3. Shows a comprehensive summary

**Expected output:**
```
Running with dbt=1.x.x
Found 4 models, 3 tests, 0 snapshots, 0 analyses, 0 macros, 0 operations, 7 sources

Building models...
Testing models...

Completed successfully
Done. PASS=7 ERROR=0 SKIP=0 TOTAL=7
```

(4 models built + 3 tests passed = 7 total)

### Understanding dbt Tests

dbt provides several built-in tests:

1. **unique** - Ensures column values are unique (no duplicates)
2. **not_null** - Ensures column has no NULL values
3. **accepted_values** - Ensures column only contains specific values
4. **relationships** - Ensures referential integrity between tables

### Adding More Tests

You can add tests to other models too. For example, add this to your `schema.yml`:

```yaml
  - name: fct_orders
    description: "Order facts with customer information"
    columns:
      - name: order_id
        description: "Unique order identifier"
        tests:
          - unique
          - not_null
      - name: customer_id
        description: "Customer who placed the order"
        tests:
          - not_null
```

Then run `dbt test` again to see the new tests execute.

### Why Data Testing Matters

Data quality tests help you:
- **Catch issues early**: Find data problems before they reach production
- **Document assumptions**: Tests make your data quality expectations explicit
- **Prevent regressions**: Tests fail if your transformations break
- **Build trust**: Stakeholders can trust data that's been tested
- **Debug faster**: Failed tests pinpoint exactly what's wrong

In production dbt projects, tests are typically run:
- After every `dbt run` in CI/CD pipelines
- On a schedule to monitor data quality
- Before promoting changes to production

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
