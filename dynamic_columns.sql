/*
	This file contains examples about Dynamic Columns.
	You can paste the snippets into your favourite MariaDB client and see the results.
	Dynamic Columns documentation:
	https://mariadb.com/kb/en/dynamic-columns/
*/


CREATE DATABASE IF NOT EXISTS maria10_snippets
	DEFAULT CHARACTER SET utf8;
USE maria10_snippets;


CREATE OR REPLACE TABLE product
(
	  id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY
	, name CHAR(50) NOT NULL
	, features BLOB NOT NULL
)
	ENGINE = InnoDB
;

INSERT INTO product (name, features) VALUES
	  ('Big Shirt', COLUMN_CREATE(
			  'size',  'XL'
			, 'color', 'red'
		))
	, ('Small Shirt', COLUMN_CREATE(
			  'size',  'S'
			, 'color', 'blue'
		))
	, ('Super-Book', COLUMN_CREATE(
			  'author', 'Lous Carrol'
			, 'title',  'Alice in Wonderland'
			, 'pages',  300
		))
	;

SELECT id, name, COLUMN_JSON(features) FROM product \G

SELECT id, name, COLUMN_GET(features, 'color' AS CHAR(10)) AS color
	FROM product
	WHERE COLUMN_EXISTS(features, 'size')
;

UPDATE product
	SET features = COLUMN_DELETE(features, 'color')
;
SELECT id, name, COLUMN_LIST(features) FROM product;

UPDATE product
	SET features = COLUMN_ADD(features, 'type', 'T-Shirt')
	WHERE COLUMN_EXISTS(features, 'size')
;
SELECT id, name, COLUMN_JSON(features) FROM product \G


ALTER TABLE product
	ADD COLUMN product_type CHAR(20) GENERATED ALWAYS
		AS (COLUMN_GET(features, 'type' AS CHAR(20))) PERSISTENT,
	ADD INDEX idx_type (product_type)
;
SELECT id, name, product_type FROM product \G


