from datetime import datetime
from uuid import uuid4

from pydantic import BaseModel, Field


class ExpenseBase(BaseModel):
    remote_id: str | None = None
    description: str = Field(min_length=1)
    category: str = "Materiais"
    amount: float = Field(ge=0)
    notes: str = ""
    photo_paths: list[str] = Field(default_factory=list)
    created_at: datetime | None = None
    updated_at: datetime | None = None
    deleted_at: datetime | None = None
    sync_status: str = "synced"


class ExpenseCreate(ExpenseBase):
    id: str = Field(default_factory=lambda: str(uuid4()))


class ExpenseUpdate(BaseModel):
    remote_id: str | None = None
    description: str | None = Field(default=None, min_length=1)
    category: str | None = None
    amount: float | None = Field(default=None, ge=0)
    notes: str | None = None
    photo_paths: list[str] | None = None
    deleted_at: datetime | None = None
    sync_status: str | None = None


class ExpenseRead(ExpenseBase):
    id: str
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
