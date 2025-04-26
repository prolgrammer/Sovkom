from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from app.schemas.partner import PartnerResponse
from app.models.partner import Partner
from app.core.database import get_db

router = APIRouter(prefix="/partners", tags=["partners"])

@router.get("/", response_model=List[PartnerResponse])
def get_partners(db: Session = Depends(get_db)):
    partners = db.query(Partner).all()
    return partners