# Inception Project Evaluation Guide

## Introduction

Please comply with the following rules:

- Remain polite, courteous, respectful and constructive throughout the evaluation process. The well-being of the community depends on it.
- Identify with the student or group whose work is evaluated the possible dysfunctions in their project. Take the time to discuss and debate the problems that may have been identified.
- You must consider that there might be some differences in how your peers might have understood the project's instructions and the scope of its functionalities. Always keep an open mind and grade them as honestly as possible. The pedagogy is useful only and only if the peer-evaluation is done seriously.

## Guidelines

- Only grade the work that was turned in the Git repository of the evaluated student or group.
- Double-check that the Git repository belongs to the student(s). Ensure that the project is the one expected. Also, check that 'git clone' is used in an empty folder.
- Check carefully that no malicious aliases was used to fool you and make you evaluate something that is not the content of the official repository.
- To avoid any surprises and if applicable, review together any scripts used to facilitate the grading (scripts for testing or automation).
- If you have not completed the assignment you are going to evaluate, you have to read the entire subject prior to starting the evaluation process.
- If cheating is suspected, the evaluation stops here. Use the available flags to report an empty repository, a non-functioning program, a Norm error, cheating, and so forth.

## Preliminary Tests

1. Any credentials, API keys, environment variables must be set inside a `.env` file during the evaluation. If credentials or API keys are available in the git repository and outside of the `.env` file, the evaluation stops and the mark is 0.

2. Defense can only happen if the evaluated student or group is present. This way everybody learns by sharing knowledge with each other.

3. If no work has been submitted (or wrong files, wrong directory, or wrong filenames), the grade is 0, and the evaluation process ends.

4. For this project, you have to clone their Git repository on their station.

## General Instructions

1. For the entire evaluation process, if you don't know how to check a requirement or verify anything, the evaluated student has to help you.

2. Ensure that all the files required to configure the application are located inside a `srcs` folder. The `srcs` folder must be located at the root of the repository.

3. Ensure that a Makefile is located at the root of the repository.

4. Before starting the evaluation, run this cleanup command:

docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null

5. Docker Configuration Requirements:
   - Read the docker-compose.yml file. There musn't be 'network: host' in it or 'links:'. Otherwise, the evaluation ends now.
   - Read the docker-compose.yml file. There must be 'network(s)' in it. Otherwise, the evaluation ends now.
   - Examine the Makefile and all scripts in which Docker is used. There musn't be '--link' in any of them. Otherwise, the evaluation ends now.
   - Examine the Dockerfiles. If you see 'tail -f' or any command run in background in any of them in the ENTRYPOINT section, the evaluation ends now. Same thing if 'bash' or 'sh' are used but not for running a script (e.g, 'nginx & bash' or 'bash').
   - If the entrypoint is a script (e.g., ENTRYPOINT ["sh", "my_entrypoint.sh"], ENTRYPOINT ["bash", "my_entrypoint.sh"]), ensure it runs no program in background (e.g, 'nginx & bash').
   - Examine all the scripts in the repository. Ensure none of them runs an infinite loop. The following are a few examples of prohibited commands: 'sleep infinity', 'tail -f /dev/null', 'tail -f /dev/random'

## Expected Directory Structure

$> ls -alR
total XX
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 .
drwxrwxrwt 17 wil wil 4096 avril 42 20:42 ..
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 Makefile
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 secrets
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 srcs

./secrets:
total XX
drwxrwxr-x 2 wil wil 4096 avril 42 20:42 .
drwxrwxr-x 6 wil wil 4096 avril 42 20:42 ..
-rw-r--r-- 1 wil wil XXXX avril 42 20:42 credentials.txt
-rw-r--r-- 1 wil wil XXXX avril 42 20:42 db_password.txt
-rw-r--r-- 1 wil wil XXXX avril 42 20:42 db_root_password.txt

./srcs:
total XX
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 .
drwxrwxr-x 3 wil wil 4096 avril 42 20:42 ..
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 docker-compose.yml
-rw-rw-r-- 1 wil wil XXXX avril 42 20:42 .env
drwxrwxr-x 5 wil wil 4096 avril 42 20:42 requirements
