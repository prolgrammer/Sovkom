from sqlalchemy.orm import Session
from sqlalchemy import and_
from datetime import date
from app.models.daily_task import DailyTask, DailyTaskAssignment, UserDailyTask
from app.models.user import User
import random
import logging

logger = logging.getLogger(__name__)

class DailyTaskService:
    def __init__(self, db: Session):
        self.db = db

    def get_user_tasks(self, user_id: int, task_date: date) -> list[UserDailyTask]:
        """Получить задания пользователя за конкретный день."""
        logger.debug(f"Fetching tasks for user {user_id} on {task_date}")
        assignment = self.db.query(DailyTaskAssignment).filter(DailyTaskAssignment.date == task_date).first()
        if not assignment:
            logger.warning(f"No task assignment found for {task_date}")
            return []

        tasks = self.db.query(UserDailyTask).filter(
            and_(
                UserDailyTask.user_id == user_id,
                UserDailyTask.assignment_id == assignment.id,
                UserDailyTask.date == task_date
            )
        ).all()
        logger.debug(f"Found {len(tasks)} tasks for user {user_id}")
        return tasks

    def get_current_tasks(self, task_date: date) -> DailyTaskAssignment:
        """Получить задания за текущий день."""
        logger.debug(f"Fetching current tasks for {task_date}")
        assignment = self.db.query(DailyTaskAssignment).filter(DailyTaskAssignment.date == task_date).first()
        if not assignment:
            logger.warning(f"No task assignment found for {task_date}")
        return assignment

    def mark_task_completed(self, user_id: int, task_id: int, task_date: date) -> UserDailyTask:
        """Отметить задание как выполненное."""
        logger.debug(f"Marking task {task_id} as completed for user {user_id} on {task_date}")
        assignment = self.db.query(DailyTaskAssignment).filter(DailyTaskAssignment.date == task_date).first()
        if not assignment:
            logger.warning(f"No task assignment found for {task_date}")
            return None

        task = self.db.query(UserDailyTask).filter(
            and_(
                UserDailyTask.user_id == user_id,
                UserDailyTask.assignment_id == assignment.id,
                UserDailyTask.task_id == task_id,
                UserDailyTask.date == task_date
            )
        ).first()
        if task and not task.completed:
            task.completed = True
            self.db.commit()
            self.db.refresh(task)
            self.update_achievements_progress(user_id, task.task.name)
            logger.info(f"Task {task_id} marked as completed for user {user_id}")
        else:
            logger.warning(f"Task {task_id} not found or already completed for user {user_id}")
        return task

    def assign_daily_tasks(self):
        """Назначить новые задания на текущий день для всех пользователей."""
        today = date.today()
        logger.debug(f"Assigning daily tasks for {today}")

        # Проверяем наличие заданий
        all_tasks = self.db.query(DailyTask).all()
        if len(all_tasks) < 2:
            logger.error("Not enough tasks to assign (need at least 2)")
            return

        # Создаем или получаем задание на день
        existing_assignment = self.db.query(DailyTaskAssignment).filter(DailyTaskAssignment.date == today).first()
        if not existing_assignment:
            selected_tasks = random.sample(all_tasks, 2)
            logger.debug(f"Selected tasks: {selected_tasks[0].name}, {selected_tasks[1].name}")
            assignment = DailyTaskAssignment(
                date=today,
                task1_id=selected_tasks[0].id,
                task2_id=selected_tasks[1].id
            )
            self.db.add(assignment)
            self.db.commit()
            logger.info(f"Created task assignment for {today} with tasks {selected_tasks[0].id}, {selected_tasks[1].id}")
        else:
            assignment = existing_assignment
            logger.debug(f"Using existing task assignment for {today}: tasks {assignment.task1_id}, {assignment.task2_id}")

        # Назначаем задания пользователям
        all_users = self.db.query(User).all()
        logger.debug(f"Found {len(all_users)} users")
        if not all_users:
            logger.warning("No users found in the database")
            return

        for user in all_users:
            for task_id in [assignment.task1_id, assignment.task2_id]:
                existing_user_task = self.db.query(UserDailyTask).filter(
                    and_(
                        UserDailyTask.user_id == user.id,
                        UserDailyTask.task_id == task_id,
                        UserDailyTask.date == today
                    )
                ).first()
                if existing_user_task:
                    logger.debug(f"Task {task_id} already assigned to user {user.id}")
                    continue

                user_task = UserDailyTask(
                    user_id=user.id,
                    assignment_id=assignment.id,
                    task_id=task_id,
                    date=today,
                    completed=False
                )
                self.db.add(user_task)
                logger.debug(f"Assigned task {task_id} to user {user.id}")
        self.db.commit()
        logger.info(f"Assigned 2 daily tasks to {len(all_users)} users for {today}")

    def assign_tasks_to_new_user(self, user_id: int):
        """Назначить ежедневные задания новому пользователю на текущий день."""
        today = date.today()
        logger.debug(f"Assigning daily tasks for new user {user_id} on {today}")

        # Проверяем наличие заданий на текущий день
        assignment = self.db.query(DailyTaskAssignment).filter(DailyTaskAssignment.date == today).first()
        if not assignment:
            logger.debug("No task assignment for today, creating one")
            self.assign_daily_tasks()  # Создаем задания на день
            assignment = self.db.query(DailyTaskAssignment).filter(DailyTaskAssignment.date == today).first()
            if not assignment:
                logger.error("Failed to create task assignment for today")
                return

        # Проверяем, есть ли уже задания у пользователя
        existing_tasks = self.db.query(UserDailyTask).filter(
            and_(
                UserDailyTask.user_id == user_id,
                UserDailyTask.date == today
            )
        ).all()
        if existing_tasks:
            logger.debug(f"User {user_id} already has tasks for {today}")
            return

        # Назначаем задания пользователю
        for task_id in [assignment.task1_id, assignment.task2_id]:
            user_task = UserDailyTask(
                user_id=user_id,
                assignment_id=assignment.id,
                task_id=task_id,
                date=today,
                completed=False
            )
            self.db.add(user_task)
            logger.debug(f"Assigned task {task_id} to user {user_id}")
        self.db.commit()
        logger.info(f"Assigned 2 daily tasks to new user {user_id} for {today}")

    def update_achievements_progress(self, user_id: int, task_name: str):
        """Обновить прогресс достижений после выполнения задания."""
        from app.services.achievement_service import AchievementService
        achievement_service = AchievementService(self.db)
        if task_name == "Загрузи чек в приложение":
            achievement_service.update_achievement_progress(user_id, "Мастер чеков", 1)
        elif task_name == "Соверши покупку в партнерском магазине":
            achievement_service.update_achievement_progress(user_id, "Путешественник по партнерам", 1)
        # Добавьте другие проверки для других заданий и достижений