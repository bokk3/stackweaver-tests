resource "local_file" "deprecated_test" {
  filename = "${path.module}/test.txt"
  content  = "test"
}

output "file_content" {
  value = local_file.deprecated_test.content
}
