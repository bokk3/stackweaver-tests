# Test workspace for deprecated resource warnings
# This workspace uses deprecated attributes to test deprecation warning detection

# Using AWS provider with deprecated attribute
# The associate_public_ip_address attribute is deprecated in favor of network_interface
resource "aws_instance" "test_deprecated" {
  ami           = "ami-0c55b159cbfafe1f0" # Example AMI (will fail but will show deprecation warning)
  instance_type = "t2.micro"

  # This attribute is deprecated - will generate deprecation warning
  associate_public_ip_address = true

  tags = {
    Name = "test-deprecated-instance"
  }
}

# Alternative: Using deprecated resource (if available)
# Some providers have deprecated resource types that still work but show warnings

