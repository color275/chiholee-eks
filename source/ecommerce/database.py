from sqlalchemy import create_engine
from sqlalchemy import *
from sqlalchemy.orm import sessionmaker
from config import *

import os

DBUSER = os.getenv("DBUSER")
PASSWORD = os.getenv("PASSWORD")
PRIMARY_HOST = os.getenv("PRIMARY_HOST")
READONLY_HOST = os.getenv("READONLY_HOST")
PORT = os.getenv("PORT")
DBNAME = os.getenv("DBNAME")

# DB_URL = f'mysql+pymysql://{DBUSER}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}'
PRIMARY_DB_URL = f'mysql+pymysql://{DBUSER}:{PASSWORD}@{PRIMARY_HOST}:{PORT}/{DBNAME}'
READONLY_DB_URL = f'mysql+pymysql://{DBUSER}:{PASSWORD}@{READONLY_HOST}:{PORT}/{DBNAME}'


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


# class engineconn:

#     def __init__(self):
#         self.engine = create_engine(DB_URL, pool_size=30, max_overflow=1000, pool_recycle=500)
#         self.Session = sessionmaker(bind=self.engine)
#         self.session = self.Session()
#         self.conn = self.engine.connect()

#     def get_session(self):
#         return self.session

#     def get_connection(self):
#         return self.conn
    
# class engineconn:

#     def __init__(self):
#         self.engine = create_engine(DB_URL, pool_size=100, max_overflow=1000, pool_recycle = 500)

#     def sessionmaker(self):
#         Session = sessionmaker(bind=self.engine)
#         session = Session()
#         return session

#     def connection(self):
#         conn = self.engine.connect()
#         return conn
