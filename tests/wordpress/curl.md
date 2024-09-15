# Testing Wordpress with curl

To test if WordPress is working using `curl`, you can send HTTP and HTTPS requests to check if the WordPress installation is up and responding. Here's how you can do it for the domain `slombard.42.fr` using `curl` with and without the `-k` flag:

### 1. **HTTP Request (without SSL):**

This checks whether the WordPress site responds over HTTP (non-SSL).

```bash
curl -I http://slombard.42.fr
```

- `-I`: This option fetches only the HTTP headers without the body of the response.
- You should expect a `200 OK` response or a redirect (like `301` or `302`), depending on your configuration.

### 2. **HTTPS Request (with SSL verification):**

This checks whether the WordPress site is reachable over HTTPS with SSL verification (the default behavior).

```bash
curl -I https://slombard.42.fr
```

- If your SSL certificate is properly configured, this command should succeed and return `200 OK` or `301/302` (redirect) along with the SSL details.
- If there is an SSL certificate issue (e.g., expired or invalid certificate), it will fail with an SSL error.

### 3. **HTTPS Request (without SSL verification using `-k` flag):**

If your SSL certificate is self-signed or there are issues with the SSL chain, you can use the `-k` (or `--insecure`) flag to bypass SSL verification and test the WordPress site.

```bash
curl -k -I https://slombard.42.fr
```

- `-k` allows `curl` to ignore SSL certificate errors.
- This is useful for testing if WordPress is accessible even when there are SSL issues. It should still return a `200 OK` or a redirect.

### 4. **HTTP with `curl` verbose mode for detailed output:**

You can use the `-v` option to get more information about the request and response, which is helpful for debugging.

#### HTTP:

```bash
curl -v http://slombard.42.fr
```

#### HTTPS:

```bash
curl -v https://slombard.42.fr
```

#### HTTPS with `-k` (ignore SSL certificate errors):

```bash
curl -v -k https://slombard.42.fr
```

### Expected Output:

- **`200 OK`**: This indicates that WordPress is responding properly.
- **`301` or `302 Redirect`**: This indicates that the site might be redirecting from HTTP to HTTPS or vice versa (which is common when SSL is enforced).
- **SSL Error**: If there’s an SSL issue, `curl` will output details like "SSL certificate problem" unless you use `-k`.
