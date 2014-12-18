/*
	This file contains examples about the CONNECT storage engine.
	Please copy the data files in the proper directories and adjust the paths.
	Then, you can paste the snippets into your favourite MariaDB client and see the results.
	CONNECT documentation:
	https://mariadb.com/kb/en/connect/
*/


INSTALL SONAME 'ha_connect';
SELECT * FROM information_schema.ENGINES 
WHERE ENGINE = 'CONNECT' \G


CREATE DATABASE IF NOT EXISTS maria10_snippets;
USE maria10_snippets;


CREATE OR REPLACE TABLE book_xml
(
	ISBN CHAR(15) NOT NULL field_format='@',
	author VARCHAR(50),
	title VARCHAR(100),
	pbl_year CHAR(4)
)
	ENGINE = CONNECT
	CHARACTER SET 'utf8'
	TABLE_TYPE = XML
	FILE_NAME = 'C:\\Program Files\\MariaDB 10.0\\data\\test\\books.xml'
	READONLY = 1
	OPTION_LIST = 'EXPAND=1,MULNODE=author,LIMIT=2';

SELECT * FROM book_xml \G


CREATE OR REPLACE TABLE book_csv
(
	ISBN CHAR(15) NOT NULL,
	author VARCHAR(50) NOT NULL,
	title VARCHAR(100) NOT NULL,
	pbl_year VARCHAR(4) NOT NULL
)
	ENGINE = CONNECT
	CHARACTER SET 'utf8'
	TABLE_TYPE = CSV
	FILE_NAME = 'C:\\Program Files\\MariaDB 10.0\\data\\test\\books.csv'
	READONLY = 1
	HEADER = 1
	SEP_CHAR = ','
	QCHAR = '"'
	ENDING = 1;

SELECT * FROM book_csv \G


CREATE OR REPLACE TABLE book_author
(
  title char(50) NOT NULL,
  author char(50) DEFAULT NULL FLAG=2
)
	ENGINE = CONNECT
	TABLE_TYPE = XCOL
	TABNAME = 'book_csv'
	OPTION_LIST = 'colname=author';

SELECT * FROM book_author;


CREATE OR REPLACE TABLE book
(
	ISBN CHAR(15) NOT NULL,
	author VARCHAR(50) NOT NULL,
	title VARCHAR(100) NOT NULL,
	pbl_year VARCHAR(4) NOT NULL
)
	ENGINE = InnoDB;

INSERT INTO book (ISBN, author, title, pbl_year)
	VALUES ('9782840825685', 'Edgar Lee Masters', 'Spoon River Anthology', '');


CREATE OR REPLACE TABLE book_proxy
	ENGINE = CONNECT
	TABLE_TYPE = PROXY
	TABNAME = book
	OPTION_LIST = 'user=root,password=proot';

SELECT * FROM book_proxy;


CREATE OR REPLACE TABLE book_tbl
	ENGINE = CONNECT
	TABLE_TYPE = TBL
	TABLE_LIST = 'book_xml,book_csv,book_proxy'
	OPTION_LIST = 'user=root,password=proot';

SELECT * FROM book_tbl;


CREATE OR REPLACE TABLE users_dir
(
	drive char(2) NOT NULL,
	path varchar(256) NOT NULL,
	file_name varchar(256) NOT NULL,
	file_type char(4) NOT NULL,
	size double(12,0) NOT NULL FLAG=5,
	full_name VARCHAR(262) AS (CONCAT(drive, path, file_name, file_type)),
	last_modified datetime NOT NULL
)
	ENGINE = CONNECT
	TABLE_TYPE = DIR
	FILE_NAME = 'c:\\Users\\*.*';

SELECT * FROM users_dir \G


CREATE OR REPLACE TABLE show_master_status
	ENGINE = CONNECT
	TABLE_TYPE = MYSQL
	SRCDEF = 'SHOW MASTER STATUS'
	CONNECTION = 'srv_local';


-- only Windows
CREATE OR REPLACE TABLE mac_addr
(
	host VARCHAR(132) NOT NULL FLAG=1,
	card VARCHAR(132) NOT NULL NOT NULL FLAG=11,
	addr CHAR(24) NOT NULL FLAG=12,
	ip CHAR(16) NOT NULL FLAG=15,
	gateway CHAR(16) NOT NULL FLAG=17,
	lease DATETIME NOT NULL FLAG=23
)
	ENGINE = CONNECT
	TABLE_TYPE = MAC;

SELECT * FROM mac_addr;

