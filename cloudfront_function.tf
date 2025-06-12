# CloudFront function for serving root objects in subfolders
resource "aws_cloudfront_function" "subfolder_root_object" {
  count = local.create_subfolder_function ? 1 : 0

  name    = "${var.cloudfront_distribution_name}-subfolder-root-object"
  runtime = "cloudfront-js-2.0"
  comment = "Serves ${var.subfolder_root_object} as default object for subfolder requests"
  publish = true

  code = <<-EOT
    function handler(event) {
      var request = event.request;
      var uri = request.uri;
      
      // If URI ends with '/' but is NOT the root path, append the configured root object
      if (uri.endsWith('/') && uri !== '/') {
        request.uri += '${var.subfolder_root_object}';
      }
      
      return request;
    }
  EOT
}
