# Step 1: Start containers
docker compose up -d

# Step 2: Access Hive server container
docker exec -it docker-hadoop-hive-parquet-hive-server-1 bash

# Step 3: Connect to Hive using Beeline
beeline -u jdbc:hive2://localhost:10000 -n hive

# Step 4: Run queries
SHOW DATABASES;

# Step 5: Stop containers
docker compose down
