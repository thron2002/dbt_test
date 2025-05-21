cd ../..  # Navigate back to the project root
cat > run_demo.sh << 'EOF'
#!/bin/bash

echo "Starting Data Pipeline Demo"
echo "=============================="

# Check if containers are running
echo "Checking Docker containers status..."
if ! docker ps | grep -q demo-postgres; then
    echo "Starting Docker containers..."
    cd docker
    docker-compose up -d
    cd ..
    sleep 5  # Give containers time to start
else
    echo "Containers are already running"
fi

# Activate virtual environment
echo "Activating Python virtual environment..."
source venv/bin/activate

# Upload data to Minio
echo "Uploading data to Minio..."
python scripts/upload_to_minio.py

# Process data with Spark
echo "Processing data with Spark..."
python scripts/process_with_spark.py

# Run dbt models
echo "Running dbt transformations..."
cd dbt_project/demo_project
dbt run
dbt test

echo "=============================="
echo "Data Pipeline Demo Completed!"
echo "You can access:"
echo "- Minio console at http://localhost:9001 (login: minioadmin/minioadmin)"
echo "- Spark Master UI at http://localhost:8080"
echo "- PostgreSQL at localhost:5432 (login: postgres/postgres)"
echo ""
echo "To connect to PostgreSQL and see the transformed data:"
echo "psql -h localhost -U postgres -d demo -c 'SELECT * FROM mart_customer_summary LIMIT 5;'"
EOF

chmod +x run_demo.sh
