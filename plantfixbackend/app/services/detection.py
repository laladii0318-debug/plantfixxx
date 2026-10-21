
import os
import io

import numpy as np
import tensorflow as tf
from PIL import Image, UnidentifiedImageError

from app.services.disease_info import get_disease_info


MODEL_PATH = os.path.join(
    "models",
    "plant_disease",
    "plant_disease_efficientnet.keras"
)

CLASS_NAMES_PATH = os.path.join(
    "models",
    "plant_disease",
    "class_names.txt"
)

IMAGE_SIZE = (224, 224)
MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10 MB
MIN_CONFIDENCE = 0.60


# Load model
model = tf.keras.models.load_model(MODEL_PATH)


# Load class names
with open(CLASS_NAMES_PATH, "r", encoding="utf-8") as file:
    class_names = []

    for line in file:
        line = line.strip()

        if not line:
            continue

        if ":" in line:
            line = line.split(":", 1)[1].strip()

        class_names.append(line)


# Validate model configuration
if not class_names:
    raise RuntimeError(
        "No class names found in class_names.txt."
    )

if model.output_shape[-1] != len(class_names):
    raise RuntimeError(
        "Model output count does not match class_names.txt."
    )


def detect_crop_disease(image_data):
    # Validate uploaded image data
    if not isinstance(image_data, bytes) or not image_data:
        raise ValueError(
            "No valid image data was provided."
        )

    if len(image_data) > MAX_IMAGE_SIZE:
        raise ValueError(
            "Image is too large. Maximum size is 10 MB."
        )

    # Open and validate image
    try:
        with Image.open(io.BytesIO(image_data)) as source_image:
            source_image.verify()

        with Image.open(io.BytesIO(image_data)) as source_image:
            image = source_image.convert("RGB")

    except (UnidentifiedImageError, OSError, ValueError):
        raise ValueError(
            "Invalid or unsupported image. Please upload a valid image."
        )

    # Resize for EfficientNet
    image = image.resize(IMAGE_SIZE)

    # Convert image to NumPy array
    image_array = np.asarray(
        image,
        dtype=np.float32
    )

    # Add batch dimension
    image_array = np.expand_dims(
        image_array,
        axis=0
    )

    # Run AI prediction
    predictions = model.predict(
        image_array,
        verbose=0
    )

    # Validate model output
    if (
            predictions.ndim != 2
            or predictions.shape[0] != 1
            or predictions.shape[1] != len(class_names)
    ):
        raise RuntimeError(
            "The AI model returned an unexpected prediction shape."
        )

    probabilities = predictions[0]

    if not np.all(np.isfinite(probabilities)):
        raise RuntimeError(
            "The AI model returned invalid prediction values."
        )

    predicted_index = int(np.argmax(probabilities))
    confidence = float(probabilities[predicted_index])

    if not 0.0 <= confidence <= 1.0:
        raise RuntimeError(
            "The AI model returned an invalid confidence score."
        )

    # Get predicted disease
    disease = class_names[predicted_index]

    # Get disease information
    info = get_disease_info(disease)

    # Mark uncertain predictions
    reliable_prediction = confidence >= MIN_CONFIDENCE

    return {
        "crop": info["crop"],
        "disease": disease,
        "confidence": round(confidence * 100, 2),
        "symptoms": info["symptoms"],
        "causes": info["causes"],
        "treatment": info["treatment"],
        "prevention": info["prevention"],
        "reliable_prediction": reliable_prediction,
        "message": (
            "Prediction confidence is low. Please upload a clearer "
            "plant image and verify the result."
            if not reliable_prediction
            else "Prediction completed. Confirm the result by checking "
                 "the plant symptoms."
        )
    }
