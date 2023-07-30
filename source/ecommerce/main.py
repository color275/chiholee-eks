from fastapi import FastAPI, Depends, Path, HTTPException, Request, Response
from pydantic import BaseModel
from models import *
from sqlalchemy import text
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse
from fastapi.responses import RedirectResponse

import socket
import os

from domain.customer import customer_router
from domain.product import product_router
from domain.order import order_router
from starlette.middleware.cors import CORSMiddleware

import pytz

import logging
from logging.handlers import RotatingFileHandler


logger = logging.getLogger("access_log")
logger.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

# 파일로 로그 저장
file_handler = logging.FileHandler("access.log")
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)

app = FastAPI()

origins = [
    "http://127.0.0.1:8000",
    "http://127.0.0.1:5173",
    "http://0.0.0.0:8000",
    "http://0.0.0.0:5173",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    # 클라이언트 IP 주소
    client_host = request.client.host

    # HTTP 메소드와 경로
    http_method = request.method
    http_path = request.url.path

    # 실제 요청 처리
    response: Response = await call_next(request)

    # 응답 상태코드
    status_code = response.status_code

    # 로그 기록
    logger.info(f"{client_host} - \"{http_method} {http_path} HTTP/1.1\" {status_code}")

    return response


app.include_router(customer_router.router)
app.include_router(product_router.router)
app.include_router(order_router.router)

@app.get("/")
async def docs():    
    return RedirectResponse(url="/docs")

@app.on_event("startup")
async def startup_event():
    # Set the timezone to Asia/Seoul
    seoul_tz = pytz.timezone("Asia/Seoul")
    pytz.timezone.default = seoul_tz
  

@app.get("/host")
async def host():  
    container_hostname = socket.gethostname()    
    container_ip = socket.gethostbyname(container_hostname)
    host_ip = os.environ.get('HOST_IP')
    host_name = os.environ.get('HOST_NAME')
    
    return {
            "container_ip": container_ip,
            "container_hostname": container_hostname,
            "host_ip": host_ip,
            "host_name": host_name,
           }



@app.get("/log_test")
async def read_root():
    logger.info("Received a request to /")
    return {"Hello": "World"}

