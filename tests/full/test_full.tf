terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "netascode/aci"
      version = ">=0.2.0"
    }
  }
}

resource "aci_rest" "fvTenant" {
  dn         = "uni/tn-TF"
  class_name = "fvTenant"
}

module "main" {
  source = "../.."

  tenant                                                  = aci_rest.fvTenant.content.name
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

data "aci_rest" "vnsLDevCtx" {
  dn = "uni/tn-${aci_rest.fvTenant.content.name}/ldevCtx-c-CON1-g-SGT1-n-N1"

  depends_on = [module.main]
}

resource "test_assertions" "vnsLDevCtx" {
  component = "vnsLDevCtx"

  equal "ctrctNameOrLbl" {
    description = "ctrctNameOrLbl"
    got         = data.aci_rest.vnsLDevCtx.content.ctrctNameOrLbl
    want        = "CON1"
  }

  equal "graphNameOrLbl" {
    description = "graphNameOrLbl"
    got         = data.aci_rest.vnsLDevCtx.content.graphNameOrLbl
    want        = "SGT1"
  }

  equal "nodeNameOrLbl" {
    description = "nodeNameOrLbl"
    got         = data.aci_rest.vnsLDevCtx.content.nodeNameOrLbl
    want        = "N1"
  }
}

data "aci_rest" "vnsRsLDevCtxToLDev" {
  dn = "${data.aci_rest.vnsLDevCtx.id}/rsLDevCtxToLDev"

  depends_on = [module.main]
}

resource "test_assertions" "vnsRsLDevCtxToLDev" {
  component = "vnsRsLDevCtxToLDev"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.vnsRsLDevCtxToLDev.content.tDn
    want        = "uni/tn-${aci_rest.fvTenant.content.name}/lDevVip-DEV1"
  }
}

data "aci_rest" "vnsLIfCtx_consumer" {
  dn = "${data.aci_rest.vnsLDevCtx.id}/lIfCtx-c-consumer"

  depends_on = [module.main]
}

resource "test_assertions" "vnsLIfCtx_consumer" {
  component = "vnsLIfCtx_consumer"

  equal "connNameOrLbl" {
    description = "connNameOrLbl"
    got         = data.aci_rest.vnsLIfCtx_consumer.content.connNameOrLbl
    want        = "consumer"
  }

  equal "l3Dest" {
    description = "l3Dest"
    got         = data.aci_rest.vnsLIfCtx_consumer.content.l3Dest
    want        = "yes"
  }

  equal "permitLog" {
    description = "permitLog"
    got         = data.aci_rest.vnsLIfCtx_consumer.content.permitLog
    want        = "yes"
  }
}

data "aci_rest" "vnsRsLIfCtxToSvcRedirectPol_consumer" {
  dn = "${data.aci_rest.vnsLIfCtx_consumer.id}/rsLIfCtxToSvcRedirectPol"

  depends_on = [module.main]
}

resource "test_assertions" "vnsRsLIfCtxToSvcRedirectPol_consumer" {
  component = "vnsRsLIfCtxToSvcRedirectPol_consumer"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.vnsRsLIfCtxToSvcRedirectPol_consumer.content.tDn
    want        = "uni/tn-${aci_rest.fvTenant.content.name}/svcCont/svcRedirectPol-REDIR1"
  }
}

data "aci_rest" "vnsRsLIfCtxToBD_consumer" {
  dn = "${data.aci_rest.vnsLIfCtx_consumer.id}/rsLIfCtxToBD"

  depends_on = [module.main]
}

resource "test_assertions" "vnsRsLIfCtxToBD_consumer" {
  component = "vnsRsLIfCtxToBD_consumer"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.vnsRsLIfCtxToBD_consumer.content.tDn
    want        = "uni/tn-${aci_rest.fvTenant.content.name}/BD-BD1"
  }
}

data "aci_rest" "vnsRsLIfCtxToLIf_consumer" {
  dn = "${data.aci_rest.vnsLIfCtx_consumer.id}/rsLIfCtxToLIf"

  depends_on = [module.main]
}

resource "test_assertions" "vnsRsLIfCtxToLIf_consumer" {
  component = "vnsRsLIfCtxToLIf_consumer"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.vnsRsLIfCtxToLIf_consumer.content.tDn
    want        = "uni/tn-${aci_rest.fvTenant.content.name}/lDevVip-DEV1/lIf-INT1"
  }
}

data "aci_rest" "vnsLIfCtx_provider" {
  dn = "${data.aci_rest.vnsLDevCtx.id}/lIfCtx-c-provider"

  depends_on = [module.main]
}

resource "test_assertions" "vnsLIfCtx_provider" {
  component = "vnsLIfCtx_provider"

  equal "connNameOrLbl" {
    description = "connNameOrLbl"
    got         = data.aci_rest.vnsLIfCtx_provider.content.connNameOrLbl
    want        = "provider"
  }

  equal "l3Dest" {
    description = "l3Dest"
    got         = data.aci_rest.vnsLIfCtx_provider.content.l3Dest
    want        = "yes"
  }

  equal "permitLog" {
    description = "permitLog"
    got         = data.aci_rest.vnsLIfCtx_provider.content.permitLog
    want        = "yes"
  }
}

data "aci_rest" "vnsRsLIfCtxToInstP_provider" {
  dn = "${data.aci_rest.vnsLIfCtx_provider.id}/rsLIfCtxToInstP"

  depends_on = [module.main]
}

resource "test_assertions" "vnsRsLIfCtxToInstP_provider" {
  component = "vnsRsLIfCtxToInstP_provider"

  equal "redistribute" {
    description = "redistribute"
    got         = data.aci_rest.vnsRsLIfCtxToInstP_provider.content.redistribute
    want        = "bgp,connected,ospf,static"
  }

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.vnsRsLIfCtxToInstP_provider.content.tDn
    want        = "uni/tn-${aci_rest.fvTenant.content.name}/out-L3OUT1/instP-EXTEPG1"
  }
}

data "aci_rest" "vnsRsLIfCtxToLIf_provider" {
  dn = "${data.aci_rest.vnsLIfCtx_provider.id}/rsLIfCtxToLIf"

  depends_on = [module.main]
}

resource "test_assertions" "vnsRsLIfCtxToLIf_provider" {
  component = "vnsRsLIfCtxToLIf_provider"

  equal "tDn" {
    description = "tDn"
    got         = data.aci_rest.vnsRsLIfCtxToLIf_provider.content.tDn
    want        = "uni/tn-${aci_rest.fvTenant.content.name}/lDevVip-DEV1/lIf-INT2"
  }
}
