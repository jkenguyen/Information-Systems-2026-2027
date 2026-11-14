# Install MySQL & clone sample database

## Install MySQL

MySQL is installed in a separate environment so the server, its data and its configuration can be reset without affecting the host machine.

Input:
```
docker run --name mysql \
        -e MYSQL_ROOT_PASSWORD=root \
        -p 3306:3306 \
        -v mysql-data:/var/lib/mysql \
        -d mysql:26.7.0
```

Output:
```
<docker container id>
```

- `mysql:26.7.0` — pin the exact version instead of `latest`, so the setup is reproducible; the server reports `26.7.0` in `SELECT VERSION()`.
- `--name mysql` — fixed name, so every later command targets the server by name instead of a random id.
- `-e MYSQL_ROOT_PASSWORD=root` — required on first start, otherwise the server refuses to initialise. A weak password is acceptable here because the server is local and disposable.
- `-p 3306:3306` — publish MySQL's default port, so a client on the host can connect to `localhost:3306`.
- `-v mysql-data:/var/lib/mysql` — keep the data files outside the container, so the ~3.9 million loaded rows survive if the container is removed and re-created.
- `-d` — run in the background and get the terminal back for the next steps.

## Clone sample database

The sample data is the `test_db` repository. It is cloned on the host and then copied into the server's environment, because the server can only read files that exist inside it.

Input:
```
git clone https://github.com/datacharmer/test_db
```

Input:
```
docker cp test_db mysql:/tmp
```

Output:
```
Successfully copied 253MB (transferred 253MB) to mysql:/tmp
```

- The repo holds the loader script `employees.sql` plus one dump file per table, 253 MB in total.
- The copy is required because the dumps must be readable by the MySQL client running inside the server environment.

# Install db

## Setup database

Input:
```
docker exec mysql bash -c 'cd /tmp/test_db && mysql --commands -u root -proot < employees.sql'
```

Output:
```
INFO
CREATING DATABASE STRUCTURE
INFO
storage engine: InnoDB
INFO
LOADING departments
INFO
LOADING employees
INFO
LOADING dept_emp
INFO
LOADING dept_manager
INFO
LOADING titles
INFO
LOADING salaries
data_load_time_diff
00:00:21
```

- `docker exec mysql bash -c` — execute the command inside mysql client.
- `bash -c '...'` — run the remainder as one shell line; this is what makes the `cd` and the `<` redirect below possible.
- `cd /tmp/test_db` — `employees.sql` calls `SOURCE load_<table>.dump` with **relative** paths, so it only works from the folder that holds the dumps.
- `mysql -u root -proot` — connect as the `root` user created in the install step.
- `--commands` — enable client-side commands. Since MySQL 9.5 they are disabled by default, and `SOURCE` is a client-side command. Without this flag, the command will throw error incorrect syntax `SOURCE`.
- `< employees.sql` — feed the loader script through standard input instead of typing it into an interactive session.
- The script runs in order: drop and re-create the `employees` database, create the 6 tables with InnoDB, import each table from its dump (the `LOADING ...` lines), then print `data_load_time_diff`.

## Verify the database

A load can finish "successfully" and still be wrong: a truncated dump, a partially imported table or a wrong encoding all leave a working server with incorrect data. The repository ships integrity tests that detect exactly this.

Input:
```
docker exec mysql bash -c 'cd /tmp/test_db && mysql -t -u root -proot --commands < test_employees_sha2.sql'
```

Output:
```
+----------------------+
| INFO                 |
+----------------------+
| TESTING INSTALLATION |
+----------------------+
+--------------+---------------+-----------+
| table_name   | records_match | crc_match |
+--------------+---------------+-----------+
| departments  | OK            | ok        |
| dept_emp     | OK            | ok        |
| dept_manager | OK            | ok        |
| employees    | OK            | ok        |
| salaries     | OK            | ok        |
| titles       | OK            | ok        |
+--------------+---------------+-----------+
+---------+--------+
| summary | result |
+---------+--------+
| CRC     | OK     |
| count   | OK     |
+---------+--------+
```

Both summary lines return `OK`, so the data match with repository expectation.
