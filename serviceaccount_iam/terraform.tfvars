irsa_list = [
  {
    name            = "external-dns"
    namespace       = "dns"
    service_account = "external-dns"
    iam_role_arn    = "arn:aws:iam::123456789012:role/external-dns-role"
  },
  {
    name            = "prometheus"
    namespace       = "monitoring"
    service_account = "prometheus"
    iam_role_arn    = "arn:aws:iam::123456789012:role/prometheus-role"
  },
  {
    name            = "app-backend"
    namespace       = "backend"
    service_account = "app-sa"
    iam_role_arn    = "arn:aws:iam::123456789012:role/app-s3-reader"
  }
]
