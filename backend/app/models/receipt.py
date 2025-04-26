from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.sql.sqltypes import DateTime
from app.core.database import Base

class Receipt(Base):
    __tablename__ = "receipts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    store_name = Column(String, nullable=False)
    total_amount = Column(Float, nullable=False)
    category = Column(String, nullable=False)
    minio_path = Column(String, nullable=False)  # Ссылка на файл в MinIO
    created_at = Column(DateTime, nullable=False)