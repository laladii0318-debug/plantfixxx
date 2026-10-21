
from fastapi import FastAPI

from app.database.database import Base, engine
from app.models import user
from app.routers.auth import router as auth_router
from app.routers.detection import router as detection_router

Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="PlantFix API",
    description="AI Crop Disease Detection Backend",
    version="1.0.0"
)

app.include_router(auth_router)
app.include_router(detection_router)


@app.get("/")
def root():
    return {
        "message": "Welcome to PlantFix API 🌱",
        "status": "running"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }

