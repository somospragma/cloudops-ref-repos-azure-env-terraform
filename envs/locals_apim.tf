locals {
  # ===== APIM (Naming: {project}-{layer}-{env}-apim - solo alfanuméricos y guiones) =====
  apim_name = "${var.project_name}-${var.layer_name}-${var.environment}-APIM"

  apim_kv_secret_name = "${var.environment}-APIM-SP-CREDENTIAL-SECRET"

  # ===== APIM POLICY FRAGMENTS =====
  apim_policy_fragments = {
    "policies-security-apim" = {
      name = "policies-security-apim-${var.environment}"
      file = "policies-security-apim.xml"
    }
    "authentication-certificate-to-ingress" = {
      name = "authentication-certificate-to-ingress-${var.environment}"
      file = "authentication-certificate-to-ingress.xml"
    }
    "policies-security-apim-test-traces" = {
      name = "policies-security-apim-test-traces-${var.environment}"
      file = "policies-security-apim-test-traces.xml"
    }
  }

}