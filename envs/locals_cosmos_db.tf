locals {

  # ===== COSMOS DB (Naming: {project}-{layer}-{env}-cosmos) - max 50 caracteres =====
  cosmosdb_account_name       = substr(lower("${var.project_name}-${var.layer_name}-${var.environment}-COSMOS-ACC"), 0, 50)
  cosmosdb_db_onecash_finance = substr(lower("CDB-${var.layer_name}-ONECASH-FINANCEPORTAL"), 0, 50)

  cosmos_databases = {

    (local.cosmosdb_db_onecash_finance) = {
      max_throughput = "1000"
    }

  }

}