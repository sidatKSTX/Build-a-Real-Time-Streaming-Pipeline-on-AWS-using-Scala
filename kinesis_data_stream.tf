terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change as needed
}

resource "aws_kinesis_stream" "my_stream" {
  name             = "myInputStream"
  shard_count      = 1
  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
  retention_period = 24
  encryption_type  = "NONE" 
}
