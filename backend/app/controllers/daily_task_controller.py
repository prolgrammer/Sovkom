from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.services.daily_task_service import DailyTaskService
from app.schemas.daily_task import UserDailyTask, DailyTask
from datetime import date
from typing import List

router = APIRouter(prefix="/daily-tasks", tags=["Daily Tasks"])

@router.get("/{user_id}", response_model=List[UserDailyTask])
def get_daily_tasks(user_id: int, task_date: date = date.today(), db: Session = Depends(get_db)):
    """Получить ежедневные задания пользователя за текущий день."""
    service = DailyTaskService(db)
    tasks = service.get_user_tasks(user_id, task_date)
    if not tasks:
        raise HTTPException(status_code=404, detail="No tasks found for this date")
    return tasks

@router.get("/current", response_model=List[DailyTask])
def get_current_tasks(task_date: date = date.today(), db: Session = Depends(get_db)):
    """Получить текущие задания за день."""
    service = DailyTaskService(db)
    assignment = service.get_current_tasks(task_date)
    if not assignment:
        raise HTTPException(status_code=404, detail="No tasks assigned for this date")
    return [assignment.task1, assignment.task2]

@router.post("/{user_id}/{task_id}/complete", response_model=UserDailyTask)
def complete_task(user_id: int, task_id: int, task_date: date = date.today(), db: Session = Depends(get_db)):
    """Отметить задание как выполненное."""
    service = DailyTaskService(db)
    task = service.mark_task_completed(user_id, task_id, task_date)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found or already completed")
    return task