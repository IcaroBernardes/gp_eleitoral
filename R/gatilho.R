# 0. Carrega bibliotecas
library(rmarkdown)
library(glue)
library(dplyr)
library(forcats)

## Carrega as cores dos partidos
cores_part <- readRDS("data/cores.RDS")

## Carrega dados de população estimada
pop <- readRDS("data/pop.RDS")

## Obtém as top3 cidades de cada estado
pop <- pop %>% 
  dplyr::group_by(sigla_uf) %>% 
  dplyr::slice_max(order_by = populacao, n = 3) %>% 
  dplyr::ungroup() %>% 
  dplyr::select(ibge7 = id_municipio, sigla_uf, populacao)

## Define os anos de eleição a analisar
anos <- seq(1998, 2018, by = 4)

## Carrega dados de votação presidencial por município
votacao <- readRDS("data/votacao.RDS")

## Mantém apenas as cidades filtradas
df <- votacao %>% 
  dplyr::mutate(ibge7 = as.character(ibge7)) %>% 
  dplyr::inner_join(pop)

## Condensa os números e mantém apenas os principais partidos
## que tiveram votação expressiva em ao menos uma eleição
df <- df %>% 
  dplyr::mutate(numero_cand = factor(numero_cand),
                numero_cand = forcats::fct_other(numero_cand,
                                                 keep = c(12,13,15,17,23,
                                                          30,40,43,45,50),
                                                 other_level = "Outros"))

## Obtém códigos das cidades de interesse
lista_codigos <- unique(df$ibge7)

## Define função para gera vários html com o gráfico de cada cidade
renderMyDocument <- function(codigo) {
    rmarkdown::render("gerador.Rmd",
                      params = list(cidade = codigo, dados = df),

                      output_file = glue("cidades_docs/{codigo}.html")
    )
}

## Aplica a função para gerar vários html
lapply(lista_codigos, renderMyDocument)
