#!/bin/bash

# Start SQL Server in the background
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to start up
echo "Waiting for SQL Server to start..."
sleep 10s

# Wait until SQL Server is ready to accept connections
echo "Checking SQL Server availability..."
for i in {1..50};
do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -Q "SELECT 1" &> /dev/null
    if [ $? -eq 0 ]
    then
        echo "SQL Server is ready!"
        break
    else
        echo "Waiting for SQL Server to be ready... ($i/50)"
        sleep 1
    fi
done

# Create the Northwind database
echo "Creating Northwind database..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -C -Q "CREATE DATABASE Northwind"

if [ $? -eq 0 ]
then
    echo "Created empty northwind database"
else
    echo "ERROR: Failed to create Northwind database"
    exit 1
fi

# Run the Northwind installation script
echo "Installing Northwind tables and data..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SA_PASSWORD" -d Northwind -i /usr/src/app/instnwnd.sql -C

if [ $? -eq 0 ]
then
    echo "Northwind database installed successfully!"
else
    echo "ERROR: Failed to install Northwind database"
    exit 1
fi

# Keep the container running
wait
