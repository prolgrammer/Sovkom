from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import date
from app.schemas.receipt import ReceiptCreate, ReceiptResponse, ReceiptFilter
from app.services.receipt_service import ReceiptService
from app.core.database import get_db
from app.core.minio import MinioService
from app.core.config import settings

router = APIRouter(prefix="/receipts", tags=["receipts"])

@router.post("/upload", response_model=ReceiptResponse)
async def upload_receipt(
    user_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    receipt_service = ReceiptService()
    file_content = await file.read()
    receipt = await receipt_service.upload_receipt(db, user_id, file_content, file.filename)

    # Генерируем временную ссылку на файл в MinIO
    minio_service = MinioService(bucket_name=settings.MINIO_BUCKET_NAME, auto_start=False)
    minio_url = minio_service.get_file_url(receipt.minio_path)

    # Создаем объект ответа с minio_url
    return ReceiptResponse(
        id=receipt.id,
        shop=receipt.shop,
        items=receipt.items,
        total=receipt.total,
        category=receipt.category,
        processed=receipt.processed,
        created_at=receipt.created_at,
        minio_url=minio_url
    )

@router.get("/", response_model=List[ReceiptResponse])
def get_receipts(
    user_id: int = Query(...),
    start_date: Optional[date] = Query(None),
    end_date: Optional[date] = Query(None),
    db: Session = Depends(get_db)
):
    receipt_service = ReceiptService()
    receipts = receipt_service.get_user_receipts(db, user_id, start_date, end_date)

    minio_service = MinioService(bucket_name=settings.MINIO_BUCKET_NAME, auto_start=False)
    result = []
    for receipt in receipts:
        minio_url = minio_service.get_file_url(receipt.minio_path)
        result.append(ReceiptResponse(
            id=receipt.id,
            shop=receipt.shop,
            items=receipt.items,
            total=receipt.total,
            category=receipt.category,
            processed=receipt.processed,
            created_at=receipt.created_at,
            minio_url=minio_url
        ))

    return result