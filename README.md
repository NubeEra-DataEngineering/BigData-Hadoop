# 🐝 Hive Workflow with Oozie using Docker

This guide walks you through running a **Hive job via an Oozie workflow** in a Docker-based Hadoop, Hive, and Oozie setup.

---

## 🧱 Prerequisites

Make sure Docker is installed:

```bash
curl -fsSL https://get.docker.com | sudo sh
```

Start your Docker containers:

```bash
sudo docker compose up -d
```

---

## 🥇 Step 1: Configure `core-site.xml` for proxyuser

### On `hadoop-namenode`:

```bash
sudo docker exec -it hadoop-namenode bash

sed -i '/<\/configuration>/ i\
<property>\n  <name>hadoop.proxyuser.hdfs.hosts</name>\n  <value>*</value>\n</property>\n\n<property>\n  <name>hadoop.proxyuser.hdfs.groups</name>\n  <value>*</value>\n</property>' /etc/hadoop/core-site.xml

exit
```

### On `hadoop-oozie`:

```bash
sudo docker exec -it hadoop-oozie bash

sed -i '/<\/configuration>/ i\
<property>\n  <name>hadoop.proxyuser.hdfs.hosts</name>\n  <value>*</value>\n</property>\n\n<property>\n  <name>hadoop.proxyuser.hdfs.groups</name>\n  <value>*</value>\n</property>' /etc/hadoop/core-site.xml

exit
```

---

## 🥈 Step 2: Create Hive workflow files

### In `hadoop-namenode`:

```bash
sudo docker exec -it hadoop-namenode bash
cd ~

cat > workflow.xml << 'EOF'
<workflow-app name="hive-wf" xmlns="uri:oozie:workflow:0.5">
    <start to="hive-action"/>
    <action name="hive-action">
        <hive xmlns="uri:oozie:hive-action:0.2">
            <job-tracker>${jobTracker}</job-tracker>
            <name-node>${nameNode}</name-node>
            <script>script.q</script>
        </hive>
        <ok to="end"/>
        <error to="fail"/>
    </action>
    <kill name="fail">
        <message>Hive failed: ${wf:errorMessage(wf:lastErrorNode())}</message>
    </kill>
    <end name="end"/>
</workflow-app>
EOF

cat > script.q << 'EOF'
CREATE TABLE IF NOT EXISTS test_table (
    id INT,
    name STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

INSERT INTO TABLE test_table VALUES (1, 'Shoeb'), (2, 'Oozie');

SELECT * FROM test_table;
EOF
```

---

## 🥉 Step 3: Upload files to HDFS

```bash
hdfs dfs -mkdir -p /user/hadoop/oozie-apps/hive
hdfs dfs -put workflow.xml script.q /user/hadoop/oozie-apps/hive/
exit
```

---

## 🏁 Step 4: Run Hive workflow from `hadoop-oozie`

```bash
sudo docker exec -it hadoop-oozie bash
cd /tmp

cat > job.properties << 'EOF'
nameNode=hdfs://hadoop-namenode:8020
jobTracker=hadoop-namenode:8032
queueName=default
oozie.wf.application.path=${nameNode}/user/hadoop/oozie-apps/hive
oozie.use.system.libpath=true
EOF

oozie job -oozie http://localhost:11000/oozie -config job.properties -run
```

---

## 🔍 Check Job Status

```bash
oozie jobs -oozie http://localhost:11000/oozie
oozie job -oozie http://localhost:11000/oozie -info <job-id>
```

---

✅ You're now running a Hive workflow using Oozie in Docker!
