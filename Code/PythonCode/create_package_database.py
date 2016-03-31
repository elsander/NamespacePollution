import logging
import csv
import subprocess

from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy import create_engine, Index, update
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import select

from sqlalchemy_schema import *

import ipdb

def session_setup(log = False, database_path = 'sqlite://'):
    '''This function sets up a sqlalchemy session, intializing the session
    and engine. Optionally, it intializes logging.'''
    ## this default database path corresponds to creating the database in memory
    ##                  database_path = 'sqlite:///../../Data/R_packages.db'):
    ## Create an engine to store data in a local directory's
    ## sqlalchemy.db file
    engine=create_engine(database_path)
    if log:
        logging.basicConfig(filename = 'sqlite.log')
        logging.getLogger('sqlalchemy.engine').setLevel(logging.DEBUG)
    ## Create all tables in the engine
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind = engine)
    session = Session()
    return session, engine

def populate_package(session, table_file = '../../Data/package.csv'):
    '''This function populates the package table with package names
    from a csv file.'''
    with open(table_file, 'r') as f:
        ## first line will be the column names
        col_names = f.readline().strip().split(',')
        ## initialize line_dict
        line_dict = dict()
        for line in f:
            ## strip newline
            line = line.strip().split(',')
            for i in range(len(col_names)):
                line_dict[col_names[i]] = line[i]
            package = Package(**line_dict)
            session.add(package)
            session.flush()
    session.commit()

def populate_package_function(session,
                       table_file = '../../Data/package_function.csv'):
    '''This function populates the package_function junction table from 
    a csv file. In doing so, it also populates the function table with function
    names.'''
    ## get number of lines in package_function to calculate percentages.
    nlines = subprocess.check_output("wc -l " + table_file, shell = True)
    nlines = nlines.decode('UTF-8').strip().split(' ')[0]
    
    ## only run this after the package table has been populated!
    functions = set([])
    packages = dict()
    k = 0
    with open(table_file, 'r') as f:
        for line in f:
            k += 1
            if k % 10000 == 0:
                print(k/nlines)
            line = line.strip().split(',')
            if line[0] not in packages.keys():
                pkg = session.query(Package).filter(Package.package_name ==
                                                    line[0]).first()
                if pkg:
                    packages[line[0]] = pkg
                else:
                    pkg = Package(package_name = line[0])
            if line[1] not in functions:
                functions.add(line[1])
                fn = Function(function_name = line[1])
            else:
                fn = session.query(Function).filter(Function.function_name ==
                                                    line[1]).first()
            junction = Package_Function(package = pkg, function = fn)
            session.add(junction)
            session.commit()

def populate_with_conflicts(session,
                            table_file = '../../Data/conflict_adjlist.csv'):
    '''This function updates the package_function junction table to note
    package-function combinations which are conflicts.'''
    ## get number of lines in package_function to calculate percentages.
    nlines = subprocess.check_output("wc -l " + table_file, shell = True)
    nlines = nlines.decode('UTF-8').strip().split(' ')[0]
    k = 0
    
    with open(table_file, 'r') as f:
        ## skip header line
        f.readline()
        for line in f:
            if k % 10000 == 0:
                print(k/nlines)
            ## line[0] is function, line[1] is package
            line = line.strip().split(',')
            try:
                fn_result = session.query(Function).filter_by(function_name = line[0])
                fn_id = fn_result.first().function_id
                pkg_result = session.query(Package).filter_by(package_name = line[1])
                pkg_id = pkg_result.first().package_id
                pkg_fn = session.query(Package_Function).\
                         filter_by(function_id = fn_id, package_id = pkg_id).first()
                pkg_fn.is_conflict = 1
                session.flush()
            except:
                pass
                # print(line)
            k += 1
    session.commit()
    
def load_database():
    session, engine = session_setup()
    print("Populating package table...")
    populate_package(session, table_file = '../../Data/package.csv')
    print("Done!")
    print("Populating function and package_function tables. This may take twenty minutes or more...")
    populate_package_function(session,
                       table_file = '../../Data/package_function.csv')
    print("Done!")
    print("Adding conflicts to package_function table...")
    populate_with_conflicts(session,
                            table_file = '../../Data/conflict_adjlist.csv')
    print("Done!")
    print("Database is stored in R_pkgs.db")
    
def dump_package(session, package_file = '../../Data/package.csv'):
    with open(package_file, 'w') as f:
        outcsv = csv.writer(f)
        records = session.query(Package)
        ## write column names
        outcsv.writerow([str(column.name) for column in Package.__mapper__.columns])
        ## write database entries
        [outcsv.writerow([str(getattr(curr, column.name)) \
                          for column in Package.__mapper__.columns]) for curr in records]

def dump_function(session, function_file = '../../Data/function.csv'):
    with open(function_file, 'w') as f:
        outcsv = csv.writer(f)
        records = session.query(Function)
        ## write column names
        outcsv.writerow([str(column.name) for column in Function.__mapper__.columns])
        ## write database entries
        [outcsv.writerow([str(getattr(curr, column.name)) \
                          for column in Function.__mapper__.columns]) for curr in records]


def dump_package_function(session, function_file = '../../Data/package_function.csv'):
    with open(package_function_file, 'w') as f:
        outcsv = csv.writer(f)
        records = session.query(Package_Function)
        ## write column names
        outcsv.writerow([str(column.name) for column in Package_Function.__mapper__.columns])
        ## write database entries
        [outcsv.writerow([str(getattr(curr, column.name)) \
                          for column in Package_Function.__mapper__.columns])\
         for curr in records]
