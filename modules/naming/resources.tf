locals {
  instance_number = {
    general = "%03d"
    windows = "%02d"
  }
  // Sources: 
  // - https://raw.githubusercontent.com/Azure/terraform-azurerm-naming/master/resourceDefinition.json
  // - https://raw.githubusercontent.com/Azure/terraform-azurerm-naming/master/resourceDefinition_out_of_docs.json
  // Fix:
  // - for windows server, change regex
  //   from: "^(?=.{1,15}$)[^\\\\/\\\"\\[\\]:|<>+=;,?*@&_][^\\\\/\\\"\\[\\]:|<>+=;,?*@&]+[^\\\\/\\\"\\[\\]:|<>+=;,?*@&.-]$",
  //   to:   "regex": "^(?=.{1,15}$)[a-zA-Z0-9-]+$",
  conf_resource      = jsondecode(file("${path.module}/config/resourceDefinition.json"))
  conf_cloudprovider = jsondecode(file("${path.module}/config/cloudproviderDefinition.json"))
  conf_region        = jsondecode(file("${path.module}/config/regionDefinition.json"))
  conf_env           = jsondecode(file("${path.module}/config/envDefinition.json"))
}

locals {
  // For return result in output
  result = [
    for i in var.resource_list : {
      resource_type = i.resource_type, names = distinct([
        for n in range(0, i.instance_count) :
        i.resource_type == "avd_host" ? (
          lower("${[for x in local.conf_resource : x if x.name == i.resource_type][0].slug}${i.resource_name}${local.conf_cloudprovider[var.resource_cp]}${local.conf_region[var.resource_region].code}${local.conf_env[var.resource_env]}")
          ) : (
          replace(i.resource_type, "windows", "") != i.resource_type || i.resource_type == "batch_pool" || i.resource_type == "service_fabric_cluster" ? (
            lower("${[for x in local.conf_resource : x if x.name == i.resource_type][0].slug}${i.resource_name}${local.conf_cloudprovider[var.resource_cp]}${local.conf_region[var.resource_region].code}${local.conf_env[var.resource_env]}${format(local.instance_number.windows, n + i.instance_start)}")
            ) : (
            try([for x in local.conf_resource : x if x.name == i.resource_type][0].dashes, false) ? (
              try([for x in local.conf_resource : x if x.name == i.resource_type][0].cases, "any") == "lower" ? (
                lower("${[for x in local.conf_resource : x if x.name == i.resource_type][0].slug}-${i.resource_name}-${var.resource_cp}-${local.conf_region[var.resource_region].abbr}-${var.resource_env}-${format(local.instance_number.general, n + i.instance_start)}")
                ) : (
                "${[for x in local.conf_resource : x if x.name == i.resource_type][0].slug}-${i.resource_name}-${var.resource_cp}-${local.conf_region[var.resource_region].abbr}-${var.resource_env}-${format(local.instance_number.general, n + i.instance_start)}"
              )
              ) : (
              try([for x in local.conf_resource : x if x.name == i.resource_type][0].cases, "any") == "lower" ? (
                lower("${[for x in local.conf_resource : x if x.name == i.resource_type][0].slug}${i.resource_name}${var.resource_cp}${local.conf_region[var.resource_region].abbr}${var.resource_env}${format(local.instance_number.general, n + i.instance_start)}")
                ) : (
                "${[for x in local.conf_resource : x if x.name == i.resource_type][0].slug}${i.resource_name}${var.resource_cp}${local.conf_region[var.resource_region].abbr}${var.resource_env}${format(local.instance_number.general, n + i.instance_start)}"
              )
            )
          )
        )
      ])
    }
  ]
  // For tempolarily use
  _name-type = [
    for i in local.result : {
      for n in i.names :
      n => i.resource_type
    }
  ]
  // For naming validation
  name-type = zipmap(
    flatten(
      [for item in local._name-type : keys(item)]
    ),
    flatten(
      [for item in local._name-type : values(item)]
    )
  )
}

// Validate Naming
# resource "errorcheck_is_valid" "naming_validation" {
#   for_each = local.name-type
#   name     = "validate type=${each.value} name=${each.key}"
#   test = {
#     assert        = length(each.key) >= [for x in local.conf_resource : x if x.name == each.value][0].length.min && length(each.key) <= [for x in local.conf_resource : x if x.name == each.value][0].length.max && can(regex(replace([for x in local.conf_resource : x if x.name == each.value][0].regex, "/^\\^\\([^\\)]*\\)/", "^"), each.key))
#     error_message = format("Fail to validate name of %s ==> %s against regex=%s, min=%d, max=%d", each.value, each.key, replace([for x in local.conf_resource : x if x.name == each.value][0].regex, "/^\\^\\([^\\)]*\\)/", "^"), [for x in local.conf_resource : x if x.name == each.value][0].length.min, [for x in local.conf_resource : x if x.name == each.value][0].length.max)
#   }
# }

# External Module => https://github.com/rhythmictech/terraform-terraform-errorcheck
module "naming_validation" {
  source  = "rhythmictech/errorcheck/terraform"
  version = "~> 1.3.0"

  for_each = local.name-type

  assert        = length(each.key) >= [for x in local.conf_resource : x if x.name == each.value][0].length.min && length(each.key) <= [for x in local.conf_resource : x if x.name == each.value][0].length.max && can(regex(replace([for x in local.conf_resource : x if x.name == each.value][0].regex, "/^\\^\\([^\\)]*\\)/", "^"), each.key))
  error_message = format("Fail to validate name of %s ==> %s against regex=%s, min=%d, max=%d", each.value, each.key, replace([for x in local.conf_resource : x if x.name == each.value][0].regex, "/^\\^\\([^\\)]*\\)/", "^"), [for x in local.conf_resource : x if x.name == each.value][0].length.min, [for x in local.conf_resource : x if x.name == each.value][0].length.max)
}