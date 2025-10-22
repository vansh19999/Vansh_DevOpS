import os, subprocess, pandas as pd
from sklearn.linear_model import LinearRegression
from joblib import dump

RAW_BUCKET = os.environ.get("RAW_BUCKET", "mlops-predictive-raw-975628796846")
LOCAL_CSV  = "/tmp/data.csv"
S3_PATH    = f"s3://{RAW_BUCKET}/data.csv"

# pull data.csv locally (assumes AWS CLI configured)
subprocess.run(["aws", "s3", "cp", S3_PATH, LOCAL_CSV, "--region", "us-east-1"], check=True)

df = pd.read_csv(LOCAL_CSV)
# simple target for demo: y = f1 + f2
df["y"] = df["f1"].astype(float) + df["f2"].astype(float)

X = df[["f1", "f2"]].astype(float).values
y = df["y"].values

model = LinearRegression()
model.fit(X, y)

dump(model, "model.pkl")
print("Saved model.pkl")
