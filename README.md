# 🧰 Oozie + Hadoop + Hive + Zookeeper - Dockerized Big Data Stack

This setup runs Apache Oozie with Hadoop HDFS, Hive, and Zookeeper using Docker Compose. It also supports uploading and running Oozie workflows.

---

## 📁 Folder Structure

```
project-root/
├── docker-compose.yml
├── hadoop-config/
│   └── core-site.xml
└── oozie-hive-wf/
    ├── workflow.xml
    └── job.properties
```

---

## 📦 Prerequisites

- Docker
- Docker Compose
- Basic familiarity with Hadoop and Oozie

---

## 🚀 1. Start Containers

```bash
docker-compose up -d
```

---

## 📤 2. Upload Oozie Workflow to HDFS

Upload oozie-hive-wf folder to oozie container

```bash
docker ps ./oozie-hive-wf oozie:/opt/oozie/oozie-hive-wf
```

Enter the Oozie container:

```bash
docker exec -it oozie bash
```

Upload workflow to HDFS:

```bash
hdfs dfs -mkdir -p /user/oozie-hive-wf
hdfs dfs -put /opt/oozie/oozie-hive-wf /user/oozie-hive-wf/
```

---

## 📝 3. Example job.properties

In `oozie-hive-wf/job.properties`, define:

```properties
nameNode=hdfs://namenode:8020
jobTracker=resourcemanager:8032
queueName=default
oozie.wf.application.path=${nameNode}/user/oozie-hive-wf/oozie-hive-wf
oozie.use.system.libpath=true
```

---

## ▶️ 4. Run Oozie Job

Inside the container:

```bash
cd /opt/oozie/oozie-hive-wf
oozie job -oozie http://localhost:11000/oozie -config job.properties -run
```

---

## 📬 Connect

- Oozie Web UI: [http://localhost:11000/oozie](http://localhost:11000/oozie)
- HDFS UI (NameNode): [http://localhost:50070](http://localhost:50070)

---

## ✅ Next Steps

- Create Hive actions in your workflows
- Integrate Spark or Pig jobs
- Automate workflow uploads and runs via script
