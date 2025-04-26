from sqlalchemy.orm import Session
from sqlalchemy import and_
from app.models.achievement import Achievement, UserAchievement
import logging

logger = logging.getLogger(__name__)

class AchievementService:
    def __init__(self, db: Session):
        self.db = db

    def get_user_achievements(self, user_id: int) -> list[UserAchievement]:
        """Получить все достижения пользователя."""
        logger.debug(f"Fetching achievements for user {user_id}")
        return self.db.query(UserAchievement).filter(UserAchievement.user_id == user_id).all()

    def get_all_achievements_with_progress(self, user_id: int) -> list[dict]:
        """Получить все достижения и прогресс пользователя по ним."""
        logger.debug(f"Fetching all achievements with progress for user {user_id}")
        achievements = self.db.query(Achievement).all()
        user_achievements = {ua.achievement_id: ua for ua in self.get_user_achievements(user_id)}

        result = []
        for achievement in achievements:
            user_achievement = user_achievements.get(achievement.id)
            result.append({
                "id": achievement.id,
                "name": achievement.name,
                "description": achievement.description,
                "target_progress": achievement.target_progress,
                "progress": user_achievement.progress if user_achievement else 0,
                "completed": user_achievement.completed if user_achievement else False
            })
        logger.debug(f"Found {len(result)} achievements for user {user_id}")
        return result

    def update_achievement_progress(self, user_id: int, achievement_name: str, increment: int):
        """Обновить прогресс достижения."""
        logger.debug(f"Updating achievement {achievement_name} for user {user_id} with increment {increment}")
        achievement = self.db.query(Achievement).filter(Achievement.name == achievement_name).first()
        if not achievement:
            logger.warning(f"Achievement {achievement_name} not found")
            return None

        user_achievement = self.db.query(UserAchievement).filter(
            and_(
                UserAchievement.user_id == user_id,
                UserAchievement.achievement_id == achievement.id
            )
        ).first()
        if user_achievement:
            user_achievement.progress += increment
            if user_achievement.progress >= achievement.target_progress:
                user_achievement.completed = True
            self.db.commit()
            self.db.refresh(user_achievement)
            logger.info(f"Updated achievement {achievement_name} for user {user_id}: progress={user_achievement.progress}")
        return user_achievement

    def initialize_user_achievements(self, user_id: int):
        """Инициализировать достижения для нового пользователя."""
        logger.debug(f"Initializing achievements for user {user_id}")
        achievements = self.db.query(Achievement).all()
        for achievement in achievements:
            existing = self.db.query(UserAchievement).filter(
                and_(
                    UserAchievement.user_id == user_id,
                    UserAchievement.achievement_id == achievement.id
                )
            ).first()
            if not existing:
                user_achievement = UserAchievement(
                    user_id=user_id,
                    achievement_id=achievement.id,
                    progress=0,
                    completed=False
                )
                self.db.add(user_achievement)
                logger.debug(f"Initialized achievement {achievement.name} for user {user_id}")
        self.db.commit()
        logger.info(f"Initialized {len(achievements)} achievements for user {user_id}")