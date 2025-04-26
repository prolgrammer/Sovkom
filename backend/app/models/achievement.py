from sqlalchemy import Column, Integer, String, ForeignKey, Boolean
from app.core.database import Base

class Achievement(Base):
    __tablename__ = "achievements"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)
    progress = Column(Integer, default=0)  # Прогресс в процентах или единицах
    completed = Column(Boolean, default=False)