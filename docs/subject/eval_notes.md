# Docker Environment Cleanup Commands

**Preliminary Tests**

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

// ... existing cleanup commands content ...

## `Docker ps -qa`

-q (quiet):
Shows only the numeric IDs
Instead of showing all columns (ID, Image, Command, Created, Status, Ports, Names)
Very useful for scripting or when you only need the container IDs
-a (all):
Shows all containers (not just running ones)
By default, docker ps only shows running containers
With -a, you see both running AND stopped containers


// ... existing cleanup commands and docker ps explanation ...

## Examples of Docker ps Commands

```bash
# Show all running containers
docker ps

# Show all containers (including stopped ones)
docker ps -a

# Show only container IDs of running containers
docker ps -q

# Show only container IDs of all containers
docker ps -qa

# Show the latest created container
docker ps -l

# Show n last created containers
docker ps -n=2  # Shows last 2 containers

# Filter containers by status
docker ps -f "status=exited"
```



## Docker Networks

Docker provides several types of networks for container communication:

### Network Types

1. **Bridge Networks** (Default and Most Common)
   - Creates an internal network where containers can communicate
   - Provides network isolation from non-networked containers
   - Containers can expose ports to the host system
   - Most suitable for standalone containers on a single host
   - Default choice for docker-compose applications

2. **Host Network**
   - Removes network isolation between container and Docker host
   - Container uses host's networking directly
   - Better performance but less secure
   - Not recommended for production multi-container setups

3. **None Network**
   - Completely disables networking
   - Container has only loopback interface
   - Used when network access is not needed

4. **Overlay Networks**
   - Enables container communication across multiple Docker hosts
   - Essential for Docker Swarm services
   - Used in distributed systems

5. **Macvlan Networks**
   - Assigns a MAC address to each container
   - Makes containers appear as physical devices on the network
   - Useful for legacy applications that expect direct network access

### Why Bridge Networks?

Bridge networks are the preferred choice for most Docker applications because they:
- Provide automatic DNS resolution between containers
- Offer network isolation and security
- Allow controlled exposure of ports to the host
- Enable easy container-to-container communication
- Work well with docker-compose and multi-container applications

### Common Network Commands

```bash
# List all networks
docker network ls

# Create a network
docker network create network-name

# Inspect a network
docker network inspect network-name

# Connect a container to a network
docker network connect network-name container-name

# Disconnect a container from a network
docker network disconnect network-name container-name

# Remove a network
docker network rm network-name
```
// ... existing content ...
// ... existing content ...

### Note About Default Networks

When running `docker network rm $(docker network ls -q) 2>/dev/null`, three networks will always remain:

```bash
NETWORK ID     NAME      DRIVER    SCOPE
49143b8f3471   bridge    bridge    local
bf098942fe4b   host      host      local
6d2376033f90   none      null      local
```

These are Docker's default networks and cannot be removed:
- The `bridge` network is the default network for containers
  - Used when you don't specify a network
  - Provides isolation and allows containers to communicate
  - Manages internal IP addresses and routing automatically

- The `host` network is for host network access
  - Removes network isolation between container and host
  - Container shares host's network stack
  - Useful for specific performance or networking requirements

- The `none` network is for complete network isolation
  - Only creates a loopback interface
  - No external network connectivity
  - Used when you want to completely disable networking

Any custom networks (like those created by docker-compose) can be removed, but these three are protected and will persist even after cleanup commands. This is by design, as they provide the fundamental networking capabilities that Docker relies on.

For example, when you run:
```bash
docker network rm $(docker network ls -q) 2>/dev/null
```
- `docker network ls -q` lists all network IDs
- `docker network rm` attempts to remove each network
- `2>/dev/null` suppresses error messages about these protected networks
- Only custom networks will be removed, leaving the three default networks intact