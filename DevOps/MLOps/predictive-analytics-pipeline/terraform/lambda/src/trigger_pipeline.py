import os, boto3
def lambda_handler(event, context):
    glue = boto3.client('glue')
    job  = os.environ.get('GLUE_JOB_NAME')
    if job:
        glue.start_job_run(JobName=job)
    return {"ok": True, "job": job}
