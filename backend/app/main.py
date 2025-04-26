from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.controllers import user_controller
from app.migrations.init_db import run_migration

app = FastAPI(title="Halva Purchases Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Для Flutter веб и мобильного
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(user_controller.router)

if __name__ == "__main__":
    run_migration()
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)