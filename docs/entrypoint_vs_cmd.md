# ENTRYPOINT vs CMD in a Dockerfile

In a Dockerfile, both `ENTRYPOINT` and `CMD` define what runs when a container starts. However, they serve different purposes and have varying levels of flexibility.

## 1. ENTRYPOINT

- **Purpose**: Specifies a fixed command that always runs when the container starts.
- **Override**: Cannot be easily overridden, except by using `--entrypoint` when running the container.
- **Usage**: Typically used to define the main process or executable the container should run.

### Example:

```Dockerfile
ENTRYPOINT ["/usr/sbin/nginx"]
```

- **Behavior**: The container will always run `nginx`, and additional arguments can be passed when running the container:
  ```bash
  docker run mycontainer -g "daemon off;"
  ```

## 2. CMD

- **Purpose**: Provides default arguments for `ENTRYPOINT` or specifies the default command if `ENTRYPOINT` is not used.
- **Override**: Easily overridden by providing a different command when running the container.
- **Usage**: Often used to define default behavior or parameters for the main process.

### Example:

```Dockerfile
CMD ["-g", "daemon off;"]
```

- **Behavior**: If no other command is provided, the container will run with the default arguments from `CMD`. This can be overridden:
  ```bash
  docker run mycontainer echo "Hello, Docker!"
  ```

## 3. Combining ENTRYPOINT and CMD

- **ENTRYPOINT** defines the executable, while **CMD** provides default arguments. Together, they offer flexibility.

### Example:

```Dockerfile
ENTRYPOINT ["/usr/sbin/nginx"]
CMD ["-g", "daemon off;"]
```

- **Behavior**: The container will run `nginx` with the `CMD` arguments, but the arguments can be overridden:
  ```bash
  docker run mycontainer -g "some other option"
  ```

## 4. Overriding ENTRYPOINT with `--entrypoint`

You can override the `ENTRYPOINT` entirely when running a container by using the `--entrypoint` flag.

### Example:

```bash
docker run --entrypoint "/bin/sh" mycontainer -c "echo 'Overridden EntryPoint'"
```

## Summary

- **ENTRYPOINT**: Fixed command that always runs, designed for the container's main executable.
- **CMD**: Default arguments or command that can be easily overridden.
- **Best Practice**: Use `ENTRYPOINT` for the primary executable, and `CMD` for default arguments or secondary commands.
