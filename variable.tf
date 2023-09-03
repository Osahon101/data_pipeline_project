variable "data_bucket_name" {
  description = "Name of the S3 bucket to store incoming JSON data"
  type        = string
  default     = "s3rawawsinbound"
}

variable "lambda_role_name" {
  description = "Name of the IAM role for Lambda functions"
  type        = string
  default     = "mylambdarole"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function for JSON to CSV conversion"
  type        = string
  default     = "mylambdafuntion"
}

variable "csv_output_bucket_name" {
  description = "Name of the S3 bucket to store CSV output"
  type        = string
  default     = "s3refinedbucket"
}

variable "datasource_id" {
  description = "ID for datasource to be created"
  type        = string
  default     = "data_source_id"
}

variable "datasource_name" {
  description = "Name for the datasource to be created"
  type        = string
  default     = "s3datasource"
}

variable "quicksight_dataset_name" {
  description = "Name of the QuickSight dataset"
  type        = string
  default     = "quicksightuser"
}

variable "quicksight_user_email" {
  description = "Name of the QuickSight user "
  type        = string
  default     = "user@example.com"
}

variable "quicksight_session_name" {
  description = "Email of the QuickSight user session"
  type        = string
  default     = "first-user"
}

variable "data_set_id" {
  description = "Indentify for the dataset to be created"
  type        = string
  default     = "dataset1"
}

variable "data_template_id" {
  description = "Indentify for the quicksight visualization to be created"
  type        = string
  default     = "template1"
}

variable "data_template_name" {
  description = "Name for the quicksight visualization to be created"
  type        = string
  default     = "template_name"
}

variable "quicksight_analysis_name" {
  description = "Name of the QuickSight analysis"
  type        = string
  default     = "qanalysis1"
}

variable "quicksight_analysis_id" {
  description = "ID of the QuickSight analysis"
  type        = string
  default     = "qanalysisid"
}

variable "quicksight_dashboard_name" {
  description = "Name of the QuickSight dashboard"
  type        = string
  default     = "mydashboard"
}

variable "quicksight_dashboard_id" {
  description = "ID of the QuickSight dashboard"
  type        = string
  default     = "mdashboardid-1"
}

variable "report_saved_lambda_name" {
  description = "Name of the Lambda function for handling report saved notifications"
  type        = string
  default     = "mylambdafuntion"
}

variable "report_saved_topic_name" {
  description = "Name of the SNS topic for report saved notifications"
  type        = string
  default     = "sns-topic-1"
}

variable "sns_topic_display_name" {
  description = "SNS topic display name"
  type        = string
  default     = "sns-topic-1"
}

variable "sns_topic_subscription_email" {
  description = "SNS topic sucbscription email"
  type        = string
  default     = "useremail@example.com"
}

variable "sns_protocol" {
  description = "SNS topic transfer protocol"
  type        = string
  default     = "email"
}


