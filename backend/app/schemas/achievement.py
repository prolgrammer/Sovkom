from pydantic import BaseModel
from typing import Optional

class AchievementBase(BaseModel):
    name: str
    description: Optional[str] = None
    target_progress: int

class AchievementCreate(AchievementBase):
    pass

class Achievement(AchievementBase):
    id: int

    class Config:
        from_attributes = True

class UserAchievementBase(BaseModel):
    user_id: int
    achievement_id: int
    progress: int
    completed: bool

class UserAchievement(UserAchievementBase):
    id: int
    achievement: Achievement

    class Config:
        from_attributes = True

class AchievementWithProgress(BaseModel):
    id: int
    name: str
    description: Optional[str]
    target_progress: int
    progress: int
    completed: bool

    class Config:
        from_attributes = True