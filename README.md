# cicd-pipeline

![CI/CD](https://github.com/ausmiras-glitch/cicd-pipeline/actions/workflows/pipeline.yml/badge.svg)

push code, it tests itself, builds itself, ships itself. that's it.

live: https://w4ykkr7f5sj25quucysndbnxku0fwbtg.lambda-url.eu-central-1.on.aws/

```
push ─┬─► lint ──┐
      └─► tests ─┴─► docker build + smoke test ─┬─► ghcr.io          (main)
                                                 └─► aws lambda       (main, once aws is set up)
```

## what's in it

- **app/**: tiny FastAPI service. `/`, `/health`, `/version`, `POST /echo`, `/docs`
- **tests/**: pytest, fails under 90% coverage
- **Dockerfile**: slim, non-root, healthcheck. same image runs locally, in CI and on Lambda ([Lambda Web Adapter](https://github.com/awslabs/aws-lambda-web-adapter))
- **.github/workflows/pipeline.yml**: ruff + hadolint → pytest → build and hit the container → push to GHCR → deploy to Lambda
- **infra/bootstrap.yml**: CloudFormation for ECR + IAM. GitHub talks to AWS over OIDC, so there are no keys in secrets
- **scripts/deploy_lambda.sh**: creates or updates the function, gives it a public URL

aws is wired up (frankfurt, lambda + ecr, oidc). setup notes: [docs/aws-setup.md](docs/aws-setup.md).

## run it

```bash
make install
make test
make run          # localhost:8080/docs
make docker-run   # same, in docker
```

MIT
