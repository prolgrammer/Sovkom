from sqlalchemy.orm import Session
from fastapi import HTTPException
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin
import logging

logger = logging.getLogger(__name__)


class UserService:
    @staticmethod
    def create_user(db: Session, user: UserCreate):
        existing_user = db.query(User).filter(
            (User.email == user.email) | (User.phone_number == user.phone_number)
        ).first()
        if existing_user:
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
        return db_user

    @staticmethod
    def login_user(db: Session, user: UserLogin):
        db_user = db.query(User).filter(User.email == user.email).first()
        if not db_user or db_user.password != user.password:
            raise HTTPException(status_code=401, detail="Invalid email or password")
        logger.info(f"User logged in: {user.email}")
        return db_user