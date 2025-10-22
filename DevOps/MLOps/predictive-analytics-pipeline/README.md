love it. here are drop-in, “useful but short” `README.md` files for each folder + one-liners to create them and commit.

## 1) create/update all READMEs (copy–paste)

Run these from your repo root:
`/Users/vansh/Vansh_DevOpS/DevOps/MLOps/predictive-analytics-pipeline`

````bash
# --- root README (keeps your existing one, but appends a section) ---
cat >> README.md <<'MD'

---

## Repository Map

- `api/` — FastAPI prediction service (loads model from S3)
- `train/` — Local trainer producing `model.pkl`
- `glue_scripts/` — Glue ETL scripts
- `terraform/` — IaC for S3, IAM, Glue, Lambda (trigger), ECR, ECS (Fargate), ALB
MD

# --- api/README.md ---
mkdir -p api
cat > api/README.md <<'MD'
# api

FastAPI microservice that loads a scikit-learn model from S3 and serves `/predict`.

## Endpoints
- `GET /health` — health check
- `POST /predict` — body: `{"feature1": float, "feature2": float}` → `{"prediction": float}`

## Local Run
```bash
docker build -t predictive-api:local .
docker run --rm -p 8080:8080 \
  -e AWS_REGION=us-east-1 \
  -e MODEL_BUCKET=mlops-predictive-model-975628796846 \
  -e MODEL_KEY=model.pkl \
  -v ~/.aws:/root/.aws:ro \
  predictive-api:local
````

## Environment Variables

* `AWS_REGION` (default `us-east-1`)
* `MODEL_BUCKET` (default `mlops-predictive-model-975628796846`)
* `MODEL_KEY` (default `model.pkl`)
  MD

# --- train/README.md ---

mkdir -p train
cat > train/README.md <<'MD'

# train

Minimal local trainer that:

1. downloads `data.csv` from the RAW bucket,
2. builds `y = f1 + f2` toy target,
3. trains a `LinearRegression`,
4. saves `model.pkl`.

## Usage

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt  # if you add one, else install pandas scikit-learn joblib
python3 train/train_model.py
aws s3 cp model.pkl s3://mlops-predictive-model-975628796846/model.pkl
```

## Notes

* Script expects `s3://mlops-predictive-raw-975628796846/data.csv`.
* Set `RAW_BUCKET` env var to override.
  MD

# --- glue_scripts/README.md ---

mkdir -p glue_scripts
cat > glue_scripts/README.md <<'MD'

# glue_scripts

AWS Glue ETL scripts (Glue 4.0, Spark). Default script:

* `clean_data.py` — reads CSV from RAW, writes a tiny JSON summary to PROCESSED.

## Expected Paths

* Script location: `s3://mlops-predictive-raw-975628796846/scripts/clean_data.py`
* Input example: `s3://mlops-predictive-raw-975628796846/data.csv`
* Output example: `s3://mlops-predictive-processed-975628796846/output/`

## Run (manual)

```bash
aws glue start-job-run --job-name clean-data-job
aws glue get-job-runs --job-name clean-data-job --max-results 1
```

MD

# --- terraform/README.md ---

mkdir -p terraform
cat > terraform/README.md <<'MD'

# terraform

Infrastructure for the predictive analytics pipeline:

* S3 buckets (raw/processed/model)
* IAM (Glue role, Lambda role, ECS roles)
* Glue job (clean-data-job)
* Lambda (trigger -> starts Glue job)
* ECR (predictive-api)
* ECS Fargate service + ALB (serves FastAPI)

## Backend

State stored in `s3://mlops-terraform-state-975628796846` (configured in `main.tf`).

## Commands

```bash
terraform init -reconfigure -upgrade
terraform validate
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
```

## Destroy

```bash
# empty buckets first
aws s3 rm s3://mlops-predictive-raw-975628796846 --recursive || true
aws s3 rm s3://mlops-predictive-processed-975628796846 --recursive || true
aws s3 rm s3://mlops-predictive-model-975628796846 --recursive || true
terraform destroy -auto-approve
```

MD

# --- terraform/s3/README.md ---

mkdir -p terraform/s3
cat > terraform/s3/README.md <<'MD'

# terraform/s3

Defines three S3 buckets:

* RAW: `mlops-predictive-raw-975628796846`
* PROCESSED: `mlops-predictive-processed-975628796846`
* MODEL: `mlops-predictive-model-975628796846`

Outputs:

* `raw_bucket_name`, `processed_bucket_name`, `model_bucket_name`

Optional: S3 → Lambda notifications for auto-triggering Glue via Lambda.
MD

# --- terraform/glue/README.md ---

mkdir -p terraform/glue
cat > terraform/glue/README.md <<'MD'

# terraform/glue

Creates Glue job:

* name: `clean-data-job`
* version: Glue 4.0
* script_location: `s3://<raw>/scripts/clean_data.py`

Inputs (variables):

* `glue_role_arn` — from IAM module
* `raw_bucket_name` — from S3 module

Outputs:

* `clean_data_job_name`
  MD

# --- terraform/iam/README.md ---

mkdir -p terraform/iam
cat > terraform/iam/README.md <<'MD'

# terraform/iam

IAM roles/policies for:

* Glue role (assume `glue.amazonaws.com`, `AWSGlueServiceRole` + S3 read RAW/write PROCESSED + Glue assets)
* Lambda exec role (basic logs + `glue:StartJobRun`)
* ECS execution role (`AmazonECSTaskExecutionRolePolicy`)
* ECS task role (S3 read on MODEL bucket)

Outputs:

* `glue_role_arn`
* `lambda_exec_role_arn`
* `ecs_task_role_arn`
* `ecs_execution_role_arn`
  MD

# --- terraform/lambda/README.md ---

mkdir -p terraform/lambda
cat > terraform/lambda/README.md <<'MD'

# terraform/lambda

Lambda function `trigger-pipeline`:

* Invokes `StartJobRun` on the Glue job (env var `GLUE_JOB_NAME`).
* Can be hooked to S3 ObjectCreated events (optional).

Inputs (variables):

* `lambda_role_arn` — IAM role for Lambda execution
* `glue_job_name`
* `raw_bucket_name` (if using S3 notification permission in module)
  MD

````

## 2) add & commit & push

```bash
git add README.md api/README.md train/README.md glue_scripts/README.md \
  terraform/README.md terraform/s3/README.md terraform/glue/README.md \
  terraform/iam/README.md terraform/lambda/README.md

git commit -m "docs: add meaningful READMEs per subfolder"
git push
````

If any folder path differs in your repo, tell me which ones and I’ll tweak the content/commands accordingly.
