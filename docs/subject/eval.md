Here is the information you provided formatted into Markdown:

# SCALE FOR PROJECT INCEPTION

## Introduction

**You should evaluate 1 student in this team. Please comply with the following rules:**

- Remain polite, courteous, respectful, and constructive throughout the evaluation process. The well-being of the community depends on it.
- Identify with the student or group whose work is evaluated the possible dysfunctions in their project. Take the time to discuss and debate the problems that may have been identified.
- Consider differences in understanding the project's instructions and the scope of its functionalities. Keep an open mind and grade honestly. The value of pedagogy emerges from serious peer-evaluation.

## Guidelines

- Only grade the work submitted in the Git repository of the evaluated student or group.
- Verify that the Git repository belongs to the student(s) and contains the expected project. Ensure that 'git clone' is used in an empty folder.
- Check for any malicious aliases that might mislead you into evaluating something other than the content of the official repository.
- If applicable, review any scripts used to facilitate grading (scripts for testing or automation) together.
- If you have not completed the assignment you are evaluating, read the entire subject before starting the evaluation.
- Use the available flags to report issues like an empty repository, non-functioning programs, Norm errors, cheating, etc. In these cases, except for cheating, the evaluation process ends and the final grade is 0 or -42 in case of cheating.

## Preliminaries

- If cheating is suspected, stop the evaluation immediately and use the "Cheat" flag. Make this decision calmly and wisely.

## Preliminary Tests

- Any credentials, API keys, or environment variables must be set inside a `.env` file during the evaluation.
- Defense can only happen if the evaluated student or group is present to ensure collaborative learning.

## General Instructions

- Ensure all required files for configuring the application are inside a `srcs` folder at the root of the repository.
- A `Makefile` should be located at the root of the repository.
- Before starting the evaluation, run cleanup commands to remove all Docker instances and images.
- Read the `docker-compose.yml` file for specific configuration checks.

## Project Overview

**The evaluated person should explain:**

- How Docker and docker-compose work.
- The difference between a Docker image used with docker-compose and without.
- The benefit of Docker compared to VMs.
- The pertinence of the directory structure required for this project.

## Docker Basics

- Check each service's Dockerfile and ensure all Docker images are built using docker-compose without crashes.

## Docker Network

- Validate the use of docker-network and run a command to verify the network visibility.

## NGINX with SSL/TLS

- Access the NGINX service configured with SSL/TLS by visiting a specific URL and ensure no access via HTTP.

## WordPress with php-fpm

- Check configurations related to WordPress installation and ensure that it is accessible only via HTTPS.

## MariaDB

- Verify the proper setup of MariaDB, its Dockerfile, and volume configurations.

## Persistence

- After rebooting the virtual machine, ensure that the configurations and data in WordPress and MariaDB persist.

## Bonus

- Evaluate additional services only if the mandatory parts were flawlessly executed.

## Ratings

- Rate from 0 (failed) to 5 (excellent) based on the evaluation criteria met during the defense.

---

### Attachments

- `subject.pdf`

This Markdown structure organizes the information into clear sections and provides a structured outline of the evaluation criteria and processes.
