variable "network_rule_set" {
  description = <<EOT
The network rule set configuration:
```
network_rule_set = {
  default_action = string # The behaviour for requests matching no rules. Either `Allow` or `Deny`. Defaults to `Allow`
  ip_rules         = [
    {
      action   = "Allow" # The behaviour for requests matching this rule.
      ip_range = string  # The CIDR block from which requests will match the rule.
    },
  ]
  virtual_networks = [
    action    = "Allow" # The behaviour for requests matching this rule.
    subnet_id = string  # The subnet id from which requests will match the rule.
  ]
}
```
EOT
  type = object({
    default_action   = string
    ip_rules         = list(any)
    virtual_networks = list(any)
  })
  default = {
    default_action   = "Allow"
    ip_rules         = []
    virtual_networks = []
  }
}