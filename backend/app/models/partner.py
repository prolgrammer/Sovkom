from sqlalchemy import Column, Integer, String, Float
from app.core.database import Base

class Partner(Base):
    __tablename__ = "partners"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, unique=True)
    category = Column(String, nullable=False)
    cashback = Column(Float, nullable=False)