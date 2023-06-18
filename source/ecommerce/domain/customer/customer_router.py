from fastapi import APIRouter
from fastapi import HTTPException
from models import *
from database import PrimaryEngineConn, ReadonlyEngineConn
from datetime import datetime
import random
from config import *
from datetime import datetime, timedelta
from sqlalchemy import desc
from sqlalchemy import func
from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from sqlalchemy import text

router = APIRouter(
    prefix="/customer",
)

primary = PrimaryEngineConn()
readonly = ReadonlyEngineConn()

@router.get("/")
async def get_all(session: Session = Depends(readonly.get_session)):
    result = session.query(Customer).all()
    return result

@router.get("/get/{id}")
async def get_customer(id: int, session: Session = Depends(readonly.get_session)):
    customer = session.query(Customer).filter(Customer.id == id).first()

    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    customer_dict = customer.__dict__
    customer_dict.pop("_sa_instance_state")

    customer_dict.update(host())

    return customer_dict