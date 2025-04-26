from minio import Minio
from minio.error import S3Error
import io
import logging
from datetime import timedelta
from app.core.config import settings
from minio_runner import minio_runner
import atexit

logger = logging.getLogger(__name__)

class MinioService:
    def __init__(self, bucket_name: str, auto_start: bool = True):
        if auto_start:
            minio_runner.start()
            atexit.register(minio_runner.stop)

        self.client = Minio(
            f"localhost:{settings.MINIO_PORT}",
            access_key=settings.MINIO_ACCESS_KEY,
            secret_key=settings.MINIO_SECRET_KEY,
            secure=False
        )
        self.bucket_name = bucket_name
        self._ensure_bucket_exists()

    def _ensure_bucket_exists(self):
        try:
            if not self.client.bucket_exists(self.bucket_name):
                self.client.make_bucket(self.bucket_name)
                logger.info(f"Created bucket {self.bucket_name}")
        except S3Error as e:
            logger.error(f"Error checking/creating bucket: {e}")
            raise

    async def upload_file(
            self,
            file_content: bytes,
            filename: str,
            content_type: str = "image/jpeg"
    ) -> str:
        try:
            self.client.put_object(
                self.bucket_name,
                filename,
                io.BytesIO(file_content),
                length=len(file_content),
                content_type=content_type
            )
            logger.info(f"Successfully uploaded {filename} to MinIO")
            return filename
        except S3Error as e:
            logger.error(f"MinIO upload error for {filename}: {e}", exc_info=True)
            raise

    def get_file_url(self, object_name: str, expires: int = 3600) -> str:
        try:
            self.client.stat_object(self.bucket_name, object_name)
            return self.client.presigned_get_object(
                bucket_name=self.bucket_name,
                object_name=object_name,
                expires=timedelta(seconds=expires)
            )
        except S3Error as e:
            logger.error(f"Error generating URL for {object_name}: {e}")
            raise