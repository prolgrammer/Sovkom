from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin
from app.services.daily_task_service import DailyTaskService
from app.services.achievement_service import AchievementService
import logging

logger = logging.getLogger(__name__)

class UserService:
    @staticmethod
    def create_user(db: Session, user: UserCreate):
        logger.debug(f"Creating user with email: {user.email}")
        existing_user = db.query(User).filter(
            (User.email == user.email) | (User.phone_number == user.phone_number)
        ).first()
        if existing_user:
            logger.warning(f"Email {user.email} or phone number {user.phone_number} already registered")
            raise HTTPException(status_code=400, detail="Email or phone number already registered")

        db_user = User(
            first_name=user.first_name,
            last_name=user.last_name,
            patronymic=user.patronymic,
            phone_number=user.phone_number,
            email=user.email,
            password=user.password,  # В продакшене нужно хешировать пароль
            role=user.role
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        logger.info(f"User created: {user.email}")

        # Инициализация ежедневных заданий для нового пользователя
        daily_task_service = DailyTaskService(db)
        daily_task_service.assign_tasks_to_new_user(db_user.id)
        logger.info(f"Assigned daily tasks to user: {user.email}")

        # Инициализация достижений для нового пользователя
        achievement_service = AchievementService(db)
        achievement_service.initialize_user_achievements(db_user.id)
        logger.info(f"Initialized achievements for user: {user.email}")

        return db_user

    @staticmethod
    def login_user(db: Session, user: UserLogin):
        logger.debug(f"Attempting login for user: {user.email}")
        db_user = db.query(User).filter(User.email == user.email).first()
        if not db_user or db_user.password != user.password:
            logger.warning(f"Invalid login attempt for email: {user.email}")
            raise HTTPException(status_code=401, detail="Invalid email or password")
        logger.info(f"User logged in: {user.email}")
        return db_user