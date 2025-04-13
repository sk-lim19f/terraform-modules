output "domain_arn" {
  value = { for k, search_engine in aws_opensearch_domain.search_engine : k => search_engine.arn }
}