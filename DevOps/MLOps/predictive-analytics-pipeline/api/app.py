from fastapi import FastAPI
from pydantic import BaseModel
import os, boto3, tempfile
from joblib import load

APP = FastAPI(title="Predictive API")

MODEL_BUCKET = os.getenv("MODEL_BUCKET", "mlops-predictive-model-975628796846")
MODEL_KEY    = os.getenv("MODEL_KEY", "model.pkl")
AWS_REGION   = os.getenv("AWS_REGION", "us-east-1")

_session = boto3.session.Session(region_name=AWS_REGION)
_s3 = _session.client("s3")
_model = None

def _ensure_model_local():
    local = os.path.join(tempfile.gettempdir(), "model.pkl")
    if not os.path.exists(local):
        _s3.download_file(MODEL_BUCKET, MODEL_KEY, local)
    return local

def _load_model():
    global _model
    if _model is None:
        local = _ensure_model_local()
        _model = load(local)
    return _model

class Features(BaseModel):
    feature1: float
    feature2: float

@APP.get("/health")
def health():
    return {"ok": True}

@APP.post("/predict")
def predict(payload: Features):
    model = _load_model()
    y = model.predict([[payload.feature1, payload.feature2]])[0]
    return {"prediction": float(y)}
