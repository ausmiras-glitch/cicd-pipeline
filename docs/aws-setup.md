# AWS setup (one time, ~10 minutes)

Until this is done, the pipeline still lints, tests, builds the Docker image and
publishes it to GitHub Container Registry. The **Deploy to AWS Lambda** job is skipped.

## 1. Create the AWS resources

1. Sign in to the [AWS Console](https://console.aws.amazon.com/) and pick a region
   (default used by the pipeline: `eu-central-1`, Frankfurt).
2. Open **CloudFormation → Create stack → With new resources**.
3. Upload `infra/bootstrap.yml`.
4. Stack name: `cicd-pipeline-bootstrap`. Set `GitHubOwner` to your GitHub username.
   If the account already has a GitHub OIDC provider, set `CreateOidcProvider` to `false`.
5. Tick "I acknowledge that AWS CloudFormation might create IAM resources" and create.
6. When it finishes, open the **Outputs** tab and copy `AwsRoleArn` and `LambdaRoleArn`.

## 2. Tell GitHub about it

In the GitHub repo: **Settings → Secrets and variables → Actions → Variables → New repository variable**.

| Name | Value |
|---|---|
| `AWS_ROLE_ARN` | `AwsRoleArn` from the stack outputs |
| `LAMBDA_ROLE_ARN` | `LambdaRoleArn` from the stack outputs |
| `AWS_REGION` | the region you used (only if not `eu-central-1`) |

No AWS passwords or access keys are stored in GitHub: the workflow uses OIDC to get
short-lived credentials that only work for this repo.

## 3. Deploy

Push any commit to `main` (or run the workflow manually from the **Actions** tab).
The deploy job prints the live URL and it appears on the repo's **Environments → production** page.

## Cost

Lambda, ECR and CloudWatch Logs all have free tiers; a demo app like this normally stays within them.
To remove everything: delete the Lambda function `cicd-pipeline`, then delete the CloudFormation stack
(empty the ECR repository first).
