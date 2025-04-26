import webbrowser
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from app.controllers import (
    user_controller,
    receipt_controller,
    daily_task_controller,
    achievement_controller,
    partner_controller
)
from app.migrations.init_db import run_migration, initialize_tasks_and_achievements
from app.services.daily_task_service import DailyTaskService
from app.core.database import get_db
import pytz

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting application")
    run_migration()  # Выполняем миграции
    initialize_tasks_and_achievements()  # Инициализируем фиксированные задания и достижения
    assign_daily_tasks_job()  # Назначаем ежедневные задания при старте
    scheduler.start()  # Запускаем планировщик
    logger.info("Application started, scheduler running")

    yield

    # Shutdown
    logger.info("Shutting down application")
    scheduler.shutdown()
    logger.info("Application shutdown, scheduler stopped")


app = FastAPI(title="Halva Purchases Backend", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключаем роутеры
app.include_router(user_controller.router)
app.include_router(receipt_controller.router)
app.include_router(partner_controller.router)
app.include_router(daily_task_controller.router)
app.include_router(achievement_controller.router)


def assign_daily_tasks_job():
    """Задача для назначения ежедневных заданий."""
    logger.info("Starting daily task assignment job")
    db = next(get_db())
    try:
        service = DailyTaskService(db)
        service.assign_daily_tasks()
        logger.info("Daily tasks assigned successfully")
    except Exception as e:
        logger.error(f"Error assigning daily tasks: {e}")
    finally:
        db.close()


scheduler = BackgroundScheduler(timezone=pytz.timezone("Europe/Moscow"))
scheduler.add_job(
    assign_daily_tasks_job,
    trigger=CronTrigger(hour=12, minute=0, second=0, timezone=pytz.timezone("Europe/Moscow"))
)


def open_minio_console():
    """Открытие консоли MinIO в браузере."""
    webbrowser.open("http://localhost:9001")


if __name__ == "__main__":
    open_minio_console()
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)