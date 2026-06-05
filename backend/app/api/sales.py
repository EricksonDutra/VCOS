from datetime import UTC, datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.sale import Sale
from app.schemas.sale import SaleCreate, SaleRead, SaleUpdate

router = APIRouter(prefix="/sales", tags=["sales"])
DbSession = Annotated[Session, Depends(get_db)]


@router.get("", response_model=list[SaleRead])
def list_sales(include_deleted: bool = False, db: DbSession = None) -> list[Sale]:
    statement = select(Sale).order_by(Sale.created_at.desc())
    if not include_deleted:
        statement = statement.where(Sale.deleted_at.is_(None))
    return list(db.scalars(statement))


@router.post("", response_model=SaleRead, status_code=status.HTTP_201_CREATED)
def create_sale(payload: SaleCreate, db: DbSession = None) -> Sale:
    now = datetime.now(UTC)
    sale = Sale(**payload.model_dump(exclude_none=True))
    sale.created_at = sale.created_at or now
    sale.updated_at = sale.updated_at or now

    db.add(sale)
    db.commit()
    db.refresh(sale)
    return sale


@router.get("/{sale_id}", response_model=SaleRead)
def get_sale(sale_id: str, db: DbSession = None) -> Sale:
    sale = db.get(Sale, sale_id)
    if sale is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sale not found")
    return sale


@router.put("/{sale_id}", response_model=SaleRead)
def update_sale(sale_id: str, payload: SaleUpdate, db: DbSession = None) -> Sale:
    sale = db.get(Sale, sale_id)
    if sale is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sale not found")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(sale, field, value)
    sale.updated_at = datetime.now(UTC)

    db.commit()
    db.refresh(sale)
    return sale


@router.delete("/{sale_id}", response_model=SaleRead)
def delete_sale(sale_id: str, db: DbSession = None) -> Sale:
    sale = db.get(Sale, sale_id)
    if sale is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sale not found")

    now = datetime.now(UTC)
    sale.deleted_at = now
    sale.updated_at = now

    db.commit()
    db.refresh(sale)
    return sale
