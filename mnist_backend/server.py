import os
import json
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import numpy as np

# Create app
app = FastAPI(title="MNIST Digit Recognizer API", description="Production API for recognizing drawn digits")

# Allow CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Late import and loading to minimize startup issues on simple requests
import tensorflow as tf
from utils.preprocess import preprocess_image

model = None
model_path = os.path.join(os.path.dirname(__file__), 'model.h5')

def load_tf_model():
    global model
    if model is None:
        if os.path.exists(model_path):
            try:
                model = tf.keras.models.load_model(model_path)
            except Exception as e:
                print(f"Error loading model: {e}")
                pass
        else:
            print(f"Model not found at {model_path}.")

class ImageRequest(BaseModel):
    image: str

@app.on_event("startup")
async def startup_event():
    load_tf_model()

@app.post("/predict")
async def predict_digit(req: ImageRequest):
    global model
    if model is None:
        load_tf_model()
        if model is None:
            raise HTTPException(status_code=503, detail="Model is not loaded. Train the model first using train.py.")
        
    try:
        img_array = preprocess_image(req.image)
        # Prediction
        preds = model.predict(img_array, verbose=0)[0]
        predicted_digit = int(np.argmax(preds))
        confidences = [float(p) for p in preds]
        
        return {
            "predicted_digit": predicted_digit,
            "confidences": confidences
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/metrics")
async def get_metrics():
    try:
        metrics_file = os.path.join(os.path.dirname(__file__), 'metrics.json')
        if not os.path.exists(metrics_file):
            raise HTTPException(status_code=404, detail="Metrics file not found. Train the model first.")
            
        with open(metrics_file, 'r') as f:
            data = json.load(f)
        return data
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
async def root():
    return {"status": "ok", "message": "MNIST API is running"}
