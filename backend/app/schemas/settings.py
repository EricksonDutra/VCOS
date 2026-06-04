from datetime import datetime

from pydantic import BaseModel


class SettingsUpdate(BaseModel):
    studio_name: str = "VCOS Retalhos"
    owner_name: str = ""
    phone: str = ""
    auto_sync_enabled: bool = True
    high_contrast_enabled: bool = False


class SettingsRead(SettingsUpdate):
    updated_at: datetime

    model_config = {"from_attributes": True}
