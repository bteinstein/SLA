library(readr)
library(dplyr)
library(dbplyr)
library(data.table)
library(tidyverse)
library(pool) 

# Cloud 
# https://github.com/r-dbi/RMariaDB
conn <- dbPool(
  RMySQL::MySQL(),
  # RMariaDB::MariaDB(), 
  dbname = "shinydemo",
  host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
  username = "guest",
  password = "guest"
)
rs <- dbGetQuery(conn, "SELECT * FROM City LIMIT 5;")
rs



# Local
SLA_temp_db <- DBI::dbConnect(RSQLite::SQLite(), "db/SLA_temp_DB.sqlite")

src_dbi(SLA_temp_db)


# SQL INJECTION PREVENTION
# sql <- "SELECT * FROM City WHERE ID = ?id ;"
# query <- sqlInterpolate(conn, sql, id = input$ID)