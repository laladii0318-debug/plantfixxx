from fastapi import APIRouter, File, UploadFile, HTTPException

from app.services.detection import detect_crop_disease


router = APIRouter(
    prefix="/detection",
    tags=["Crop Detection"]
)


@router.post("/detect")
async def detect_disease(file: UploadFile = File(...)):
    try:
        image_data = await file.read()

        if not image_data:
            raise HTTPException(
                status_code=400,
                detail="No image uploaded"
            )

        result = detect_crop_disease(image_data)

        return result

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )