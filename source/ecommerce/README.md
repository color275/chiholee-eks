### start
```
export DBUSER="appuser"
export PASSWORD="Appuser12#$"
export PRIMARY_HOST="localhost"
export READONLY_HOST="localhost"
export PORT="3306"
export DBNAME="ecommerce"
uvicorn main:app --port 8000 --reload
```