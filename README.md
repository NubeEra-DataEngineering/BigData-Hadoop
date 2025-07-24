# 🐘 Dockerized Hadoop and Oozie Workflow Setup

This repository provides a fully Dockerized environment for Hadoop and Oozie, including a working example of a shell-based Oozie workflow.

---

## 📋 Table of Contents

- [Prerequisites](#-prerequisites)
- [Docker Compose Setup](#-docker-compose-setup)
- [Start the Cluster](#-start-the-cluster)
- [Proxy Configuration](#-proxy-configuration)
- [Create Sample Oozie Workflow](#-create-sample-oozie-workflow)
- [Run Oozie Workflow](#-run-oozie-workflow)
- [Access Web Interfaces](#-access-web-interfaces)
- [File Structure](#-file-structure)
- [Summary](#-summary)

---

## 🛠️ Prerequisites

Ensure the following are installed:

- [Docker](https://docs.docker.com/get-docker/)
- Docker Compose

### Install Docker

```bash
curl -fsSL https://get.docker.com | sudo sh
🧱 Docker Compose Setup
Create a file called docker-compose.yml with the following content:

yaml
Copy
Edit
services:
  hadoop-namenode:
    image: bde2020/hadoop-namenode:2.0.0-hadoop2.7.4-java8
    container_name: hadoop-namenode
    environment:
      - CLUSTER_NAME=docker-hadoop
    ports:
      - "50070:50070"
      - "8020:8020"

  hadoop-datanode:
    image: bde2020/hadoop-datanode:2.0.0-hadoop2.7.4-java8
    container_name: hadoop-datanode
    environment:
      - CLUSTER_NAME=docker-hadoop
      - CORE_CONF_fs_defaultFS=hdfs://hadoop-namenode:8020
    depends_on:
      - hadoop-namenode
    ports:
      - "50075:50075"

  hadoop-oozie:
    image: equemuelcompellon/hadoop-oozie
    container_name: hadoop-oozie
    command: oozied.sh run
    ports:
      - "11000:11000"
    environment:
      - FS_DEFAULTFS=hdfs://hadoop-namenode:8020
      - YARN_RESOURCEMANAGER_ADDRESS=hadoop-namenode:8032
      - OOZIE_HADOOP_USER_NAME=hadoop
    depends_on:
      - hadoop-namenode
      - hadoop-datanode
🚀 Start the Cluster
Use the following commands to spin up the environment:

bash
Copy
Edit
nano docker-compose.yml
sudo docker compose up -d
🔧 Proxy Configuration
Update core-site.xml in both hadoop-namenode and hadoop-oozie containers to allow proxy user access.

Edit in hadoop-namenode:
bash
Copy
Edit
sudo docker exec -it hadoop-namenode bash
Inside the container, run:

bash
Copy
Edit
sed -i '/<\/configuration>/ i\
<property>\n\
  <name>hadoop.proxyuser.hdfs.hosts</name>\n\
  <value>*</value>\n\
</property>\n\
\n\
<property>\n\
  <name>hadoop.proxyuser.hdfs.groups</name>\n\
  <value>*</value>\n\
</property>' /etc/hadoop/core-site.xml
Then exit:

bash
Copy
Edit
exit
Edit in hadoop-oozie:
bash
Copy
Edit
sudo docker exec -it hadoop-oozie bash
Run the same sed command as above, then exit:

bash
Copy
Edit
exit
📂 Create Sample Oozie Workflow
Enter NameNode container:
bash
Copy
Edit
sudo docker exec -it hadoop-namenode bash
Create the workflow XML:
bash
Copy
Edit
cat > workflow.xml << 'EOF'
<workflow-app name="sample-wf" xmlns="uri:oozie:workflow:0.5">
    <start to="shell-action"/>
    <action name="shell-action">
        <shell xmlns="uri:oozie:shell-action:0.2">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <exec>echo.sh</exec>
            <file>echo.sh</file>
        </shell>
        <ok to="end"/>
        <error to="fail"/>
    </action>
    <kill name="fail">
        <message>Action failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>
    </kill>
    <end name="end"/>
</workflow-app>
EOF
Create the shell script:
bash
Copy
Edit
cat > echo.sh << 'EOF'
#!/bin/bash
echo "Hello from Oozie Shell Action"
EOF

chmod +x echo.sh
Upload to HDFS:
bash
Copy
Edit
hdfs dfs -mkdir -p /user/hadoop/workflow-app
hdfs dfs -put workflow.xml /user/hadoop/workflow-app/
hdfs dfs -put echo.sh /user/hadoop/workflow-app/

hdfs dfs -mkdir -p /user/hadoop/oozie-apps/shell
hdfs dfs -put workflow.xml echo.sh /user/hadoop/oozie-apps/shell/
Exit the container:

bash
Copy
Edit
exit
▶️ Run Oozie Workflow
Enter Oozie container:
bash
Copy
Edit
sudo docker exec -it hadoop-oozie bash
cd /tmp
Create job.properties file:
bash
Copy
Edit
cat > job.properties << 'EOF'
nameNode=hdfs://hadoop-namenode:8020
jobTracker=hadoop-namenode:8032
queueName=default
oozie.wf.application.path=${nameNode}/user/hadoop/oozie-apps/shell
oozie.use.system.libpath=true
EOF
Submit the job:
bash
Copy
Edit
oozie job -oozie http://localhost:11000/oozie -config job.properties -run
