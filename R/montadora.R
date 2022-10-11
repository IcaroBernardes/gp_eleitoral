# 0. Carrega bibliotecas
library(dplyr)
library(purrr)
library(glue)
library(magick)
library(colorspace)

# 1. Carrega e processa dados
## Carrega as cores dos partidos
cores_part <- readRDS("data/cores.RDS")

## Define cores dos detalhes e aerofólio de cada carro
cores_part <- cores_part %>% 
  dplyr::mutate(
    detalhes = colorspace::darken(cor, amount = 0.4, method = "relative"),
    aerofolio = colorspace::lighten(cor, amount = 0.4, method = "relative")
  )

# 2. Modifica e salva as imagens
## Carrega imagem do carro e diminui o tamanho
car <- magick::image_read("images/car.png") %>% 
  magick::image_scale("513x")

## Define alguns parâmetros do processo de colorir
ref_detalhes <- "#80372F"
fuzz_detalhes <- 15
ref_aerofolio <- "#FB8376"
fuzz_aerofolio <- 15
ref_cor <- "#E64C3C"
fuzz_cor <- 5

## Define função para colorir os carros e salvar imagens
colorir <- function(partido, cor, detalhes, aerofolio) {
  
  ### Altera a cor dos detalhes do carro
  car_temp <- car %>%
    magick::image_fill(color = detalhes, refcolor = ref_detalhes,
                       point = '+150+79', fuzz = fuzz_detalhes) %>% 
    magick::image_fill(color = detalhes, refcolor = ref_detalhes,
                       point = '+150+159', fuzz = fuzz_detalhes) %>% 
    magick::image_fill(color = detalhes, refcolor = ref_detalhes,
                       point = '+150+239', fuzz = fuzz_detalhes) %>% 
    magick::image_fill(color = detalhes, refcolor = ref_detalhes,
                       point = '+500+79', fuzz = fuzz_detalhes) %>% 
    magick::image_fill(color = detalhes, refcolor = ref_detalhes,
                       point = '+500+239', fuzz = fuzz_detalhes)
  
  ### Altera a cor do aerofólio do carro
  car_temp <- car_temp %>% 
    magick::image_fill(color = aerofolio, refcolor = ref_aerofolio,
                       point = '+10+159', fuzz = fuzz_aerofolio)
  
  ### Altera a cor do corpo do carro
  car_temp <- car_temp %>% 
    magick::image_fill(color = cor, refcolor = ref_cor,
                       point = '+100+159', fuzz = fuzz_cor) 
  
  ### Reduz ruídos devido a pixelização
  car_temp <- car_temp %>% magick::image_median(radius = 5)
  
  ### Salva a imagem gerada
  image_write(car_temp, glue("images/car_{partido}.png"))
  
}

## Aplica a função ao banco de dados
cores_part %>% 
  dplyr::select(-numero_cand) %>% 
  purrr::pwalk(colorir)
