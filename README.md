
# Docker-Based Hadoop and Oozie Setup

This guide provides a step-by-step approach to set up a basic Hadoop and Oozie environment using Docker Compose. It includes all necessary commands, configuration, and a sample Oozie workflow.

---

## 🐳 Prerequisites

Install Docker using the official script:

```bash
curl -fsSL https://get.docker.com | sudo sh
```

---

## 🧱 Create `docker-compose.yml`

Create a file named `docker-compose.yml`:

```yaml
services:
  hadoop-namenode:
    image: bde2020/hadoop-namenode:2.0.0-hadoop2.7.4-java8
    container_name: hadoop-namenode
    environment:
      - CLUSTER_NAME=docker-hadoop
    ports:
      - "50070:50070"   # NameNode web UI
      - "8020:8020"     # HDFS RPC for clients/DataNodes

  hadoop-datanode:
    image: bde2020/hadoop-datanode:2.0.0-hadoop2.7.4-java8
    container_name: hadoop-datanode
    environment:
      - CLUSTER_NAME=docker-hadoop
      - CORE_CONF_fs_defaultFS=hdfs://hadoop-namenode:8020
    depends_on:
      - hadoop-namenode
    ports:
      - "50075:50075"   # DataNode web UI

  hadoop-oozie:
    image: equemuelcompellon/hadoop-oozie
    container_name: hadoop-oozie
    command: oozied.sh run
    ports:
      - "11000:11000"   # Oozie web UI
    environment:
      - FS_DEFAULTFS=hdfs://hadoop-namenode:8020
      - YARN_RESOURCEMANAGER_ADDRESS=hadoop-namenode:8032
      - OOZIE_HADOOP_USER_NAME=hadoop
    depends_on:
      - hadoop-namenode
      - hadoop-datanode
```

---

## 🚀 Start the Cluster

```bash
sudo docker compose up -d
```

---

## 🔧 Configure Proxy User in `core-site.xml`

### 1. Inside `hadoop-namenode`

```bash
sudo docker exec -it hadoop-namenode bash
```

```bash
sed -i '/<\/configuration>/ i<property>\n  <name>hadoop.proxyuser.hdfs.hosts</name>\n  <value>*</value>\n</property>\n\n<property>\n  <name>hadoop.proxyuser.hdfs.groups</name>\n  <value>*</value>\n</property>' /etc/hadoop/core-site.xml
```

```bash
exit
```

### 2. Inside `hadoop-oozie`

```bash
sudo docker exec -it hadoop-oozie bash
```

```bash
sed -i '/<\/configuration>/ i<property>\n  <name>hadoop.proxyuser.hdfs.hosts</name>\n  <value>*</value>\n</property>\n\n<property>\n  <name>hadoop.proxyuser.hdfs.groups</name>\n  <value>*</value>\n</property>' /etc/hadoop/core-site.xml
```

```bash
exit
```

---

## 📂 Create Sample Oozie Workflow

### Inside `hadoop-namenode`:

```bash
sudo docker exec -it hadoop-namenode bash
```

Create the workflow:

```bash
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
```

Create the shell script:

```bash
cat > echo.sh << 'EOF'
#!/bin/bash
echo "Hello from Oozie Shell Action"
EOF

chmod +x echo.sh
```

Upload to HDFS:

```bash
hdfs dfs -mkdir -p /user/hadoop/workflow-app
hdfs dfs -put workflow.xml /user/hadoop/workflow-app/
hdfs dfs -put echo.sh /user/hadoop/workflow-app/

hdfs dfs -mkdir -p /user/hadoop/oozie-apps/shell
hdfs dfs -put workflow.xml echo.sh /user/hadoop/oozie-apps/shell/
```

```bash
exit
```

---

## ▶️ Run Oozie Job

### Inside `hadoop-oozie`:

```bash
sudo docker exec -it hadoop-oozie bash
cd /tmp
```

Create `job.properties`:

```bash
cat > job.properties << 'EOF'
nameNode=hdfs://hadoop-namenode:8020
jobTracker=hadoop-namenode:8032
queueName=default
oozie.wf.application.path=${nameNode}/user/hadoop/oozie-apps/shell
oozie.use.system.libpath=true
EOF
```

Submit the job:

```bash
oozie job -oozie http://localhost:11000/oozie -config job.properties -run
```

---

## ✅ Verification

- Visit the **Oozie Web UI**: http://localhost:11000/oozie
- Check **Hadoop NameNode UI**: http://localhost:50070
- Validate job status via CLI or UI.

---

## 📌 Notes

- Ensure HDFS is formatted and started before Oozie jobs are submitted.
- If jobs fail, check logs inside containers for detailed errors.

---

## 📎 References

- [Docker Hadoop Images](https://hub.docker.com/u/bde2020)
- [Oozie Official Docs](https://oozie.apache.org/)
