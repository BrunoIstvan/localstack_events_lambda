FUNCTION_NAME=lambda-jsonserver-apigateway
DEFAULT_REGION='us-east-1'
API_GATEWAY_NAME='ApiGatewayTest'
STAGE=dev
JSON_SERVER_HOST=172.28.1.2
API_GATEWAY_HOST=172.28.1.3

echo ' >>>>>>>> DELETING LAMBDA FUNCTION '
awslocal lambda delete-function --function-name $FUNCTION_NAME
echo ' <<<<<<<< DELETING LAMBDA FUNCTION '

echo ' >>>>>>>> ZIPPING LAMBDA CODE '
cp lambda_function.py ../.venv/lib/python3.6/site-packages
cd ../.venv/lib/python3.6/site-packages
zip -r lambda.zip lambda_function.py request* chardet* certifi* idna*
mv lambda.zip ${OLDPWD}
cd ${OLDPWD}
echo ' <<<<<<<< ZIPPING LAMBDA CODE '

echo ' >>>>>>>> CREATING LAMBDA CODE '
awslocal lambda create-function \
    --region $DEFAULT_REGION \
    --function-name $FUNCTION_NAME \
    --runtime python3.7 \
    --role irrelevant \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://lambda.zip \
    --environment Variables={'HOST_API_JSON'=$JSON_SERVER_HOST}
echo ' <<<<<<<< CREATING LAMBDA CODE '


echo ' >>>>>>>> GETTING LAMBDA ARN '
LAMBDA_ARN=$(awslocal lambda list-functions \
          --query "Functions[?FunctionName==\`${FUNCTION_NAME}\`].FunctionArn" \
          --output text \
          --region ${DEFAULT_REGION})
echo $LAMBDA_ARN
echo ' <<<<<<<< GETTING LAMBDA ARN '


#echo ' >>>>>>>> DELETING APIGATEWAY IF EXISTS '
#awslocal apigateway delete-rest-api --rest-api-id $API_GATEWAY_NAME
#echo ' <<<<<<<< DELETING APIGATEWAY IF EXISTS '

echo ' >>>>>>>> CREATING APIGATEWAY '
ID_API=$(awslocal apigateway create-rest-api \
    --name $API_GATEWAY_NAME \
    --region $DEFAULT_REGION)
echo 'ID_API: ' $ID_API
echo ' <<<<<<<< CREATING APIGATEWAY '


echo ' >>>>>>>> GETTING APIGATEWAY ID '
API_ID=$(awslocal apigateway get-rest-apis \
    --query "items[?name==\`${API_GATEWAY_NAME}\`].id" \
    --output text \
    --region ${DEFAULT_REGION})
echo 'API_ID: ' $API_ID
echo ' <<<<<<<< GETTING APIGATEWAY ID '


echo ' >>>>>>>> CREATING APIGATEWAY GET-RESOURCES '
PARENT_RESOURCE_ID=$(awslocal apigateway get-resources \
  --rest-api-id ${API_ID} \
  --query 'items[?path==`/`].id' \
  --output text \
  --region ${DEFAULT_REGION})
echo 'PARENT_RESOURCE_ID: ' $PARENT_RESOURCE_ID
echo ' <<<<<<<< CREATING APIGATEWAY GET-RESOURCES '


echo ' >>>>>>>> EXECUTING APIGATEWAY CREATE-RESOURCE '
awslocal apigateway create-resource \
    --region ${DEFAULT_REGION} \
    --rest-api-id ${API_ID} \
    --parent-id ${PARENT_RESOURCE_ID} \
    --path-part "{postId}"
echo ' >>>>>>>> EXECUTING APIGATEWAY CREATE-RESOURCE '

echo ' >>>>>>>> EXECUTING APIGATEWAY GET-RESOURCES '
RESOURCE_ID=$(awslocal apigateway get-resources \
    --rest-api-id ${API_ID} \
    --query 'items[?path==`/{postId}`].id' \
    --output text \
    --region ${DEFAULT_REGION})
echo 'RESOURCE_ID: ' $RESOURCE_ID
echo ' <<<<<<<< EXECUTING APIGATEWAY GET-RESOURCES '

echo ' >>>>>>>> EXECUTING APIGATEWAY PUT-METHOD '
awslocal apigateway put-method \
    --region ${DEFAULT_REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --request-parameters "method.request.path.somethingId=true" \
    --authorization-type "NONE"
echo ' <<<<<<<< EXECUTING APIGATEWAY PUT-METHOD '

echo ' >>>>>>>> EXECUTING APIGATEWAY PUT-INTEGRATION '
awslocal apigateway put-integration \
    --region ${DEFAULT_REGION} \
    --rest-api-id ${API_ID} \
    --resource-id ${RESOURCE_ID} \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:${DEFAULT_REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations \
    --passthrough-behavior WHEN_NO_MATCH
echo ' <<<<<<<< EXECUTING APIGATEWAY PUT-INTEGRATION '

echo ' >>>>>>>> EXECUTING APIGATEWAY CREATE-DEPLOYMENT '
awslocal apigateway create-deployment \
    --region ${DEFAULT_REGION} \
    --rest-api-id ${API_ID} \
    --stage-name ${STAGE}
echo ' <<<<<<<< EXECUTING APIGATEWAY CREATE-DEPLOYMENT '

ENDPOINT=http://${API_GATEWAY_HOST}:4567/restapis/${API_ID}/${STAGE}/_user_request_/HowMuchIsTheFish

echo "API available at: ${ENDPOINT}"




