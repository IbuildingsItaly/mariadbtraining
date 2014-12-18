/*
	This file contains examples about OQGRAPH.
	You can paste the snippets into your favourite MariaDB client and see the results.
	
	OQGRAPH documentation on MariaDB KB:
	https://mariadb.com/kb/en/oqgraph-overview/
	
	Official site (Open Query):
	http://openquery.com/graph
*/


INSTALL SONAME 'ha_oqgraph';
SELECT * FROM information_schema.ENGINES 
WHERE ENGINE = 'OQGRAPH' \G


CREATE DATABASE IF NOT EXISTS maria10_snippets
	DEFAULT CHARACTER SET utf8;
USE maria10_snippets;


CREATE OR REPLACE TABLE foaf
(
	  person_a INT UNSIGNED NOT NULL
	, person_b INT UNSIGNED NOT NULL
	, PRIMARY KEY (person_a, person_b)
	, KEY (person_b)
)
	ENGINE = InnoDB
;

INSERT INTO foaf (person_a, person_b)
	  (1,   2)
	, (1,   3)
	, (1,   4)
	, (2,   20)
	, (3,   30)
	, (20,  100)
	, (30,  100)
	, (100, 20)
	, (100, 30)
	;


CREATE OR REPLACE TABLE foaf_oq
(
	  latch VARCHAR(32) NULL
	, origid BIGINT UNSIGNED NULL
	, destid BIGINT UNSIGNED NULL
	, weight DOUBLE NULL
	, seq BIGINT UNSIGNED NULL
	, linkid BIGINT UNSIGNED NULL
	, KEY (latch, origid, destid) USING HASH
	, KEY (latch, destid, origid) USING HASH
)
	ENGINE = OQGRAPH
	DATA_TABLE = 'foaf'
	ORIGID = 'person_a'
	DESTID = 'person_b'
;

SELECT * FROM foaf_oq;


-- shortest path
SELECT *
	FROM foaf_oq
	WHERE latch='breadth_first'
		AND origid = 20
		AND destid = 30
;

-- destinations
SELECT *
	FROM foaf_oq
	WHERE latch = 'dijkstras'
		AND origid = 2
;

-- proveniences
SELECT *
	FROM foaf_oq
	WHERE latch = 'dijkstras'
		AND destid = 2
;

