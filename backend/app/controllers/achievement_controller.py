from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.services.achievement_service import AchievementService
from app.schemas.achievement import UserAchievement, AchievementWithProgress
from typing import List

router = APIRouter(prefix="/achievements", tags=["Achievements"])

@router.get("/{user_id}", response_model=List[UserAchievement])
def get_user_achievements(user_id: int, db: Session = Depends(get_db)):
    """Получить достижения пользователя."""
    service = AchievementService(db)
    achievements = service.get_user_achievements(user_id)
    if not achievements:
        raise HTTPException(status_code=404, detail="No achievements found for this user")
    return achievements

@router.get("/{user_id}/all", response_model=List[AchievementWithProgress])
def get_all_achievements_with_progress(user_id: int, db: Session = Depends(get_db)):
    """Получить все достижения и прогресс пользователя по ним."""
    service = AchievementService(db)
    achievements = service.get_all_achievements_with_progress(user_id)
    if not achievements:
        raise HTTPException(status_code=404, detail="No achievements found")
    return achievements