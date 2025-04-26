import os
import subprocess
import atexit
import time
import platform
import requests
import stat
from pathlib import Path
from minio import Minio
import logging

logger = logging.getLogger(__name__)

class MinioLocalRunner:
    def __init__(self, data_dir="minio_data", port=9000, console_port=9001):
        self.data_dir = os.path.abspath(data_dir)
        self.port = port
        self.console_port = console_port
        self.process = None
        self.access_key = "minioadmin"
        self.secret_key = "minioadmin"
        self.minio_binary_path = self._get_minio_binary()

    def _get_minio_binary(self):
        """Скачивает MinIO бинарник если нужно и возвращает путь к нему"""
        system = platform.system().lower()
        machine = platform.machine().lower()

        if system == "linux" and machine == "x86_64":
            url = "https://dl.min.io/server/minio/release/linux-amd64/minio"
        elif system == "darwin" and machine == "x86_64":
            url = "https://dl.min.io/server/minio/release/darwin-amd64/minio"
        elif system == "windows" and machine == "amd64":
            url = "https://dl.min.io/server/minio/release/windows-amd64/minio.exe"
        else:
            raise RuntimeError(f"Unsupported platform: {system} {machine}")

        binary_name = "minio.exe" if system == "windows" else "minio"
        binary_path = Path(__file__).parent / binary_name

        if not binary_path.exists():
            logger.info(f"Downloading MinIO binary from {url}")
            response = requests.get(url, stream=True)
            response.raise_for_status()

            with open(binary_path, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)

            if system != "windows":
                os.chmod(binary_path, binary_path.stat().st_mode | stat.S_IEXEC)

        return str(binary_path)

    def start(self):
        """Запускает MinIO сервер"""
        if not os.path.exists(self.data_dir):
            os.makedirs(self.data_dir)

        cmd = [
            self.minio_binary_path,
            "server",
            self.data_dir,
            "--address", f":{self.port}",
            "--console-address", f":{self.console_port}"
        ]

        creationflags = 0
        if platform.system() == "Windows":
            creationflags = subprocess.CREATE_NEW_PROCESS_GROUP

        self.process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env={
                "MINIO_ROOT_USER": self.access_key,
                "MINIO_ROOT_PASSWORD": self.secret_key,
                **os.environ
            },
            creationflags=creationflags
        )

        time.sleep(2)
        logger.info(f"MinIO server started at http://localhost:{self.port}")
        logger.info(f"Console available at http://localhost:{self.console_port}")
        return self

    def stop(self):
        """Останавливает сервер"""
        if self.process:
            if platform.system() == "Windows":
                self.process.send_signal(subprocess.CTRL_BREAK_EVENT)
            else:
                self.process.terminate()
            self.process.wait()
            logger.info("MinIO server stopped")

    def get_client(self):
        """Возвращает клиент для работы с MinIO"""
        return Minio(
            f"localhost:{self.port}",
            access_key=self.access_key,
            secret_key=self.secret_key,
            secure=False
        )

minio_runner = MinioLocalRunner()