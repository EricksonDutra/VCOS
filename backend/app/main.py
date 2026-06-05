from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.api.expenses import router as expenses_router
from app.api.health import router as health_router
from app.api.sales import router as sales_router
from app.api.settings import router as settings_router
from app.api.uploads import router as uploads_router
from app.core.config import get_settings
from app.db.session import create_db_and_tables


def create_app() -> FastAPI:
    settings = get_settings()

    app = FastAPI(
        title=settings.app_name,
        version="0.1.0",
        docs_url="/docs",
        redoc_url="/redoc",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.on_event("startup")
    def on_startup() -> None:
        create_db_and_tables()

    Path(settings.uploads_dir).mkdir(parents=True, exist_ok=True)
    app.mount("/uploads", StaticFiles(directory=settings.uploads_dir), name="uploads")

    app.include_router(health_router, prefix=settings.api_prefix)
    app.include_router(sales_router, prefix=settings.api_prefix)
    app.include_router(expenses_router, prefix=settings.api_prefix)
    app.include_router(settings_router, prefix=settings.api_prefix)
    app.include_router(uploads_router, prefix=settings.api_prefix)

    return app


app = create_app()
