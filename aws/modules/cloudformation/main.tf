resource "aws_cloudformation_stack" "glean-bootstrap" {
  name = "glean-bootstrap"
  parameters = {
    ContactEmail = var.contact_email
  }
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  template_url = var.cloudformation_bootstrap_template_uri
}
