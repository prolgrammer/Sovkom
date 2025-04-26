from sqlalchemy import Column, Integer, String, Date, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.core.database import Base
from datetime import date

class DailyTask(Base):
    __tablename__ = "daily_tasks"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=True)

    user_tasks = relationship("UserDailyTask", back_populates="task")
    assignments = relationship(
        "DailyTaskAssignment",
        back_populates="task1",
        foreign_keys="DailyTaskAssignment.task1_id"
    )
    assignments2 = relationship(
        "DailyTaskAssignment",
        back_populates="task2",
        foreign_keys="DailyTaskAssignment.task2_id"
    )

class DailyTaskAssignment(Base):
    __tablename__ = "daily_task_assignments"

    id = Column(Integer, primary_key=True, index=True)
    date = Column(Date, nullable=False, default=date.today)
    task1_id = Column(Integer, ForeignKey("daily_tasks.id"), nullable=False)
    task2_id = Column(Integer, ForeignKey("daily_tasks.id"), nullable=False)

    task1 = relationship(
        "DailyTask",
        back_populates="assignments",
        foreign_keys=[task1_id]
    )
    task2 = relationship(
        "DailyTask",
        back_populates="assignments2",
        foreign_keys=[task2_id]
    )
    user_tasks = relationship("UserDailyTask", back_populates="assignment")

class UserDailyTask(Base):
    __tablename__ = "user_daily_tasks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    assignment_id = Column(Integer, ForeignKey("daily_task_assignments.id"), nullable=False)
    task_id = Column(Integer, ForeignKey("daily_tasks.id"), nullable=False)
    date = Column(Date, nullable=False, default=date.today)
    completed = Column(Boolean, default=False)

    task = relationship("DailyTask", back_populates="user_tasks")
    assignment = relationship("DailyTaskAssignment", back_populates="user_tasks")