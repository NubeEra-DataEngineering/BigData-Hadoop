# 🧰 Oozie + Hadoop + Hive + Zookeeper - Dockerized Big Data Stack

This setup runs Apache Oozie with Hadoop HDFS, Hive, and Zookeeper using Docker Compose. It also supports uploading and running Oozie workflows.

---

## 📁 Folder Structure

```
.
├── docker-compose.yml
└── oozie-wf-shell
    ├── action.sh
    ├── job.properties
    └── workflow.xml
├── README.md
└── hadoop-config
    └── core-site.xml
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

Upload oozie-shell-wf folder to HDFS:

```bash
hdfs dfs -mkdir -p /user/hadoop/oozie-apps/shell
hdfs dfs -put workflow.xml echo.sh /user/hadoop/oozie-apps/shell/
```

---

## ▶️ 4. Run Oozie Job

Inside the container Run Oozie Job:

```bash
docker exec -it hadoop-oozie bash

cd oozie-wf-shell/
chmod +x echo.sh
oozie job -oozie http://localhost:11000/oozie -config job.properties -run
```

---

## 📬 Connect

- Oozie Web UI: [http://localhost:11000/oozie](http://localhost:11000/oozie)
- HDFS UI (NameNode): [http://localhost:50070](http://localhost:50070)

---