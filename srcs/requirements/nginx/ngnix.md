### Explanation of the Changes:

- **`adduser -D -H -s /bin/false -u 1000 -G www-data www-data`**: This line only adds the `www-data` user to the already existing `www-data` group without creating a new group. The flags are:
  - `-D`: Create a user without a password.
  - `-H`: Do not create a home directory for the user.
  - `-s /bin/false`: Disable shell access for the user.
  - `-u 1000`: Set the user ID to 1000.
  - `-G www-data`: Add the user to the `www-data` group.
