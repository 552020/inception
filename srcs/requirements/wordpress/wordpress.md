# Wordpress Docker container

## Dockerfile

### Packages

```docker
RUN apk update && apk add --no-cache \
    php81 php81-fpm php81-mysqli php81-json php81-opcache \
    php81-curl php81-dom php81-exif php81-fileinfo \
    php81-mbstring php81-session php81-xml php81-zip \
    curl bash
```

#### PHP and PHP-FPM Packages:

1. **`php81`**: This is the core PHP package, which includes the PHP interpreter. WordPress is written in PHP, so this package is essential to execute PHP code.

   - **Why needed?** Without PHP, WordPress would not run, as it depends entirely on PHP to generate dynamic content, such as posts and pages.

2. **`php81-fpm`**: PHP-FPM (FastCGI Process Manager) is a PHP daemon that listens for incoming requests (from Nginx) and processes PHP files. It’s crucial when you're running PHP in a separate container from your web server (Nginx).
   - **Why needed?** Since you're not running PHP directly within Nginx, PHP-FPM is used to process PHP code in a more efficient, scalable way, listening on port 9000.

#### Additional PHP Extensions:

WordPress has several dependencies on specific PHP extensions, which provide additional functionality. Here’s why each is included:

3. **`php81-mysqli`**: This is the MySQL Improved extension for PHP. It allows PHP to connect to a MySQL/MariaDB database and run SQL queries.

   - **Why needed?** WordPress requires database connectivity to function, as it stores all posts, users, settings, etc., in the MariaDB database. Without this extension, WordPress wouldn't be able to interact with the database.

4. **`php81-json`**: This provides support for JSON (JavaScript Object Notation) in PHP. JSON is commonly used to exchange data between the server and clients.

   - **Why needed?** WordPress and many plugins use JSON to handle data, such as in REST API responses or in settings stored as JSON.

5. **`php81-opcache`**: This is a PHP extension that caches precompiled script bytecode in memory, which improves PHP performance by reducing the need to recompile PHP scripts on every request.

   - **Why needed?** Opcache enhances performance, which is particularly useful in production environments where speed and efficiency are important.

6. **`php81-curl`**: This is a library used to make HTTP requests from PHP. Many plugins and themes use CURL to send requests to external APIs or services.

   - **Why needed?** WordPress itself, as well as various plugins, use CURL for tasks such as fetching external resources or integrating with third-party services (e.g., for updates or API calls).

7. **`php81-dom`**: This extension allows PHP to work with XML documents and the Document Object Model (DOM). It’s required by certain WordPress features and plugins.

   - **Why needed?** WordPress core and some plugins use DOM for parsing XML data or working with HTML-like structures.

8. **`php81-exif`**: The EXIF extension is used for reading metadata from images (like camera information, orientation, etc.). WordPress uses this to handle image uploads.

   - **Why needed?** When users upload photos, WordPress often uses EXIF data to automatically rotate images or retrieve additional image information.

9. **`php81-fileinfo`**: This provides functionality for determining the file type of a given file. It is used by WordPress to handle file uploads and media types.

   - **Why needed?** Fileinfo helps WordPress validate and correctly process files uploaded by users, ensuring they are the correct type (e.g., images, documents).

10. **`php81-mbstring`**: This extension provides multibyte string functions, allowing WordPress to correctly handle text with special characters and different encodings.

- **Why needed?** WordPress operates in many languages, and mbstring ensures proper handling of multibyte character encodings like UTF-8, which is essential for displaying non-Latin characters.

11. **`php81-session`**: This extension provides support for PHP sessions, which allow data to persist between requests (such as user login sessions).

- **Why needed?** WordPress uses PHP sessions to manage user logins, temporary data, and certain features, particularly in the admin panel.

12. **`php81-xml`**: Provides XML parsing capabilities to PHP. WordPress uses XML for various tasks, such as importing/exporting data or handling API responses.

- **Why needed?** XML is a common data format in WordPress (especially for things like RSS feeds), and many plugins rely on this extension.

13. **`php81-zip`**: This extension allows PHP to read and create ZIP files. It's often used by WordPress for plugin and theme installation, which involves downloading and extracting ZIP archives.

