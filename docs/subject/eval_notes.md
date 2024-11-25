# Docker Environment Cleanup Commands

## Complete Cleanup Command

```bash
docker stop $(docker ps -qa)
docker rm $(docker ps -qa)
docker rmi -f $(docker images -qa)
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls -q) 2>/dev/null
```

## Command Breakdown

### 1. Stop All Containers

```bash
docker stop $(docker ps -qa)
```

- `docker ps -qa`: Lists all container IDs (running and stopped)
- `docker stop`: Stops all running containers
- `$()` executes the inner command first and passes the result

### 2. Remove All Containers

```bash
docker rm $(docker ps -qa)
```

- Removes all containers that were stopped in the previous step

### 3. Remove All Images

```bash
docker rmi -f $(docker images -qa)
```

- `docker images -qa`: Lists all image IDs
- `docker rmi -f`: Forcefully removes all Docker images
- `-f` flag forces removal even if an image is used by a stopped container

### 4. Remove All Volumes

```bash
docker volume rm $(docker volume ls -q)
```

- `docker volume ls -q`: Lists all volume IDs
- `docker volume rm`: Removes all Docker volumes
- Deletes all persistent data stored in Docker volumes

### 5. Remove All Networks

```bash
docker network rm $(docker network ls -q) 2>/dev/null
```

- `docker network ls -q`: Lists all network IDs
- `docker network rm`: Removes all custom Docker networks
- `2>/dev/null`: Suppresses error messages
- Note: Default networks (`bridge`, `host`, `none`) cannot be removed

## Summary of Actions

- Stops all containers
- Removes all containers
- Removes all images
- Removes all volumes
- Removes all custom networks

## ⚠️ Warning

This is a "nuclear option" that will delete ALL Docker resources on your system:

- All running containers
- All stored data in volumes
- All downloaded/built images
- All custom networks

Use this command sequence when you need to completely clean your Docker environment and start fresh.

## `Docker ps -qa`

-q (quiet):
Shows only the numeric IDs
Instead of showing all columns (ID, Image, Command, Created, Status, Ports, Names)
Very useful for scripting or when you only need the container IDs
-a (all):
Shows all containers (not just running ones)
By default, docker ps only shows running containers
With -a, you see both running AND stopped containers

```bash
# Shows only running containers with full details

docker ps

# Shows all containers (running and stopped) with full details

docker ps -a

# Shows only IDs of running containers

docker ps -q

# Shows IDs of all containers (running and stopped)

docker ps -qa
```
