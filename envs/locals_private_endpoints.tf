locals {

  # ===== PRIVATE ENDPOINTS (Naming: pe-{resource}-{env}) =====
  pe_cosmosdb_name = "PE-COSMOSDB-${var.environment}"
  pe_keyvault_name = "PE-KEYVAULT-${var.environment}"
  pe_sql_name      = "PE-SQL-${var.environment}"


}