- **Why needed?** WordPress uses the zip extension to handle uploading, installing, and updating plugins and themes, which are distributed as ZIP files.

#### Other Utilities:

14. **`curl`**: A command-line tool for transferring data using various protocols (HTTP, FTP, etc.). It’s used to download WordPress during the build process.

- **Why needed?** Curl is used in the Dockerfile to download the WordPress tarball from the official site.

15. **`bash`**: A shell program that allows you to interact with the container in case you need to debug or manually execute commands. It's not essential for production but useful during development or troubleshooting.

- **Why needed?** It's not strictly necessary for WordPress to run, but it can help in debugging during container development.

#### Summary of Necessity:

- **Absolutely required for WordPress to run:** `php81`, `php81-fpm`, `php81-mysqli`, `php81-json`, `php81-curl`, `php81-session`.
- **Highly recommended (commonly used by WordPress features and plugins):** `php81-opcache`, `php81-dom`, `php81-exif`, `php81-fileinfo`, `php81-mbstring`, `php81-xml`, `php81-zip`.
- **Optional but useful for container development and debugging:** `curl`, `bash`.

### Installation

...

## www.conf

```
[www]
user = www-data
group = www-data
listen = wordpress:9000
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
clear_env = no
```

Yes, all of these directives in Yann’s `www.conf` file for PHP-FPM serve specific purposes related to managing PHP processes, handling FastCGI requests, and ensuring proper permissions and security. However, depending on the scale of your setup and specific needs, some of these directives could be tweaked or simplified. Let's go over each one and its purpose:

### 1. **[www]**

- **Meaning:** This defines the pool name. In PHP-FPM, pools are separate configurations for handling PHP processes. The `[www]` pool is the default pool name.
- **Is it necessary?** Yes, you need a pool name, and `[www]` is the default.

### 2. **user = www-data**

- **Meaning:** This directive sets the user under which the PHP-FPM worker processes will run. `www-data` is a standard user in web server configurations (also used by Nginx or Apache) with restricted permissions for security.
- **Is it necessary?** Yes, it's important to define this to ensure that PHP processes run under a restricted user, minimizing the security risk if a vulnerability is exploited.

### 3. **group = www-data**

- **Meaning:** This directive sets the group under which the PHP-FPM worker processes will run. Like the `user` directive, `www-data` is a standard group for web services.
- **Is it necessary?** Yes, defining the group is equally important to control file and resource access permissions for the PHP processes.

### 4. **listen = wordpress:9000**

- **Meaning:** This sets the **address and port** where PHP-FPM listens for incoming FastCGI requests from Nginx. In this case, PHP-FPM will listen on port 9000 for the service named `wordpress` within the Docker network.
- **Is it necessary?** Yes, this is crucial. Without this, PHP-FPM wouldn’t know where to accept FastCGI requests. The value can be either a TCP address (`0.0.0.0:9000` or `wordpress:9000`) or a Unix socket path (`/var/run/php/php-fpm.sock`).

- In Yann's case, **TCP is being used**, which is common in Docker environments where services communicate over an internal network.

### 5. **listen.owner = www-data**

- **Meaning:** This sets the owner of the listening socket (if using a Unix socket) or port (in this case, `9000`). It defines who has permission to access and manage the socket.
- **Is it necessary?** It is **only required if using a Unix socket**. Since Yann is using a TCP port (`wordpress:9000`), this directive is not strictly necessary in this configuration.

### 6. **listen.group = www-data**

- **Meaning:** This sets the group of the listening socket or port, similarly to `listen.owner`.
- **Is it necessary?** Like `listen.owner`, this is **only necessary if using a Unix socket**. Since Yann is using a TCP port, this directive is not required here.

### 7. **pm = dynamic**

- **Meaning:** This directive sets the process manager mode. In `dynamic` mode, the number of PHP-FPM worker processes changes dynamically based on the traffic load. PHP-FPM will spawn or kill worker processes as needed, allowing it to scale up or down depending on demand.
- **Is it necessary?** Yes, the `pm` directive is critical for managing how PHP-FPM handles requests. Choosing the right mode (`dynamic`, `static`, or `ondemand`) depends on the expected traffic. `dynamic` is generally a good choice for most cases.

