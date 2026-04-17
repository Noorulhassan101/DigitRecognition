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

from utils.preprocess import preprocess_image

try:
    import ai_edge_litert.interpreter as tflite
except ImportError:
    # Fallback for local testing if ai-edge-litert fails but standard tensorflow is present
    try:
        from tensorflow import lite as tflite
    except ImportError:
        tflite = None
        print("TFLite runtime not found!")

interpreter = None
input_details = None
output_details = None
model_path = os.path.join(os.path.dirname(__file__), 'model.tflite')

def load_tflite_model():
    global interpreter, input_details, output_details
    if interpreter is None and tflite is not None:
        if os.path.exists(model_path):
            try:
                interpreter = tflite.Interpreter(model_path=model_path)
                interpreter.allocate_tensors()
                input_details = interpreter.get_input_details()
                output_details = interpreter.get_output_details()
            except Exception as e:
                print(f"Error loading TFLite model: {e}")
                pass
        else:
            print(f"Model not found at {model_path}.")

class ImageRequest(BaseModel):
    image: str

@app.on_event("startup")
async def startup_event():
    load_tflite_model()

@app.post("/predict")
async def predict_digit(req: ImageRequest):
    global interpreter
    if interpreter is None:
        load_tflite_model()
        if interpreter is None:
            raise HTTPException(status_code=503, detail="Model is not loaded. Ensure model.tflite exists.")
        
    try:
        img_array = preprocess_image(req.image)
        # Ensure the type matches what TFLite expects
        img_array = np.array(img_array, dtype=np.float32)
        
        # Prediction via TFLite Runtime
        interpreter.set_tensor(input_details[0]['index'], img_array)
        interpreter.invoke()
        preds = interpreter.get_tensor(output_details[0]['index'])[0]
        
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
    return {"status": "ok", "message": "MNIST API (TFLite) is running natively!"}
