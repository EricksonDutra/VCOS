from datetime import UTC, datetime
from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.settings import AppSettings
from app.schemas.settings import SettingsRead, SettingsUpdate

router = APIRouter(prefix="/settings", tags=["settings"])
DbSession = Annotated[Session, Depends(get_db)]


def get_or_create_settings(db: Session) -> AppSettings:
    settings = db.get(AppSettings, 1)
    if settings is not None:
        return settings

    settings = AppSettings(id=1)
    db.add(settings)
    db.commit()
    db.refresh(settings)
    return settings


@router.get("", response_model=SettingsRead)
def read_settings(db: DbSession = None) -> AppSettings:
    return get_or_create_settings(db)


@router.put("", response_model=SettingsRead)
def update_settings(payload: SettingsUpdate, db: DbSession = None) -> AppSettings:
    settings = get_or_create_settings(db)

    for field, value in payload.model_dump().items():
        setattr(settings, field, value)
    settings.updated_at = datetime.now(UTC)

    db.commit()
    db.refresh(settings)
    return settings
