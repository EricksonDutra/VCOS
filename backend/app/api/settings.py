from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.settings import AppSettings
from app.schemas.settings import SettingsRead, SettingsUpdate

router = APIRouter(prefix="/settings", tags=["settings"])


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
def read_settings(db: Session = Depends(get_db)) -> AppSettings:
    return get_or_create_settings(db)


@router.put("", response_model=SettingsRead)
def update_settings(payload: SettingsUpdate, db: Session = Depends(get_db)) -> AppSettings:
    settings = get_or_create_settings(db)

    for field, value in payload.model_dump().items():
        setattr(settings, field, value)
    settings.updated_at = datetime.now(timezone.utc)

    db.commit()
    db.refresh(settings)
    return settings
