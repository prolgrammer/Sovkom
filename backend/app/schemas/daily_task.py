from pydantic import BaseModel
from datetime import date
from typing import Optional

class DailyTaskBase(BaseModel):
    name: str
    description: Optional[str] = None

class DailyTaskCreate(DailyTaskBase):
    pass

class DailyTask(DailyTaskBase):
    id: int

    class Config:
        from_attributes = True

class DailyTaskAssignmentBase(BaseModel):
    date: date
    task1_id: int
    task2_id: int

class DailyTaskAssignment(DailyTaskAssignmentBase):
    id: int
    task1: DailyTask
    task2: DailyTask

    class Config:
        from_attributes = True

class UserDailyTaskBase(BaseModel):
    user_id: int
    assignment_id: int
    task_id: int
    date: date
    completed: bool

class UserDailyTask(UserDailyTaskBase):
    id: int
    task: DailyTask

    class Config:
        from_attributes = True