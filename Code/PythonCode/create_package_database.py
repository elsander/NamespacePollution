import logging
import csv

from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy import create_engine, Index
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import select

from sqlalchemy_schema import *

def session_setup(log = False,
                  database_path = 'sqlite:///../../Data/R_packages.db'):
    ## Create an engine to store data in a local directory's
    ## sqlalchemy.db file
    engine=create_engine(database_path)
    if log:
        logging.basicConfig(filename = 'psql.log')
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
    functions = dict()
    packages = dict()
    with open(table_file, 'rb') as f:
        for line in f:
            line = line.strip().split(',')
            if line[0] not in packages.keys():
                ## select package_id from package where package_name = line[0]
                result = session.query(Package).filter(Package.package_name == line[0])
                if not result:
                    pkg = Package(package_name = line[0])
                    session.add(pkg)
                    session.flush()
                    ## query again to get id number
                    result = session.query(Package).filter(Package.package_name ==
                                                           line[0])
                result = result.first().package_id
                packages[line[0]] = result
            if line[1] not in functions.keys():
                ## select function_id from function where function_name = line[1]
                result = session.query(Function).filter(Function.function_name == line[1])
                if not result:
                    fn = Function(function_name = line[1])
                    session.add(function)
                    session.flush()
                    ## now query again to get the id number
                    result = session.query(Function).filter(Function.function_name ==
                                                            line[1])
                result = result.first().function_id
                functions[line[1]] = result
            session.commit()

            ## now add the line to the linking table
            ## NOTE:
            ## no information about methods or environments for now
            package_function = Package_Function(package_id = packages[line[0]],
                                                function_id = functions[line[1]],
                                                is_method = -1,
                                                environment = 'NA')
            session.add(package_function)
            session.flush()
    session.commit()
    
def dump_package(session, package_file = '../../Data/package.csv'):
    session.query(Package)
    with open(package_file, 'wb') as f:
        outcsv = csv.writer(f)
        records = session.query(Package)
        ## write column names
        outcsv.writerow([str(column.name) for column in Package.__mapper__.columns])
        ## write database entries
        [outcsv.writerow([str(getattr(curr, column.name)) for column in Package.__mapper__.columns]) for curr in records]
