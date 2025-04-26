from sqlalchemy import create_engine, inspect
from sqlalchemy.orm import sessionmaker
from app.core.config import settings
from app.core.database import Base, engine, SessionLocal
from app.models import user, receipt, achievement, daily_task
from app.models.daily_task import DailyTask, DailyTaskAssignment
from app.models.achievement import Achievement
from datetime import date
import logging
import random

from app.models.partner import Partner

logger = logging.getLogger(__name__)


def run_migration():
    inspector = inspect(engine)
    existing_tables = inspector.get_table_names()

    if not existing_tables:
        logger.info("No tables found, creating database schema...")
        Base.metadata.create_all(bind=engine)

        # Инициализация партнеров
        db = SessionLocal()
        try:
            initial_partners = [
                Partner(name="Магнит", category="Продукты", cashback=5.0),
                Partner(name="Wildberries", category="Одежда", cashback=3.0),
                Partner(name="Лента", category="Продукты", cashback=4.0),
            ]
            db.add_all(initial_partners)
            db.commit()
            logger.info("Initial partners added to database")
        finally:
            db.close()

        logger.info("Database schema created successfully")
    else:
        logger.info("Database schema already exists")

def initialize_tasks_and_achievements():
    """Инициализировать фиксированные ежедневные задания, достижения и задания на текущий день."""
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()

    try:
        # Инициализация ежедневных заданий
        tasks = [
            {"name": "Соверши покупку в партнерском магазине", "description": "Купи что-нибудь в любом магазине-партнере «Халвы»."},
            {"name": "Оплати покупку на сумму от 1000 рублей", "description": "Соверши транзакцию на 1000+ рублей с картой «Халва»."},
            {"name": "Загрузи чек в приложение", "description": "Отсканируй и загрузи чек от любой покупки."},
            {"name": "Посети продуктовый магазин-партнер", "description": "Соверши покупку в продуктовом магазине из списка партнеров."},
            {"name": "Купи одежду в партнерском магазине", "description": "Соверши покупку в магазине одежды из списка партнеров."},
            {"name": "Получи кешбэк за покупку", "description": "Соверши покупку, чтобы получить кешбэк по карте «Халва»."},
            {"name": "Изучи рекомендации", "description": "Просмотри персональные рекомендации по магазинам в приложении."},
            {"name": "Соверши покупку в категории «Электроника»", "description": "Купи что-нибудь в магазине электроники из партнеров."},
            {"name": "Соверши покупку в категории «Красота»", "description": "Посети магазин косметики или парфюмерии из партнеров."},
            {"name": "Соверши 2 покупки за день", "description": "Соверши минимум 2 покупки с картой «Халва»."},
            {"name": "Загрузи 2 чека", "description": "Загрузи в приложение 2 чека от покупок за день."},
            {"name": "Оплати покупку на сумму от 5000 рублей", "description": "Соверши транзакцию на 5000+ рублей."},
            {"name": "Посети новый магазин-партнер", "description": "Соверши покупку в магазине, где ты еще не был."},
            {"name": "Соверши покупку в кафе или ресторане", "description": "Оплати заказ в кафе/ресторане-партнере."},
            {"name": "Используй рассрочку", "description": "Соверши покупку в рассрочку с картой «Халва»."},
            {"name": "Проверь статистику трат", "description": "Открой раздел статистики в приложении и просмотри свои траты."},
            {"name": "Соверши покупку в аптеке-партнере", "description": "Купи что-нибудь в аптеке из списка партнеров."},
            {"name": "Оцени магазин в приложении", "description": "Поставь оценку любому магазину-партнеру в приложении."},
            {"name": "Поделись рекомендацией", "description": "Отправь ссылку на приложение другу через соцсети."},
            {"name": "Соверши покупку в онлайн-магазине", "description": "Купи что-нибудь в интернет-магазине-партнере «Халвы»."},
        ]

        for task in tasks:
            existing = db.query(DailyTask).filter(DailyTask.name == task["name"]).first()
            if not existing:
                db.add(DailyTask(
                    name=task["name"],
                    description=task["description"]
                ))
        db.commit()
        logger.info(f"Initialized {len(tasks)} daily tasks.")

        # Инициализация достижений
        achievements = [
            {"name": "Новичок шопинга", "description": "Соверши первую покупку с картой «Халва»", "target_progress": 1},
            {"name": "Мастер чеков", "description": "Загрузи 50 чеков в приложение", "target_progress": 50},
            {"name": "Кешбэк-гуру", "description": "Получи кешбэк на сумму 10,000 рублей", "target_progress": 10000},
            {"name": "Путешественник по партнерам", "description": "Соверши покупки в 10 разных магазинах-партнерах", "target_progress": 10},
            {"name": "Любитель рассрочки", "description": "Соверши 5 покупок в рассрочку", "target_progress": 5},
            {"name": "Экономный покупатель", "description": "Соверши покупки на сумму 100,000 рублей с картой «Халва»", "target_progress": 100000},
            {"name": "Фанат рекомендаций", "description": "Следуй 10 персональным рекомендациям", "target_progress": 10},
            {"name": "Супер-активный", "description": "Выполни 30 ежедневных заданий", "target_progress": 30},
            {"name": "Знаток категорий", "description": "Соверши покупки в 5 разных категориях", "target_progress": 5},
            {"name": "Ветеран Халвы", "description": "Совершай покупки 100 дней подряд", "target_progress": 100},
        ]

        for achievement in achievements:
            existing = db.query(Achievement).filter(Achievement.name == achievement["name"]).first()
            if not existing:
                db.add(Achievement(
                    name=achievement["name"],
                    description=achievement["description"],
                    target_progress=achievement["target_progress"]
                ))
        db.commit()
        logger.info(f"Initialized {len(achievements)} achievements.")

        # Инициализация заданий на текущий день (для тестирования)
        today = date.today()
        existing_assignment = db.query(DailyTaskAssignment).filter(DailyTaskAssignment.date == today).first()
        if not existing_assignment:
            all_tasks = db.query(DailyTask).all()
            if len(all_tasks) >= 2:
                selected_tasks = random.sample(all_tasks, 2)
                assignment = DailyTaskAssignment(
                    date=today,
                    task1_id=selected_tasks[0].id,
                    task2_id=selected_tasks[1].id
                )
                db.add(assignment)
                db.commit()
                logger.info(f"Initialized daily task assignment for {today}.")
            else:
                logger.warning("Not enough tasks to initialize daily assignment.")

    except Exception as e:
        logger.error(f"Error initializing tasks and achievements: {e}")
        db.rollback()
        raise
    finally:
        db.close()