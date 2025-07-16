Hadoop & Pig
==============================

# Pull the image

```
docker pull usiegj00/hadoop-pig
```

# Start a container

In order to use the Docker image use:

```
docker run -i -t usiegj00/hadoop-pig /etc/bootstrap.sh -bash
```

# Test Pig

Once the container has started, execute
```
pig -x local
```
