from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy import Index
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

## sets up Base as a basic table class for SQLalchemy
Base = declarative_base()

## This is the schema for the R package database
class Package(Base):
    __tablename__ = 'package'
    package_id = Column(Integer, index = True, primary_key = True)
    package_name = Column(String(100))
    functions = relationship('Package_Function', backref = 'package')

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
    packages = relationship('Package_Function', backref = 'function')

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
    ## is this function in this package in conflict with another function?
    is_conflict = Column(Integer, default = 0)
