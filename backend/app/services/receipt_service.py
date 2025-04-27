import uuid
from datetime import datetime, date
import logging
from typing import Optional

from fastapi import HTTPException
import httpx
from sqlalchemy.orm import Session
from sqlalchemy import and_
import asyncio
from app.models.receipt import Receipt
from app.models.user import User
from app.core.minio import MinioService
from app.core.config import settings

logger = logging.getLogger(__name__)

class ReceiptService:
    def __init__(self):
        self.minio_service = MinioService(bucket_name=settings.MINIO_BUCKET_NAME, auto_start=True)
        self.analytics_service_url = "http://localhost:8000/analyze"  # URL нейронки (заглушка)

    async def upload_receipt(self, db: Session, user_id: int, file_content: bytes, filename: str):
        # Проверяем, существует ли пользователь
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Проверяем формат файла
        file_ext = filename.split('.')[-1].lower()
        if file_ext not in ['pdf', 'jpeg', 'jpg', 'png']:
            raise HTTPException(status_code=400, detail="Unsupported file format")

        # Генерируем уникальный путь для MinIO
        receipt_id = str(uuid.uuid4())
        minio_path = f"user_{user_id}/receipt_{receipt_id}.{file_ext}"

        # Создаем пустую запись в базе
        receipt = Receipt(
            user_id=user_id,
            minio_path=minio_path,
            processed=False,
            created_at=datetime.utcnow()
        )
        db.add(receipt)
        db.commit()
        db.refresh(receipt)

        # Загружаем файл в MinIO
        await self.minio_service.upload_file(
            file_content=file_content,
            filename=minio_path,
            content_type=f"application/{file_ext}" if file_ext == 'pdf' else f"image/{file_ext}"
        )

        # Запускаем фоновую обработку чека
        asyncio.create_task(self.process_receipt_background(db, receipt.id, file_content, minio_path))

        return receipt

    async def process_receipt_background(self, db: Session, receipt_id: int, file_content: bytes, minio_path: str):
        """Фоновая обработка чека"""
        try:
            # Получаем запись чека
            receipt = db.query(Receipt).filter(Receipt.id == receipt_id).first()
            if not receipt:
                logger.error(f"Receipt {receipt_id} not found during processing")
                return

            # Отправляем файл на нейронку (заглушка)
            async with httpx.AsyncClient(timeout=30.0) as client:
                file_ext = minio_path.split('.')[-1].lower()
                files = {"file": (
                    minio_path, file_content, f"application/{file_ext}" if file_ext == 'pdf' else f"image/{file_ext}")}
                response = await client.post(self.analytics_service_url, files=files)
                if response.status_code != 200:
                    raise HTTPException(status_code=response.status_code, detail=response.text)

                # Мок-данные вместо реального ответа нейронки
                result = {
                    "shop": "Магнит",
                    "items": [
                        {"name": "Сёмга филе", "quantity": 1, "price": 350.00, "category": "Рыба"},
                        {"name": "Хлеб", "quantity": 2, "price": 50.00, "category": "Продукты"}
                    ],
                    "total": 450.00,
                    "category": "Продукты"
                }

            # Обновляем запись в базе
            receipt.shop = result["shop"]
            receipt.items = result["items"]
            receipt.total = result["total"]
            receipt.category = result["category"]
            receipt.processed = True
            db.commit()
            logger.info(f"Receipt {receipt_id} processed successfully")

        except httpx.RequestError as e:
            logger.error(f"Neural network connection error for receipt {receipt_id}: {str(e)}")
            # Не удаляем запись и файл, оставляем для повторной обработки
        except Exception as e:
            logger.error(f"Processing error for receipt {receipt_id}: {str(e)}")
            # Не удаляем запись и файл, оставляем для повторной обработки

    def get_user_receipts(self, db: Session, user_id: int, start_date: Optional[date] = None, end_date: Optional[date] = None):
        # Проверяем, существует ли пользователь
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Создаем базовый запрос для обработанных чеков
        query = db.query(Receipt).filter(Receipt.user_id == user_id, Receipt.processed == True)

        # Добавляем фильтрацию по периоду, если указаны даты
        if start_date:
            query = query.filter(Receipt.created_at >= start_date)
        if end_date:
            query = query.filter(Receipt.created_at <= end_date)

        receipts = query.all()
        return receipts