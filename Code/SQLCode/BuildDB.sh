#!/usr/bin/bash

# For simplicity, work in the local folder
cp ../../Data/package.csv package.csv
cp ../../Data/function.csv function.csv
cp ../../Data/package_function.csv package_function.csv

# create database and views
/usr/bin/sqlite3 DB.db < BuildDB.sql

# cleanup
rm *.csv
mv DB.db ../../Data/R_packages.db
