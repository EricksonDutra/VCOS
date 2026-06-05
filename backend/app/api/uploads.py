from pathlib import Path
from typing import Annotated
from uuid import uuid4

from fastapi import APIRouter, File, HTTPException, Request, UploadFile, status

from app.core.config import get_settings

router = APIRouter(prefix="/uploads", tags=["uploads"])

_ALLOWED_IMAGE_TYPES = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}


@router.post("/expense-photos", status_code=status.HTTP_201_CREATED)
async def upload_expense_photo(
    request: Request,
    file: Annotated[UploadFile, File()],
) -> dict[str, str]:
    extension = _ALLOWED_IMAGE_TYPES.get(file.content_type or "")
    if extension is None:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Unsupported image type",
        )

    settings = get_settings()
    photo_dir = Path(settings.uploads_dir) / "expense-photos"
    photo_dir.mkdir(parents=True, exist_ok=True)

    file_name = f"{uuid4()}{extension}"
    destination = photo_dir / file_name
    contents = await file.read()
    destination.write_bytes(contents)

    path = f"/uploads/expense-photos/{file_name}"
    return {
        "path": path,
        "url": str(request.base_url).rstrip("/") + path,
    }
