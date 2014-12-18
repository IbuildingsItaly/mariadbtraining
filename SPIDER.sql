/*
	This file contains examples about the SPIDER storage engine.
	Please copy the data files in the proper directories and adjust the paths.
	Then, you can paste the snippets into your favourite MariaDB client and see the results.
	SPIDER documentation on MariaDB KB:
	https://mariadb.com/kb/en/spider/
	
	SPIDER's official website:
	http://spiderformysql.com/
*/


// MDEV-6096
// MDEV-5632


\W


INSTALL SONAME 'ha_spider';
SELECT * FROM information_schema.ENGINES 
WHERE ENGINE = 'SPIDER' \G
SOURCE /usr/local/mysql/share/install_spider.sql
SOURCE /usr/share/mysql/install_spider.sql


SHOW TABLES FROM mysql LIKE 'spider%';
SHOW VARIABLES LIKE 'spider%';
SHOW STATUS LIKE 'spider%';


CREATE DATABASE IF NOT EXISTS maria10_snippets;
CREATE DATABASE IF NOT EXISTS maria10_snippets_1;
CREATE DATABASE IF NOT EXISTS maria10_snippets_2;
USE maria10_snippets;


CREATE OR REPLACE TABLE maria10_snippets_1.site_user
(
	  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY
	, first_name CHAR(50) NOT NULL
	, last_name CHAR(50) NOT NULL
	, email CHAR(255) NOT NULL
	, UNIQUE INDEX unq_last_name (email)
)
	ENGINE = InnoDB
;

INSERT INTO maria10_snippets_1.site_user (first_name, last_name, email) VALUES
	  ('Mario', 'Rossi', 'mario@rossi.it')
	, ('Mauro', 'Verdi', 'mauro@verdi.it')
	, ('Marco', 'Bianchi', 'marco@bianchi.it')
	;


CREATE OR REPLACE TABLE maria10_snippets_2.site_user
(
	  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY
	, first_name CHAR(50) NOT NULL
	, last_name CHAR(50) NOT NULL
	, email CHAR(255) NOT NULL
	, UNIQUE INDEX unq_last_name (email)
)
	ENGINE = InnoDB
	AUTO_INCREMENT = 10000
;

INSERT INTO maria10_snippets_2.site_user (first_name, last_name, email) VALUES
	  ('Elena', 'Rossi', 'elena@rossi.it')
	, ('Viviana', 'Verdi', 'viviana@verdi.it')
	, ('Monica', 'Bianchi', 'monica@bianchi.it')
	;


CREATE USER 'spider'@'localhost';
SET PASSWORD FOR 'spider'@'localhost' = PASSWORD('pspider');
GRANT ALL ON *.* TO 'spider'@'localhost';


CREATE OR REPLACE TABLE site_user
(
	  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY
	, first_name CHAR(50) NOT NULL
	, last_name CHAR(50) NOT NULL
	, email CHAR(255) NOT NULL
	, UNIQUE INDEX unq_last_name (email)
)
	ENGINE = SPIDER
	COMMENT 'host "127.0.0.1", user "spider", password "pspider", database "maria10_snippets_1", table "site_user"'
;

SELECT * FROM site_user;


CREATE OR REPLACE TABLE site_user
(
	  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY
	, first_name CHAR(50) NOT NULL
	, last_name CHAR(50) NOT NULL
	, email CHAR(255) NOT NULL
	, INDEX unq_last_name (email)
)
	ENGINE = SPIDER
PARTITION BY RANGE (id)
(
	PARTITION p0 VALUES LESS THAN (10000)
		COMMENT = 'host "127.0.0.1", user "spider", password "pspider", database "maria10_snippets_1", table "site_user"',
	PARTITION p1 VALUES LESS THAN (20000)
		COMMENT = 'host "127.0.0.1", user "spider", password "pspider", database "maria10_snippets_2", table "site_user"'
);

SELECT * FROM site_user;



-- @@spider_general_log server

