from sqlalchemy import Column, Integer, String, Float, ForeignKey, Boolean, DateTime, JSON
from app.core.database import Base

class Receipt(Base):
    __tablename__ = "receipts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    shop = Column(String, nullable=True)
    items = Column(JSON, nullable=True)  # Список товаров в формате JSON
    total = Column(Float, nullable=True)
    category = Column(String, nullable=True)
    minio_path = Column(String, nullable=False)  # Путь к файлу в MinIO
    processed = Column(Boolean, default=False, nullable=False)  # Статус обработки
    created_at = Column(DateTime, nullable=False)