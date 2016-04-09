import logging
import csv
import subprocess
import ipdb

from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy import create_engine, Index, update
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.sql import select

from sqlalchemy_schema import *

def session_setup(log = False, database_path = 'sqlite:///../../Data/R_packages.db'):
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

def populate_base_table(session, table = 'package',
                        table_file = '../../Data/package.csv'):
    '''This function populates the package table with package names
    from a csv file.'''
    ## get number of lines in package_function to calculate percentages.
    nlines = subprocess.check_output("wc -l " + table_file, shell = True)
    nlines = int(nlines.decode('UTF-8').strip().split(' ')[0])
    k = 0
    with open(table_file, 'r') as f:
        ## first line will be the column names
        col_names = f.readline().strip().split(',')
        ## initialize line_dict
        line_dict = dict()
        for line in f:
            if k % 10000 == 0:
                print("%.4f percent complete" % (k/nlines*100))
            k += 1
            ## strip newline
            line = line.strip().split(',')
            for i in range(len(col_names)):
                line_dict[col_names[i]] = line[i]
            if table == 'package':
                entry = Package(**line_dict)
            elif table == 'function':
                entry = Function(**line_dict)
            else:
                raise ValueError
            session.add(entry)
            session.flush()
    session.commit()
    
def populate_package_function(session,
                       table_file = '../../Data/package_function.csv'):
    '''This function populates the package_function junction table from 
    a csv file.'''
    ## get number of lines in package_function to calculate percentages.
    nlines = subprocess.check_output("wc -l " + table_file, shell = True)
    nlines = int(nlines.decode('UTF-8').strip().split(' ')[0])
    
    ## only run this after the package table has been populated!
    k = 0
    with open(table_file, 'r') as f:
        ## skip header line
        f.readline()
        for line in f:
            if k % 1000 == 0:
                print("%.4f percent complete" % (k/nlines*100))
            k += 1
            line = line.strip().split(',')
            line = [int(entry) for entry in line]
            pkg = session.query(Package).filter(Package.package_id ==
                                                    line[0]).first()
            fn = session.query(Function).filter(Function.function_id ==
                                                line[1]).first()
            junction = Package_Function(package = pkg, function = fn,
                                        is_conflict = line[2])
            session.add(junction)
    session.commit()

def populate_with_conflicts(session,
                            table_file = '../../Data/conflict_adjlist.csv'):
    '''This function updates the package_function junction table to note
    package-function combinations which are conflicts.'''
    ## get number of lines in package_function to calculate percentages.
    nlines = subprocess.check_output("wc -l " + table_file, shell = True)
    nlines = int(nlines.decode('UTF-8').strip().split(' ')[0])
    k = 0
    f_missed = open('../../Data/conflict_missed.csv', 'w')
    with open(table_file, 'r') as f:
        ## skip header line
        f.readline()
        for line_string in f:
            if k % 1000 == 0:
                print("%.4f percent complete" % (k/nlines*100))
            ## line[0] is function, line[1] is package
            line = line_string.strip().split(',')
            try:
                fn_result = session.query(Function).\
                            filter_by(function_name = line[0]).first()
                fn_id = fn_result.function_id
                pkg_result = session.query(Package).\
                             filter_by(package_name = line[1]).first()
                pkg_id = pkg_result.package_id
                pkg_fn = session.query(Package_Function).\
                         filter(Package_Function.function_id == fn_id,
                                Package_Function.package_id == pkg_id).first()
                pkg_fn.is_conflict = 1
                session.flush()
            except:
                f_missed.write(line_string)
            k += 1
    session.commit()
    f_missed.close()

def populate_meta_package(session, table_file):
    pass
    
def populate_meta_function(session, table_file):
    pass
    
def load_database():
    session, engine = session_setup()
    print("Populating package table...")
    populate_base_table(session, table = 'package', table_file = '../../Data/package.csv')
    print("Done!")
    print("Populating function table...")
    populate_base_table(session, table = 'function',
                        table_file = '../../Data/function.csv')
    print("Done!")
    ipdb.set_trace()
    print("Populating package_function table. This may take twenty minutes or more...")
    populate_package_function(session,
                       table_file = '../../Data/package_function.csv')
    print("Done!")
    ipdb.set_trace()
    print("Adding conflicts to package_function table...")
    populate_with_conflicts(session,
                            table_file = '../../Data/conflict_adjlist.csv')
    print("Done!")
    print("Database is stored in ../../Data/R_packages.db")
    return session, engine
    
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


def dump_package_function(session,
                          package_function_file = '../../Data/package_function.csv'):
    with open(package_function_file, 'w') as f:
        outcsv = csv.writer(f)
        records = session.query(Package_Function)
        ## write column names
        outcsv.writerow([str(column.name) for column in Package_Function.__mapper__.columns])
        ## write database entries
        [outcsv.writerow([str(getattr(curr, column.name)) \
                          for column in Package_Function.__mapper__.columns])\
         for curr in records]

def dump_database(session):
    print('Dumping Package table...')
    dump_package(session, package_file = '../../Data/package.csv')
    print('Done!')
    print('Dumping Function table...')
    dump_function(session, function_file = '../../Data/function.csv')
    print('Done!')
    print('Dumping Package_Function table...')
    dump_package_function(session,
                          package_function_file = '../../Data/package_function.csv')
    print('Done!')

def populate_package_function_from_names(session,
                       table_file = '../../Data/pkg_function.csv'):
    '''This function populates the package_function junction table from 
    a csv file. In doing so, it also populates the function table with function
    names.'''
    ## get number of lines in package_function to calculate percentages.
    nlines = subprocess.check_output("wc -l " + table_file, shell = True)
    nlines = int(nlines.decode('UTF-8').strip().split(' ')[0])
    
    k = 0
    with open(table_file, 'r') as f:
        try:
            for line in f:
                k += 1
                if k % 1000 == 0:
                    print("%.4f percent complete" % (k/nlines*100))
                line = line.strip().split(',')
                pkg = session.query(Package).filter(Package.package_name ==
                                                    line[0]).first()
                if not pkg:
                    pkg = Package(package_name = line[0])
                    session.add(pkg)

                fn = session.query(Function).filter(Function.function_name ==
                                                    line[1]).first()
                if not fn:
                    fn = Function(function_name = line[1])
                    session.add(fn)
                if not session.query(Package_Function).\
                   filter(Package_Function.function_id == fn.function_id,
                          Package_Function.package_id == pkg.package_id).first():
                    junction = Package_Function(package = pkg, function = fn)
                    session.add(junction)
                # else:
                #     print(fn.function_name)
                #     print(pkg.package_name)
                #     continue
            session.commit()
        except:
            ipdb.set_trace()
