provider "aws" {
  region  = "us-east-1"
}

# Creating an S3 bucket with the random suffix.

resource "aws_s3_bucket" "assessment_bucket" {
  bucket_prefix = "sow-test-"  
  acl           = "private"
}

# Uploading the local file "index.html" to the s3 bucket

resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.assessment_bucket.bucket
  key    = "index.html"
  source = "index.html"
  acl    = "private" 
}

# Creating the security group to allow inbound traffic for specifi IP

resource "aws_security_group" "allow_specific_ip" {
  name        = "allow_specific_ip"
  description = "Allow inbound traffic from specific IP"
  

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["3.121.56.176/32"]  
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.assessment_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.assessment_bucket.arn}/index.html"
      Condition = {
        IpAddress : {
          "aws:SourceIp" : "3.121.56.176/32"  
        }
      }
    }]
  })
}
