import logging
import csv

from sqlalchemy import Column, ForeignKey, Integer, String, Float, Boolean
from sqlalchemy import create_engine, Index
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, backref, sessionmaker
from sqlalchemy.sql import select

## sets up Base as a basic table class for SQLalchemy
Base = declarative_base()

## This is the schema for the R package database
class Package(Base):
    __tablename__ = 'package'
    package_id = Column(Integer, index = True, primary_key = True)
    package_name = Column(String(100))

class MetaPackage(Base):
    __tablename__ = 'metapackage'
    package_id = Column(Integer, ForeignKey('package.package_id'),
                        index = True, primary_key = True)
    ## hash of first part of email address
    email_start = Column(String(100))
    ## email domain
    email_end = Column(String(100))

class Function(Base):
    __tablename__ = 'function'
    function_id = Column(Integer, index = True, primary_key = True)
    function_name = Column(String(100))

class MetaFunction(Base):
    __tablename__ = 'metafunction'
    function_id = Column(Integer, ForeignKey('function.function_id'),
                         index = True, primary_key = True)
    ## is it camel case, snake case, etc.
    name_case = Column(Integer)

class Package_Function(Base):
    __tablename__ = 'package_function'
    package_id = Column(Integer, ForeignKey('package.package_id'), primary_key = True)
    function_id = Column(Integer, ForeignKey('function.function_id'), primary_key = True)
    ## is the function an S3 or S4 method
    is_method = Column(Boolean)
    ## is the function imported from another library
    environment = Column(String(100))

############################################################################
############################################################################
    
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

def populate_package(session, package_file = '../../Data/packages.csv'):
    with open(package_file, 'rb') as f:
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

def dump_package(session, package_file = '../../Data/packages.csv'):
    session.query(Package)
    with open(package_file, 'wb') as f:
        outcsv = csv.writer(f)
        records = session.query(Package)
        ## write column names
        outcsv.writerow([str(column.name) for column in Package.__mapper__.columns])
        ## write database entries
        [outcsv.writerow([str(getattr(curr, column.name)) for column in Package.__mapper__.columns]) for curr in records]