### 8. **pm.max_children = 5**

- **Meaning:** This sets the maximum number of child processes (worker processes) that PHP-FPM can create. It limits the number of simultaneous requests PHP can handle.
- **Is it necessary?** Yes, this is crucial for controlling resource usage. The value you choose for `pm.max_children` depends on the resources available on your server (CPU, RAM) and the expected traffic. For small setups, 5 may be reasonable, but for larger setups, you would likely need to increase this number.

### 9. **pm.start_servers = 2**

- **Meaning:** This sets the number of child processes that PHP-FPM starts when it first launches. These processes are pre-forked and ready to handle requests immediately.
- **Is it necessary?** Yes, this helps control how PHP-FPM behaves at startup. You want enough initial servers to handle some load, but not so many that they waste resources when idle.

### 10. **pm.min_spare_servers = 1**

- **Meaning:** This sets the minimum number of idle worker processes that should always be available. If the number of idle processes falls below this value, PHP-FPM will create more processes to ensure quick handling of incoming requests.
- **Is it necessary?** Yes, it's important to ensure there are always idle processes ready to handle new requests. The value can be adjusted based on your traffic.

### 11. **pm.max_spare_servers = 3**

- **Meaning:** This sets the maximum number of idle worker processes that PHP-FPM should maintain. If the number of idle processes exceeds this value, PHP-FPM will kill some idle processes to conserve resources.
- **Is it necessary?** Yes, setting a maximum helps control resource usage by preventing too many idle processes from hanging around.

### 12. **clear_env = no**

- **Meaning:** This controls whether PHP-FPM should clear all environment variables before starting PHP processes. Setting this to `no` means environment variables will not be cleared, allowing you to pass environment variables (like database credentials) into the PHP processes.
- **Is it necessary?** Yes, it’s often useful to keep environment variables available for PHP processes, especially in Docker environments where configuration often relies on passing variables via `docker-compose` or `.env` files.

---

### Summary of Necessity and Purpose:

| Directive                    | Necessary? | Purpose                                                                                                   |
| ---------------------------- | ---------- | --------------------------------------------------------------------------------------------------------- |
| **[www]**                    | Yes        | Defines the PHP-FPM pool.                                                                                 |
| **user = www-data**          | Yes        | Sets the user under which PHP-FPM runs. Security-related.                                                 |
| **group = www-data**         | Yes        | Sets the group under which PHP-FPM runs. Security-related.                                                |
| **listen = wordpress:9000**  | Yes        | Defines where PHP-FPM listens for incoming FastCGI requests (here, on port 9000 via TCP).                 |
| **listen.owner = www-data**  | No (TCP)   | Sets the owner of the socket. Necessary for Unix sockets, not for TCP.                                    |
| **listen.group = www-data**  | No (TCP)   | Sets the group of the socket. Necessary for Unix sockets, not for TCP.                                    |
| **pm = dynamic**             | Yes        | Defines the process management mode (dynamic scaling of worker processes).                                |
| **pm.max_children = 5**      | Yes        | Limits the maximum number of PHP-FPM worker processes to prevent resource exhaustion.                     |
| **pm.start_servers = 2**     | Yes        | Sets how many worker processes are pre-started when PHP-FPM launches.                                     |
| **pm.min_spare_servers = 1** | Yes        | Ensures that at least one idle worker process is always available.                                        |
| **pm.max_spare_servers = 3** | Yes        | Limits the maximum number of idle worker processes to prevent resource waste.                             |
| **clear_env = no**           | Yes        | Allows environment variables (like database credentials) to be passed to PHP processes. Useful in Docker. |

### Conclusion:

All these directives are generally useful, but the `listen.owner` and `listen.group` are not necessary in a TCP-based setup (since TCP doesn't require setting ownership like Unix sockets do). However, they can be left in without causing issues, especially if you decide to switch to Unix sockets in the future.

For your own project, you can adopt this configuration as a starting point and adjust values like `pm.max_children`, `pm.min_spare_servers`, and `pm.max_spare_servers` based on the resources available and the expected load.
