variable "wifi_ssid" {
  description = "SSID of the WiFi network to connect the Thing to"
}

variable "wifi_password" {
  description = "Password for the WiFi to connect the Thing to"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_iot_thing" "pub_sub_example" {
  name = "pub_sub_example"
}

resource "aws_iot_policy" "pub_sub_example" {
  name = "pub_sub_example"

  policy = data.aws_iam_policy_document.pub_sub_example.json
}

data "aws_iam_policy_document" "pub_sub_example" {
  statement {
    actions   = ["iot:Connect"]
    resources = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:client/${aws_iot_thing.pub_sub_example.name}"]
  }

  statement {
    actions   = ["iot:Subscribe"]
    resources = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topicfilter/example/sub"]
  }

  statement {
    actions   = ["iot:Receive"]
    resources = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/example/sub"]
  }

  statement {
    actions   = ["iot:Publish"]
    resources = ["arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/example/pub"]
  }
}

resource "aws_iot_policy_attachment" "pub_sub_example" {
  policy = aws_iot_policy.pub_sub_example.name
  #  target = var.aws_iot_certificate_arn
  target = aws_iot_certificate.pub_sub_example.arn
}

resource "aws_iot_certificate" "pub_sub_example" {
  active = true
}

resource "aws_iot_thing_principal_attachment" "certificate" {
  principal = aws_iot_certificate.pub_sub_example.arn
  thing     = aws_iot_thing.pub_sub_example.name
}

data "aws_iot_endpoint" "endpoint" {
  endpoint_type = "iot:Data-ATS"
}

data "http" "iot_root_ca_cert" {
  url = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"
}

resource "local_file" "secrets" {
  filename = "${path.module}/secrets.h"

  content = templatefile("secrets.h.tpl", {
    thing_name         = aws_iot_thing.pub_sub_example.name,
    wifi_ssid          = var.wifi_ssid,
    wifi_password      = var.wifi_password,
    iot_endpoint       = data.aws_iot_endpoint.endpoint.endpoint_address,
    device_certificate = aws_iot_certificate.pub_sub_example.certificate_pem,
    private_key        = aws_iot_certificate.pub_sub_example.private_key,
    ca_cert            = data.http.iot_root_ca_cert.body
  })
}
