from pydantic import BaseModel

class PartnerResponse(BaseModel):
    id: int
    name: str
    category: str
    cashback: float

    class Config:
        from_attributes = True