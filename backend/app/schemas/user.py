from pydantic import BaseModel, EmailStr
from typing import Optional
from app.models.user import UserRole

class UserCreate(BaseModel):
    first_name: str
    last_name: str
    patronymic: Optional[str] = None
    phone_number: str
    email: EmailStr
    password: str
    role: UserRole = UserRole.CLIENT

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    patronymic: Optional[str]
    phone_number: str
    email: EmailStr
    role: UserRole

    class Config:
        from_attributes = True