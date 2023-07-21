library(tidyverse)
library(data.table)
library(readxl)
library(MASS) # statistical functions
library(clifro) # windrose plot
library(scales) # percentages

# read met mast data ----
met <- 
  read_xlsx(here::here('data-raw', 'br_canudos_i.xlsx'),
            sheet = 'br_canudos_i', 
            skip = 1 ) |>
  mutate(ano = year(TS),
         mes = month(TS),
         dia = day(TS))
write_csv(filter(met, ano == 2018, mes == 1, dia == 1)[, 1:10], './data-raw/metmast.csv')

metmast <- read_csv('./data-raw/metmast.csv') |>
  mutate(ano = year(TS),
         mes = month(TS),
         dia = day(TS))

# read gps data ----
gps <- 
  vroom::vroom(here::here('data-raw', 'aleari_20220727.csv')) |>
  janitor::clean_names() |>
  mutate(ano = year(timestamp),
         mes = month(timestamp),
         dia = day(timestamp))

write_csv(filter(gps, ano == 2018, mes == 1, dia == 1) %>% 
            dplyr::select('timestamp', 'heading', 'ground_speed'), 
          './data-raw/gps20180101.csv')

gps <- read_csv('./data-raw/gps20180101.csv') |>
  mutate(ano = year(timestamp),
         mes = month(timestamp),
         dia = day(timestamp))

# Wind profile ----
with(metmast, 
     windrose(speed = WSP_MEAN_1,
              direction = DIR_MEAN_1,
              facet = factor(ano),
              n_directions = 12,
              n_col = 3,
              speed_cuts = seq(0, 20, 4),
              ggtheme='minimal',
              col_pal = 'YlGnBu'))

# convert to datatable ----
metmastdt <- setDT(metmast) |> 
  dplyr::select(date = TS, winddir = DIR_MEAN_1, windspeed = WSP_MEAN_1)
metmastdt[, dateorig := date]

gpsdt <- setDT(gps) |>
  dplyr::select(date = timestamp, fligthdir = heading, fligthspeed = ground_speed)

# Join with roll ----
metmastdt[gpsdt, on = .(date), roll = TRUE]
