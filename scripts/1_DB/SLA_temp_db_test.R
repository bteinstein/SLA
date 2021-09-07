conn_SLA_temp_db <- DBI::dbConnect(RSQLite::SQLite(), "db/SLA_temp_DB.sqlite")
dbListTables(conn_SLA_temp_db)
# dbRemoveTable(con_SLA_temp_db, "TBL_ATTEMPT_TABLE")
dbGetQuery(conn_SLA_temp_db, "SELECT COUNT(*) FROM TBL_ATTEMPTS")
dbDisconnect(conn_SLA_temp_db)


create_SLA_temp_DBConnection <- function(){
  # if (db_name == "SLA_temp_DB") {
   DBI::dbConnect(RSQLite::SQLite(), "db/SLA_temp_DB.sqlite")
  # }
}


create_SLA_temp_DBConnection()