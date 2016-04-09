from sqlalchemy_schema import *
from create_package_database import *

session, engine = session_setup()

## packages with the most conflicts:
## count the number of conflicts for each package id
## descending order
## display package name instead of id

session.query(Package_Function).filter(Package_Function.is_conflict == 0).count()
