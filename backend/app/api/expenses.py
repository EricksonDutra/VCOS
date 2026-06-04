from datetime import UTC, datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.expense import Expense
from app.schemas.expense import ExpenseCreate, ExpenseRead, ExpenseUpdate

router = APIRouter(prefix="/expenses", tags=["expenses"])
DbSession = Annotated[Session, Depends(get_db)]


@router.get("", response_model=list[ExpenseRead])
def list_expenses(include_deleted: bool = False, db: DbSession = None) -> list[Expense]:
    statement = select(Expense).order_by(Expense.created_at.desc())
    if not include_deleted:
        statement = statement.where(Expense.deleted_at.is_(None))
    return list(db.scalars(statement))


@router.post("", response_model=ExpenseRead, status_code=status.HTTP_201_CREATED)
def create_expense(payload: ExpenseCreate, db: DbSession = None) -> Expense:
    now = datetime.now(UTC)
    expense = Expense(**payload.model_dump(exclude_none=True))
    expense.created_at = expense.created_at or now
    expense.updated_at = expense.updated_at or now

    db.add(expense)
    db.commit()
    db.refresh(expense)
    return expense


@router.get("/{expense_id}", response_model=ExpenseRead)
def get_expense(expense_id: str, db: DbSession = None) -> Expense:
    expense = db.get(Expense, expense_id)
    if expense is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Expense not found")
    return expense


@router.put("/{expense_id}", response_model=ExpenseRead)
def update_expense(
    expense_id: str,
    payload: ExpenseUpdate,
    db: DbSession = None,
) -> Expense:
    expense = db.get(Expense, expense_id)
    if expense is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Expense not found")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(expense, field, value)
    expense.updated_at = datetime.now(UTC)

    db.commit()
    db.refresh(expense)
    return expense


@router.delete("/{expense_id}", response_model=ExpenseRead)
def delete_expense(expense_id: str, db: DbSession = None) -> Expense:
    expense = db.get(Expense, expense_id)
    if expense is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Expense not found")

    now = datetime.now(UTC)
    expense.deleted_at = now
    expense.updated_at = now

    db.commit()
    db.refresh(expense)
    return expense
