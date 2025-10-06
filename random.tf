# Generate random postfix for resource names
resource "random_string" "postfix" {
  length  = 6
  special = false
  upper   = false
}