from sqlalchemy import inspect
from app.core.database import Base, engine
from app.models import user, receipt, achievement, daily_task
import logging

logger = logging.getLogger(__name__)


def run_migration():
    inspector = inspect(engine)
    existing_tables = inspector.get_table_names()

    if not existing_tables:
        logger.info("No tables found, creating database schema...")
        Base.metadata.create_all(bind=engine)
        logger.info("Database schema created successfully")
    else:
        logger.info("Database schema already exists")