aws --endpoint-url=http://localhost:4574 lambda delete-function \
--function-name lambda-demo


aws --endpoint-url=http://localhost:4574 lambda create-function \
--region 'us-east-1' \
--function-name lambda-demo \
--runtime python3.7 \
--role arn:aws:iam::123456:role/irrelevant \
--handler lambda_function.lambda_handler \
--zip-file fileb://lambda.zip

aws --endpoint-url=http://localhost:4574 lambda invoke \
--function-name lambda-demo out --log-type Tail

aws --endpoint-url=http://localhost:4587 events put-rule \
--name my-scheduled-rule \
--schedule-expression 'rate(1 minute)'

aws --endpoint-url="http://localhost:4574" lambda add-permission \
--function-name "arn:aws:lambda:us-east-1:000000000000:function:lambda-demo" \
--statement-id my-scheduled-event \
--action 'lambda:InvokeFunction' \
--principal events.amazonaws.com \
--source-arn "arn:aws:events:us-west-2:111111111111:rule/my-scheduled-rule"

aws events put-targets --rule my-scheduled-rule --targets file://targets.json