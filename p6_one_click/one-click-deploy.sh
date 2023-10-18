#!/bin/bash
# Please provide a single parameter to the script, 
# the container URL. 
# Example ./one-click-deploy.sh 11111111.dkr.ecr.eu-central-1.amazonaws.com/xxx:spring-rest-api
export AWS_DEFAULT_REGION=eu-central-1
echo "AWS Region is $AWS_DEFAULT_REGION"

###
# Check if the number of parameters is not equal to 1
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <container-url>"
  echo "Please provide a single parameter, the container URL. Example 11111111.dkr.ecr.eu-central-1.amazonaws.com/xxx:spring-rest-api"
  exit 1
fi
containerUrl="$1"
# You can add more code here to work with the container_url variable
echo "Container URL provided: $containerUrl"

###
echo Deploing initial AWS Cognito User Pool
aws cloudformation deploy \
    --stack-name one-click-openid \
    --template-file ./templates/openid.yaml \
    --parameter-overrides CallbackUrl=https://example.com/callback

cognitoPoolArn=$(aws cloudformation describe-stacks --stack-name one-click-openid --query 'Stacks[0].Outputs[?OutputKey==`CognitoPoolArn`].OutputValue' --output text)
echo "Cognito Pool ARN $cognitoPoolArn"

cognitoPoolId=$(aws cloudformation describe-stacks --stack-name one-click-openid --query 'Stacks[0].Outputs[?OutputKey==`CognitoPoolId`].OutputValue' --output text)
echo "Cognito Pool Id $cognitoPoolId"

oAuthClientId=$(aws cloudformation describe-stacks --stack-name one-click-openid --query 'Stacks[0].Outputs[?OutputKey==`OAuthClientId`].OutputValue' --output text)
echo "OAuth Client Id $oAuthClientId"

###
echo Adding user named test with password password
aws cognito-idp admin-create-user --user-pool-id $cognitoPoolId --username test --temporary-password password --user-attributes Name=email,Value=name@example.com

###
echo Deploing Backend
aws cloudformation deploy \
    --stack-name one-click-backend \
    --template-file ./templates/backend.yaml \
    --parameter-overrides CognitoPoolArn=$cognitoPoolArn ContainerURI=$containerUrl \
    --capabilities CAPABILITY_IAM

apiDomain=$(aws cloudformation describe-stacks --stack-name one-click-backend --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayDomain`].OutputValue' --output text)

apiStage=$(aws cloudformation describe-stacks --stack-name one-click-backend --query 'Stacks[0].Outputs[?OutputKey==`ApiGatewayStage`].OutputValue' --output text)

echo "apiUrl https://${apiDomain}/${apiStage}"

###
echo Deploing Frontend
aws cloudformation deploy \
    --stack-name one-click-frontend \
    --template-file ./templates/frontend.yaml \
    --parameter-overrides APIEndpoint=$apiDomain APIEndpointStage=$apiStage

websiteUrl=$(aws cloudformation describe-stacks --stack-name one-click-frontend --query 'Stacks[0].Outputs[?OutputKey==`URL`].OutputValue' --output text)

s3bucket=$(aws cloudformation describe-stacks --stack-name one-click-frontend --query 'Stacks[0].Outputs[?OutputKey==`BucketWithStaticAssets`].OutputValue' --output text)

echo "Website URL: $websiteUrl"

###
echo Updating Cognito callback URL
aws cloudformation deploy \
    --stack-name one-click-openid \
    --template-file ./templates/openid.yaml \
    --parameter-overrides CallbackUrl="$websiteUrl/callback.html"

###
echo Building website
cd frontend

cat > src/settings.js << EOL
export const settings = {
    authority: 'https://cognito-idp.eu-central-1.amazonaws.com/$cognitoPoolId',
    client_id: '$oAuthClientId',
    redirect_uri: '$websiteUrl/callback.html',
    response_type: 'code',
    scope: 'openid',
    revokeTokenTypes: ["refresh_token"],
    automaticSilentRenew: false,
};
EOL
echo "settings.js file has been created"

npm i
npm run build
aws s3 sync dist/ s3://$s3bucket
cd ..