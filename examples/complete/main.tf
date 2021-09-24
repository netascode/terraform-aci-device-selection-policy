module "aci_device_selection_policy" {
  source  = "netascode/device-selection-policy/aci"
  version = ">= 0.0.1"

  tenant                                                  = "ABC"
  contract                                                = "CON1"
  service_graph_template                                  = "SGT1"
  sgt_device_name                                         = "DEV1"
  consumer_l3_destination                                 = true
  consumer_permit_logging                                 = true
  consumer_logical_interface                              = "INT1"
  consumer_redirect_policy                                = "REDIR1"
  consumer_bridge_domain                                  = "BD1"
  provider_l3_destination                                 = true
  provider_permit_logging                                 = true
  provider_logical_interface                              = "INT2"
  provider_external_endpoint_group                        = "EXTEPG1"
  provider_external_endpoint_group_l3out                  = "L3OUT1"
  provider_external_endpoint_group_redistribute_bgp       = true
  provider_external_endpoint_group_redistribute_ospf      = true
  provider_external_endpoint_group_redistribute_connected = true
  provider_external_endpoint_group_redistribute_static    = true
}
