#!/usr/bin/env bash
# Create or update a container-image Lambda function and expose it via a Function URL.
# Usage: FUNCTION_NAME=... LAMBDA_ROLE_ARN=... ./scripts/deploy_lambda.sh <image-uri>
set -euo pipefail

IMAGE_URI="${1:?image URI required}"
: "${FUNCTION_NAME:?FUNCTION_NAME required}"

if aws lambda get-function --function-name "$FUNCTION_NAME" >/dev/null 2>&1; then
  echo "Updating $FUNCTION_NAME -> $IMAGE_URI"
  aws lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --image-uri "$IMAGE_URI" >/dev/null
  aws lambda wait function-updated-v2 --function-name "$FUNCTION_NAME"
else
  : "${LAMBDA_ROLE_ARN:?LAMBDA_ROLE_ARN required to create the function}"
  echo "Creating $FUNCTION_NAME from $IMAGE_URI"
  aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --package-type Image \
    --code "ImageUri=$IMAGE_URI" \
    --role "$LAMBDA_ROLE_ARN" \
    --architectures x86_64 \
    --memory-size 512 \
    --timeout 15 >/dev/null
  aws lambda wait function-active-v2 --function-name "$FUNCTION_NAME"
fi

if ! aws lambda get-function-url-config --function-name "$FUNCTION_NAME" >/dev/null 2>&1; then
  echo "Creating public Function URL"
  aws lambda create-function-url-config \
    --function-name "$FUNCTION_NAME" \
    --auth-type NONE >/dev/null
  aws lambda add-permission \
    --function-name "$FUNCTION_NAME" \
    --statement-id public-url \
    --action lambda:InvokeFunctionUrl \
    --principal "*" \
    --function-url-auth-type NONE >/dev/null
  aws lambda add-permission \
    --function-name "$FUNCTION_NAME" \
    --statement-id public-url-invoke \
    --action lambda:InvokeFunction \
    --principal "*" \
    --invoked-via-function-url >/dev/null \
    || echo "::warning::Could not add lambda:InvokeFunction permission; the URL may return 403"
fi

URL="$(aws lambda get-function-url-config --function-name "$FUNCTION_NAME" --query FunctionUrl --output text)"
echo "Live at: $URL"
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "url=$URL" >> "$GITHUB_OUTPUT"
fi
