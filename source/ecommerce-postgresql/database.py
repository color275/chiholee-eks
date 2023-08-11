from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from config import *

import os

DBUSER = os.getenv("DBUSER")
PASSWORD = os.getenv("PASSWORD")
PRIMARY_HOST = os.getenv("PRIMARY_HOST")
READONLY_HOST = os.getenv("READONLY_HOST")
PORT = os.getenv("PORT")
DBNAME = os.getenv("DBNAME")

# DB_URL = f'postgresql://{DBUSER}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}'
PRIMARY_DB_URL = f'postgresql://{DBUSER}:{PASSWORD}@{PRIMARY_HOST}:{PORT}/{DBNAME}'
READONLY_DB_URL = f'postgresql://{DBUSER}:{PASSWORD}@{READONLY_HOST}:{PORT}/{DBNAME}'

class PrimaryEngineConn:
    def __init__(self):
        self.engine = create_engine(PRIMARY_DB_URL, pool_size=30, max_overflow=1000, pool_recycle=500)
        self.Session = sessionmaker(bind=self.engine)

    def get_session(self):
        session = self.Session()
        try:
            yield session
        finally:
            session.close()

class ReadonlyEngineConn:
    def __init__(self):
        self.engine = create_engine(READONLY_DB_URL, pool_size=30, max_overflow=1000, pool_recycle=500)
        self.Session = sessionmaker(bind=self.engine)

    def get_session(self):
        session = self.Session()
        try:
            yield session
        finally:
            session.close()


# from sqlalchemy import create_engine
# from sqlalchemy import *
# from sqlalchemy.orm import sessionmaker
# from config import *

# import os

# DBUSER = os.getenv("DBUSER")
# PASSWORD = os.getenv("PASSWORD")
# PRIMARY_HOST = os.getenv("PRIMARY_HOST")
# READONLY_HOST = os.getenv("READONLY_HOST")
# PORT = os.getenv("PORT")
# DBNAME = os.getenv("DBNAME")

# PRIMARY_DB_URL = f'mysql+pymysql://{DBUSER}:{PASSWORD}@{PRIMARY_HOST}:{PORT}/{DBNAME}'
# READONLY_DB_URL = f'mysql+pymysql://{DBUSER}:{PASSWORD}@{READONLY_HOST}:{PORT}/{DBNAME}'


# class PrimaryEngineConn:
#     def __init__(self):
#         self.engine = create_engine(PRIMARY_DB_URL, pool_size=30, max_overflow=1000, pool_recycle=500)
#         self.Session = sessionmaker(bind=self.engine)

#     def get_session(self):
#         session = self.Session()
#         try:
#             yield session
#         finally:
#             session.close()

# class ReadonlyEngineConn:
#     def __init__(self):
#         self.engine = create_engine(READONLY_DB_URL, pool_size=30, max_overflow=1000, pool_recycle=500)
#         self.Session = sessionmaker(bind=self.engine)

#     def get_session(self):
#         session = self.Session()
#         try:
#             yield session
#         finally:
#             session.close()            

