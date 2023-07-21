library(data.table)
library(tidyverse)
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
         mes = month(TS))

met22 <- filter(met, ano < 2023)

# read gps data ----
gps <- 
  vroom::vroom(here::here('data-raw', 'aleari_20220727.csv')) |>
  janitor::clean_names() |>
  mutate(ano = year(timestamp),
         mes = month(timestamp))

gps |>
  count(ano, mes) |> print(n=50)

# Wind profile ----
with(met, 
     windrose(speed = WSP_MEAN_1,
              direction = DIR_MEAN_1,
              facet = factor(ano),
              n_directions = 12,
              n_col = 3,
              speed_cuts = seq(0, 20, 4),
              ggtheme='minimal',
              col_pal = 'YlGnBu'))

# Join with roll ----
met18 <-
  setDT(dplyr::filter(met, ano == 2018, mes == 1) |> 
          dplyr::select(date = TS, winddir = DIR_MEAN_1, windspeed = WSP_MEAN_1))
met18[, dateorig := date]

gps18 <-
  setDT(filter(gps, ano == 2018, mes == 1) |>
          dplyr::select(date = timestamp, fligthdir = heading, fligthspeed = ground_speed))

met18[gps18, on = .(date), roll = TRUE]
