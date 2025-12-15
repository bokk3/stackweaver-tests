# Generate a random ID for the server
resource "random_id" "server" {
  byte_length = 8
}


# Create 10 resources that each take ~20 seconds to apply
# This allows testing real-time polling and status updates during apply


resource "time_sleep" "resource_1" {
  create_duration = "5s"
}

resource "null_resource" "resource_1" {
  depends_on = [time_sleep.resource_1]
  
  provisioner "local-exec" {
    command = "echo 'Resource 1 created'"
  }
}

resource "time_sleep" "resource_2" {
  create_duration = "10s"
}

resource "null_resource" "resource_2" {
  depends_on = [time_sleep.resource_2]
  
  provisioner "local-exec" {
    command = "echo 'Resource 2 created'"
  }
}

resource "time_sleep" "resource_3" {
  create_duration = "15s"
}

resource "null_resource" "resource_3" {
  depends_on = [time_sleep.resource_3]
  
  provisioner "local-exec" {
    command = "echo 'Resource 3 created'"
  }
}

resource "time_sleep" "resource_4" {
  create_duration = "20s"
}

resource "null_resource" "resource_4" {
  depends_on = [time_sleep.resource_4]
  
  provisioner "local-exec" {
    command = "echo 'Resource 4 created'"
  }
}




# Original server resource (kept for compatibility)
resource "null_resource" "server" {
  triggers = {
    server_id   = random_id.server.hex
    timestamp   = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'Deploying server ${random_id.server.hex}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Destroying server ${self.triggers.server_id}'"
  }
}

# Deprecated resource for testing deprecation warnings
# Using AWS instance with deprecated associate_public_ip_address attribute
# This will generate a deprecation warning: "Warning: Argument is deprecated"
# The associate_public_ip_address attribute is deprecated in favor of network_interface blocks
resource "aws_instance" "deprecated_test" {
  ami           = "ami-0c55b159cbfafe1f0" # Example AMI - replace with valid AMI for your region
  instance_type = "t2.micro"

  # DEPRECATED: This attribute is deprecated and will generate a warning
  # Use network_interface blocks instead
  associate_public_ip_address = true

  tags = {
    Name        = "deprecated-test-instance"
    Purpose     = "Testing deprecation warnings in StackWeaver"
    Environment = "test"
  }
}
