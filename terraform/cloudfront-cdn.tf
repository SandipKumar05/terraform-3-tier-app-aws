resource "aws_s3_bucket" "cloudfront_bucket" {
  bucket = "demo-sandip-cloudfront-cdn"
}

resource "aws_s3_bucket_public_access_block" "cloudfront_bucket_acl" {
  bucket              = aws_s3_bucket.cloudfront_bucket.id
  block_public_policy = false
  block_public_acls   = false
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI"
}

resource "aws_cloudfront_distribution" "cf_dist" {
  enabled = true
  origin {
    domain_name = aws_s3_bucket.cloudfront_bucket.bucket_domain_name
    origin_id   = aws_s3_bucket.cloudfront_bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.cloudfront_bucket.id
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN", "US", "CA"]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
