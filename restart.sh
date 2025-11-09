#!/bin/bash

echo "This will DELETE EVERYTHING and start fresh."
echo "This includes:"
echo "  - All Docker containers and volumes"
echo "  - All changes to dbt_projects/csc1142lab7/"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# Stop and remove containers/volumes
docker compose down -v

# Reset all git changes
git reset --hard
git clean -fdx

# Rebuild and restart
docker compose build --no-cache
docker compose up -d

echo ""
echo "Done! Access JupyterLab at: http://localhost:8888"
