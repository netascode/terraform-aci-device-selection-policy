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

  tenant                     = aci_rest.fvTenant.content.name
  contract                   = "CON1"
  service_graph_template     = "SGT1"
  sgt_device_name            = "DEV1"
  consumer_logical_interface = "INT1"
  provider_logical_interface = "INT2"
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

data "aci_rest" "vnsRsLIfCtxToLIf_consumer" {
  dn = "${data.aci_rest.vnsLDevCtx.id}/lIfCtx-c-consumer/rsLIfCtxToLIf"

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

data "aci_rest" "vnsRsLIfCtxToLIf_provider" {
  dn = "${data.aci_rest.vnsLDevCtx.id}/lIfCtx-c-provider/rsLIfCtxToLIf"

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
