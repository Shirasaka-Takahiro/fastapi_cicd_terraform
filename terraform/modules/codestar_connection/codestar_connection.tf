locals {
  name_prefix = "${var.project}-${var.env}"
}

resource "aws_codestarconnections_connection" "this" {
  name          = "${local.name_prefix}-github"
  provider_type = "GitHub"

  tags = {
    Name = "${local.name_prefix}-github-connection"
  }
}
