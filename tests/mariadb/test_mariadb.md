# MariaDB Docker Setup with Volume Mounting

## 1. **Build** the Docker Image

```bash
docker build -t test-mariadb-img .
```

- `-t test-mariadb-img`: This tags the image with the name `test-mariadb-img`.
- `.`: The dot tells Docker to use the `Dockerfile` in the current directory.

## 2. **Run** the Docker Container with Volume Mounting

After building the image, we run the container with a mounted volume for data persistence. The mounted volume ensures that the data inside MariaDB persists even if the container is stopped or removed.

```bash
docker run --name test-mariadb-ctn -p 3306:3306 -v ./mysqldata:/var/lib/mysql test-mariadb-img
```

- `--name test-mariadb-ctn`: This names the container `test-mariadb-ctn` for easy identification.
- `-p 3306:3306`: This maps port 3306 of the container to port 3306 on your host, allowing access to MariaDB from outside the container.
- `-v ./mysqldata:/var/lib/mysql`: This mounts the local `./mysqldata` directory from the host machine to `/var/lib/mysql` inside the container, ensuring data persistence.
- `test-mariadb-img`: This is the name of the Docker image you just built.

### 3. Verify Data Persistence

Once the container is running, you can verify that the data is being stored in the local directory `./mysqldata` on the host machine. The MariaDB data directory inside the container (`/var/lib/mysql`) will be synced with `./mysqldata` on the host.

### 4. Optional: Enter the Running Container

If you want to interact with the running container (for example, to inspect logs, configuration files, or execute MySQL commands), you can enter the container's shell using:

```bash
docker exec -it test-mariadb-ctn /bin/bash
```

- `-it`: This makes the terminal interactive.
- `test-mariadb-ctn`: The name of the running container.
- `/bin/bash`: The command to start a bash shell inside the container.

### 5. Stop and Remove the Container (Optional)

If you need to stop the container, press `CTRL + C` in the terminal running the container (since it's not in detached mode). Alternatively, you can use the following commands:

- **Stop the container**:

  ```bash
  docker stop test-mariadb-ctn
  ```

- **Remove the container**:

  ```bash
  docker rm test-mariadb-ctn
  ```

These commands will stop and remove the container if it's no longer needed.

## Summary of Commands

1. **Build the Docker image**:

   ```bash
   docker build -t test-mariadb-img .
   ```

2. **Run the Docker container with volume mounted**:

   ```bash
   docker run --name test-mariadb-ctn -p 3306:3306 \
   -v ./mysqldata:/var/lib/mysql test-mariadb-img
   ```

3. **Optional: Enter the running container**:

   ```bash
   docker exec -it test-mariadb-ctn /bin/bash
   ```

4. **Stop the container**:

   ```bash
   docker stop test-mariadb-ctn
   ```

5. **Remove the container**:

   ```bash
   docker rm test-mariadb-ctn
   ```

## Notes

- Ensure that the `./mysqldata` directory exists before running the container. If it doesn’t exist, Docker will create it.
- The container will run in the foreground (non-detached mode), allowing you to see logs and interact with MariaDB directly.
