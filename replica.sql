/*
	A small replication example.
	Includes syntax for multi-source and parallel replication.
	
	For parallel replication and the various binlog settings, see:
	https://kristiannielsen.livejournal.com/18435.html
*/


/*
	Setup Master
*/

-- in my.cnf or my.ini file:

log-bin=mysql-bin
server-id=1

-- if we only want to replicate some databases:
--binlog-do-db=name,name


-- create users for slaves and monitoring tools

CREATE USER 'repl'@'%' IDENTIFIED BY 'prepl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

CREATE USER 'monitor'@'%' IDENTIFIED BY 'pmonitor';
GRANT REPLICATION CLIENT ON *.* TO 'monitor'@'%';

SHOW BINARY LOGS;
SELECT @@global.expire_logs_days;


/*
	SLAVE
*/

server-id=2



/*
	BINLOG
*/

-- master:

FLUSH TABLES WITH READ LOCK;

SHOW MASTER STATUS;


-- slave:

CHANGE MASTER 'master1' TO
	MASTER_HOST = '169.254.80.80',
	MASTER_USER = 'repl',
	MASTER_PASSWORD = 'prepl',
	MASTER_PORT = 3306,
	MASTER_LOG_FILE='mysql-bin.000001',
	MASTER_LOG_POS = 982,
	MASTER_CONNECT_RETRY = 100;

START SLAVE 'master1';


-- slave:

UNLOCK TABLES;

SHOW SLAVE 'master1' STATUS;


-- useful settings for slaves:

SET @@global.default_master_connection = '';
--replicate-do-db=name,name

--slave-parallel-threads=20
slave-parallel-threads=#
SELECT @@global.slave_parallel_max_queued;

