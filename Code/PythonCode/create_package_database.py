import logging

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
    package_name = Column(String(250))
    email = Column(String(250))

class Function(Base):
    __tablename__ = 'function'
    function_id = Column(Integer, index = True, primary_key = True)
    function_name = Column(String(250))
    ## is it camel case, snake case, etc.
    name_case = Column(Integer)

class Package_Function(Base):
    __tablename__ = 'package_function'
    package_id = Column(Integer, ForeignKey('package.package_id'), primary_key = True)
    function_id = Column(Integer, ForeignKey('function.function_id'), primary_key = True)
    ## is the function an S3 or S4 method
    is_method = Column(Boolean)

############################################################################3
############################################################################3
    
def sessionSetup(log = False):
    ## Create an engine to store data in a local directory's
    ## sqlalchemy.db file
    engine=create_engine('sqlite:///R_packages.db')
    if log:
        logging.basicConfig(filename = 'sqlite.log')
        logging.getLogger('sqlalchemy.engine').setLevel(logging.DEBUG)
    ## Create all tables in the engine
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind = engine)
    session = Session()
    return session, engine

## NEXT THING TO DO:
## read in fn_pkg_method.csv
## - iterate through and add information to the database
## this will give us everything but the email info for all conflict functions
## later: add non conflict functions to database?
