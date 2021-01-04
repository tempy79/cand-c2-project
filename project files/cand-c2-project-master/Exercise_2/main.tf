provider "aws" {
   region = var.region
}


resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}


resource "aws_cloudwatch_log_group" "example" {
  name              = "example"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_cloudwatch_log_stream" "foo" {
  name           = "SampleLogStream1234"
  log_group_name = "${aws_cloudwatch_log_group.example.name}"
}


resource "aws_lambda_function" "example" {
   function_name = "ServerlessExample"

   # The bucket name as created earlier with "aws s3api create-bucket"
   s3_bucket = "terraformserverlessexample2"
   s3_key    = "v1.0.0/example.zip"

   # "main" is the filename within the zip file (main.js) and "handler"
   # is the name of the property under which the handler function was
   # exported in that file.
   handler = "greet_lambda.lambda_handler"
   runtime     = "python3.7"
   role = aws_iam_role.lambda_exec.arn
   
   vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [aws_subnet.main.id]
    security_group_ids = [aws_default_security_group.default.id]
	}
	
	 # ... other configuration ...
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.example,
  ]

}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
    role       = aws_iam_role.lambda_exec.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

 # IAM role which dictates what other AWS services the Lambda function
 # may access.
resource "aws_iam_role" "lambda_exec" {
   name = "serverless_example_lambda"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

  