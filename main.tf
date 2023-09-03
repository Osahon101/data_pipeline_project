# S3 bucket to store incoming JSON data
resource "aws_s3_bucket" "data_bucket" {
  bucket = var.data_bucket_name
}

# S3 bucket to store incoming CSV data
resource "aws_s3_object" "json_object" {
  bucket = var.data_bucket_name
  key    = "data.json"
  source = "./data.json"
  depends_on = [ 
    aws_s3_bucket.data_bucket
   ]
}

# S3 bucket to store the CSV output
resource "aws_s3_bucket" "csv_bucket" {
  bucket = var.csv_output_bucket_name

}

# S3 bucket notification to trigger when objects are created
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.csv_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.json_to_csv_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
# Role for Lambda function
resource "aws_iam_role" "role_lambda" {
  name = "roleLambda"

  assume_role_policy = <<-POLICY
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
  POLICY
}

# Lambda function to convert JSON to CSV
resource "aws_lambda_function" "json_to_csv_lambda" {
  function_name    = var.lambda_function_name
  handler          = "lambda_function.handler"
  runtime          = "python3.8"
  s3_bucket =  aws_s3_bucket.csv_bucket.bucket
  s3_key = "data.csv"
  #filename = "lambda_function.zip"
  source_code_hash = filebase64("./lambda_function.zip")
  role             = aws_iam_role.role_lambda.arn
  
  environment {
    variables = {
      OUTPUT_BUCKET = aws_s3_bucket.csv_bucket.id
    }
  }
}

# Lambda function to handle the report saved notification
resource "aws_lambda_function" "report_saved_lambda" {
  function_name    = var.report_saved_lambda_name
  handler          = "lambda_function.handler"
  runtime          = "python3.8"
  filename = "lambda_function.zip"
  role             = aws_iam_role.role_lambda.arn
  source_code_hash = filebase64("./lambda_function.zip")

  environment {
    variables = {
      NOTIFICATION_TOPIC = aws_sns_topic.report_topic.arn
    }
  }
}

# SNS topic for sending notifications
resource "aws_sns_topic" "report_topic" {
  name         = var.report_saved_topic_name
  display_name = var.sns_topic_display_name
}

# SNS topic permission for sending notifications
resource "aws_lambda_permission" "sns_publish_permission" {
  statement_id  = "AllowSNSPublish"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.json_to_csv_lambda.function_name
  principal     = "sns.amazonaws.com"

  source_arn = aws_sns_topic.report_topic.arn
}

# SNS topic subscription to publish notifications
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.report_topic.arn
  protocol  = var.sns_protocol
  endpoint  = var.sns_topic_subscription_email
}

# Quicksight data source configuration
resource "aws_quicksight_data_source" "datasource" {
  data_source_id = var.datasource_id
  name           = var.datasource_name

  parameters {
    s3 {
      manifest_file_location {
        bucket = aws_s3_bucket.csv_bucket.bucket
        key    = "data.csv"
      }
    }
  }

  type = "S3"
}

# Define the QuickSight dataset, analysis, and dashboard
resource "aws_quicksight_data_set" "quicksight_dataset" {
  name        = var.quicksight_dataset_name
  data_set_id = var.data_set_id
  import_mode = "SPICE"

  physical_table_map {
    physical_table_map_id = "dataset-id"
    s3_source {
      data_source_arn = aws_quicksight_data_source.datasource.arn
      input_columns {
        name = "Column1"
        type = "STRING"
      }
      upload_settings {
        format = "CSV"
      }
    }
  }
  column_level_permission_rules {
    column_names = ["Column1"]
    
  }
}

# Quicksight template configuration
resource "aws_quicksight_template" "visual_template" {
  template_id         = var.data_template_id
  name                = var.data_template_name
  version_description = "v1.0"
  definition {
    data_set_configuration {
      data_set_schema {
        column_schema_list {
          name      = "Column1"
          data_type = "STRING"
        }
        column_schema_list {
          name      = "Column2"
          data_type = "INTEGER"
        }
      }
      placeholder = "1"
    }
    sheets {
      title    = "Test"
      sheet_id = "Test1"
      visuals {
        bar_chart_visual {
          visual_id = "BarChart"
          chart_configuration {
            field_wells {
              bar_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "1"
                    column {
                      column_name         = "Column1"
                      data_set_identifier = "1"
                    }
                  }
                }
                values {
                  numerical_measure_field {
                    field_id = "2"
                    column {
                      column_name         = "Column2"
                      data_set_identifier = "1"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

# Quicksight data anlysis configuration
resource "aws_quicksight_analysis" "firstanalysis" {
  analysis_id = var.quicksight_analysis_id
  name        = var.quicksight_analysis_name

  source_entity {
    source_template {
      arn = aws_quicksight_template.visual_template.arn
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.quicksight_dataset.arn
        data_set_placeholder = "1"
      }
    }
  }
}

# Quicksight data dispplay dashboard configuration
resource "aws_quicksight_dashboard" "quicksight_dashboard" {
  name                = var.quicksight_dashboard_name
  dashboard_id        = var.quicksight_dashboard_id
  version_description = "v1.0"
  source_entity {
    source_template {
      arn = aws_quicksight_template.visual_template.arn
      data_set_references {
        data_set_arn         = aws_quicksight_data_set.quicksight_dataset.arn
        data_set_placeholder = "1"
      }
    }
  }
}

# Define an S3 bucket notification to trigger when a CSV report is saved
resource "aws_s3_bucket_notification" "report_saved_notification" {
  bucket = aws_s3_bucket.csv_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.report_saved_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}


