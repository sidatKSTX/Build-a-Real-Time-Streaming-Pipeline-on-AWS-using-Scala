resource "aws_s3_bucket" "testtrajectory" {
  bucket = "test-trajectory-projectpro"
}

resource "aws_s3_object" "trajectory_folder" {
  bucket = aws_s3_bucket.testtrajectory.id
  key    = "trajectory/"
  acl    = "private"
}
