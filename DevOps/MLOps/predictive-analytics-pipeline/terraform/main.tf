terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "mlops-terraform-state-975628796846"
    key          = "predictive-analytics/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- include subfolder code as modules ---

module "s3" {
  source = "./s3"
}

module "iam" {
  source = "./iam"
}


module "glue" {
  source          = "./glue"
  glue_role_arn   = module.iam.glue_role_arn
  raw_bucket_name = module.s3.raw_bucket_name

  depends_on = [module.s3, module.iam]
}
module "lambda_trigger" {
  source          = "./lambda"
  lambda_role_arn = module.iam.lambda_exec_role_arn
  glue_job_name   = module.glue.clean_data_job_name
  raw_bucket_name = module.s3.raw_bucket_name
  depends_on      = [module.glue, module.iam, module.s3]
}

