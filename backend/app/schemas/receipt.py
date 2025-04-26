from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class Item(BaseModel):
    name: str
    quantity: int
    price: float
    category: str

class ReceiptCreate(BaseModel):
    user_id: int

class ReceiptResponse(BaseModel):
    id: int
    shop: Optional[str]
    items: Optional[List[Item]]
    total: Optional[float]
    category: Optional[str]
    processed: bool
    created_at: datetime
    minio_url: str

    class Config:
        from_attributes = True