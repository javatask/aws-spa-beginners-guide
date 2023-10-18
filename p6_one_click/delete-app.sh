#!/bin/bash
export AWS_DEFAULT_REGION=eu-central-1
echo "AWS Region is $AWS_DEFAULT_REGION"

###
echo Deleting Backend
aws cloudformation delete-stack \
    --stack-name one-click-backend

###
cognitoPoolId=$(aws cloudformation describe-stacks --stack-name one-click-openid --query 'Stacks[0].Outputs[?OutputKey==`CognitoPoolId`].OutputValue' --output text)
echo "Cognito Pool Id $cognitoPoolId"

###
echo Deleting AWS Cognito User Pool stack
aws cloudformation delete-stack \
    --stack-name one-click-openid

### 
echo Deleting 
aws cognito-idp delete-user-pool --user-pool-id $cognitoPoolId
 
### Empty s3 bucket
echo Empty s3 bucket
s3Bucket=$(aws cloudformation describe-stacks --stack-name one-click-frontend --query 'Stacks[0].Outputs[?OutputKey==`BucketWithStaticAssets`].OutputValue' --output text)
aws s3 rm --recursive s3://$s3Bucket

s3LogsBucket=$(aws cloudformation describe-stacks --stack-name one-click-frontend --query 'Stacks[0].Outputs[?OutputKey==`LogsBucket`].OutputValue' --output text)
aws s3 rm --recursive s3://$s3LogsBucket

###
echo Deleting Frontend
aws cloudformation delete-stack \
    --stack-name one-click-frontend