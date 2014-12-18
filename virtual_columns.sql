/*
	This file contains examples about Virtual Columns.
	You can paste the snippets into your favourite MariaDB client and see the results.
	Virtual Columns documentation:
	https://mariadb.com/kb/en/virtual-columns/
*/


CREATE DATABASE IF NOT EXISTS maria10_snippets
	DEFAULT CHARACTER SET utf8;
USE maria10_snippets;


CREATE OR REPLACE TABLE site_user
(
	  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY
	, username CHAR(20) NOT NULL
	, pwd CHAR(20) NOT NULL
	, username_normalized CHAR(20)
		GENERATED ALWAYS AS (LOWER(username)) PERSISTENT
	, UNIQUE INDEX unq_last_name (username_normalized)
)
	ENGINE = InnoDB
;

INSERT INTO site_user (username, pwd) VALUES ('paperino', 'donald');
INSERT INTO site_user (username, pwd) VALUES ('PaPeRino', 'duck');


CREATE OR REPLACE TABLE customer
(
	  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY
	, first_name CHAR(50) NOT NULL
	, last_name CHAR(50) NOT NULL
	, last_name_normalized CHAR(50)
		GENERATED ALWAYS AS (REPLACE(REPLACE(last_name, '''', ''), ' ', '')) PERSISTENT
	, UNIQUE INDEX unq_last_name (last_name_normalized)
)
	ENGINE = InnoDB
;

INSERT INTO customer (first_name, last_name) VALUES ('Emma', 'D''Amelia');
SELECT * FROM customer WHERE last_name_normalized LIKE 'damelia';


CREATE OR REPLACE TABLE product
(
	  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY
	, price DECIMAL(7, 2) NOT NULL
	, price_vat DECIMAL(7, 2)
		GENERATED ALWAYS AS (price / 100 * 22) PERSISTENT
)
	ENGINE = InnoDB
;

