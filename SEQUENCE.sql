/*
	This file contains examples about the SEQUENCE storage engine.
	You can paste the snippets into your favourite MariaDB client and see the results.
	SEQUENCE documentation:
	https://mariadb.com/kb/en/sequence/
*/


INSTALL SONAME 'ha_connect';
SELECT * FROM information_schema.ENGINES 
WHERE ENGINE = 'SEQUENCE' \G


-- SEQUENCE tables are virtual tables, but they are still tables.
-- Thus, in order to query them, we need to select a default database.
CREATE DATABASE IF NOT EXISTS maria10_snippets;
USE maria10_snippets;


-- SEQUENCE is not meant to (and cannot) add a counter to a resultset.
-- This is done via variables.
CREATE OR REPLACE TABLE city (id INT PRIMARY KEY, name VARCHAR(50)) ENGINE = InnoDB;
INSERT INTO city VALUES
(1, 'Milano')
, (2, 'Roma')
, (4, 'Genova')
, (5, 'Verona ')
, (8, 'Bologna')
, (10, 'Firenze')
;
SET @x := 0;
SELECT @x := @x + 1 AS num, name FROM city;


-- Simple sequences
SELECT * FROM seq_1_to_5;
SELECT * FROM seq_5_to_1;
SELECT * FROM seq_0_to_30_step_5;
SELECT -seq FROM seq_0_to_5;


-- SEQUENCE returns a BIGINT UNSIGNED column.
-- To have a negative+positive sequence:
(SELECT -seq AS seq FROM seq_1_to_5)
UNION
(SELECT seq FROM seq_0_to_5)
ORDER BY 1;


-- SEQUENCE is fast, variables are not.
SELECT BENCHMARK(100000000, ( 
	SELECT COUNT(*)FROM 
		(SELECT seq FROM seq_0_to_1000) x
	)
);
SET @x := 0;
SELECT BENCHMARK(100000000, @x + 1);


-- find holes in AUTO_INCREMENT column

SELECT * FROM city;

SELECT s.seq FROM seq_1_to_10 s 
LEFT JOIN city c ON s.seq = c.id 
WHERE c.id IS NULL;


-- Repeating sequences
SELECT seq mod 3 FROM seq_0_to_14;


-- Combo of sequences
SELECT s1.seq AS a, s2.seq AS b 
FROM seq_1_to_3 s1 JOIN seq_1_to_3 s2 
ORDER BY 1, 2;


-- FLOAT sequences
SELECT TRUNCATE(seq / 10, 2) AS seq FROM seq_0_to_10;


-- Chars sequences

SELECT CHAR(seq) FROM seq_97_to_122;

SELECT GROUP_CONCAT(CHAR(seq) SEPARATOR '') 
FROM seq_97_to_122;

SELECT CHAR(seq) chr FROM (
	(SELECT * FROM seq_97_to_122 low)
	UNION
	(SELECT * FROM seq_65_to_90 high)
) c;

-- Temporal sequences

SELECT DATE ('2015.01.01' + INTERVAL (s.seq - 1) DAY) AS day, 
DAYNAME(DATE ('2015.01.01' + INTERVAL (s.seq - 1) DAY)) AS weekday 
FROM (SELECT seq FROM seq_1_to_30) s;
-- working days
SELECT DATE ('2014-01-01' + INTERVAL (s.seq - 1) DAY) AS d 
FROM (SELECT seq FROM seq_1_to_30) s 
WHERE DAYOFWEEK(DATE ('2014-01-01' + INTERVAL (s.seq - 1) DAY)) BETWEEN 2 AND 6;
-- Hours in a day
SELECT TIME '00:00:00' + INTERVAL (s.seq - 1) HOUR AS h 
FROM (SELECT seq FROM seq_1_to_24) s;
-- Halfes of an hour in a day
SELECT TIME '00:00:00' + INTERVAL (30 * s.seq) MINUTE AS m 
FROM (SELECT seq FROM seq_1_to_48) s;


-- Date, datetime or time sequences can be useful to populate tables
-- used by booking/reservation applications.
CREATE OR REPLACE TABLE reservation ENGINE = InnoDB 
SELECT TIME '09:00:00' + INTERVAL (30 * s.seq) MINUTE AS bucket 
FROM (SELECT seq FROM seq_0_to_17) s;
SELECT * FROM reservation;


-- Numeric sequences

SELECT seq * seq AS square, POW(seq, 3) AS cube 
FROM seq_1_to_10;

-- Multiples of 3
SELECT seq FROM seq_3_to_20_step_3;
-- ...of 3 and 5
SELECT DISTINCT a.seq AS a 
FROM seq_3_to_20_step_3 a 
INNER JOIN seq_5_to_20_step_5 b;

-- Multiples of powers of 2
SELECT seq FROM seq_1_to_20 WHERE NOT seq & 1; -- ...of 2

-- Triangolar numbers
SET @part = 0;
SELECT (@part := @part + seq) AS part FROM seq_1_to_10;

-- Factorials
SELECT IF(seq < 2, (@fct := 1), (@fct := @fct * seq)) AS fct 
FROM seq_1_to_10;
-- !5
SELECT MAX(IF(seq < 2, (@fct := 1), (@fct := @fct * seq))) AS fct 
FROM seq_1_to_10;

-- Fibonacci
SELECT seq, 
IF(seq = 0, 0, IF(seq = 1, 
(@a := 0) + (@b := 1) + (@s := 0), 
(@b := LAST_VALUE(LAST_VALUE(@s := (@a + @b), @a := @b), @s)) 
)) AS fibo 
FROM seq_0_to_10;


-- We can cache a frequently used sequence
CREATE TABLE fibonacci ENGINE = MEMORY 
SELECT IF(seq < 2, (@fct := 1), (@fct := @fct * seq)) AS fct 
FROM seq_1_to_10;

