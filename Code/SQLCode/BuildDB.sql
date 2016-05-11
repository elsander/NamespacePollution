DROP TABLE IF EXISTS package;
DROP TABLE IF EXISTS metapackage;
DROP TABLE IF EXISTS function;
DROP TABLE IF EXISTS metafunction;
DROP TABLE IF EXISTS package_function;
DROP TABLE IF EXISTS tmp;
DROP VIEW IF EXISTS v_all;
DROP VIEW IF EXISTS v_conflict;
DROP VIEW IF EXISTS v_count_conflict_package;
DROP VIEW IF EXISTS v_count_conflict_function;

/*#################################
CREATE TABLE package
#################################*/
.mode csv
.import package.csv tmp
.tables

CREATE TABLE package (
package_id INTEGER PRIMARY KEY UNIQUE, 
package_name TEXT);

INSERT INTO package(
"package_id",
"package_name"
) SELECT 
"package_id",
"package_name" 
FROM tmp;
  
DROP TABLE tmp;
.tables

/*#################################
CREATE TABLE function
#################################*/
.mode csv
.import function.csv tmp
.tables

CREATE TABLE function (
function_id INTEGER PRIMARY KEY UNIQUE, 
function_name TEXT);

INSERT INTO function(
"function_id",
"function_name"
) SELECT 
"function_id",
"function_name" 
FROM tmp;
  
DROP TABLE tmp;
.tables

/*#################################
CREATE TABLE package_function
#################################*/
.mode csv
.import package_function.csv tmp
.tables

CREATE TABLE package_function (
package_id INTEGER,
function_id INTEGER,
is_conflict INTEGER,
FOREIGN KEY(package_id) REFERENCES package(package_id)
FOREIGN KEY(function_id) REFERENCES function(function_id)
);

INSERT INTO package_function(
"package_id",
"function_id",
"is_conflict"
) SELECT 
"package_id",
"function_id",
"is_conflict"
FROM tmp;
  
DROP TABLE tmp;
.tables

/*#################################
Some handy queries and views
#################################*/
CREATE VIEW v_all AS
SELECT package.package_id AS package_id,  
package.package_name AS package_name, 
function.function_id AS function_id, 
function.function_name AS function_name, 
is_conflict
FROM 
package_function 
INNER JOIN package ON package.package_id = package_function.package_id
INNER JOIN function ON function.function_id = package_function.function_id;

CREATE VIEW v_conflict AS
SELECT *
FROM 
v_all
WHERE is_conflict = 1;

CREATE VIEW v_count_conflict_package AS
SELECT package_name, COUNT(is_conflict) AS num_conflicts FROM
v_conflict
GROUP BY package_name
ORDER BY num_conflicts DESC;

CREATE VIEW v_count_conflict_function AS
SELECT function_name, COUNT(is_conflict) AS num_conflicts FROM
v_conflict
GROUP BY function_name
ORDER BY num_conflicts DESC;

