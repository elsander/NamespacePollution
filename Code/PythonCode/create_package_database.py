import logging
import csv

from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy import create_engine, Index, update
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import select

from sqlalchemy_schema import *

import ipdb

def session_setup(log = False, database_path = 'sqlite://'):
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
    with open(table_file, 'rb') as f:
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
    ## only run this after the package table has been populated!
    functions = set([])
    packages = dict()
    k = 0
    with open(table_file, 'rb') as f:
        for line in f:
            k += 1
            if k % 10000 == 0:
                print k
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
    with open(table_file, 'rb') as f:
        ## skip header line
        f.readline()
        for line in f:
            ipdb.set_trace()
            ## line[0] is function, line[1] is package
            line = line.strip().split(',')
            result = session.query(Package_Function).\
                     filter(Package_Function.function_id)
            package_function.update().\
                where(Function.function_name == line[0] &
                      Package.package_name == line[1]).\
                values(is_conflict = 1)
    
    
def dump_package(session, package_file = '../../Data/package.csv'):
    with open(package_file, 'wb') as f:
        outcsv = csv.writer(f)
        records = session.query(Package)
        ## write column names
        outcsv.writerow([str(column.name) for column in Package.__mapper__.columns])
        ## write database entries
        [outcsv.writerow([str(getattr(curr, column.name)) for column in Package.__mapper__.columns]) for curr in records]
