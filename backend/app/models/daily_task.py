from sqlalchemy import Column, Integer, String, Date
from app.core.database import Base

class DailyTask(Base):
    __tablename__ = "daily_tasks"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)
    date = Column(Date, nullable=False)  # Дата, на которую активно задание