# 0. Carrega bibliotecas e dados
library(dplyr)
library(forcats)
library(glue)
library(quarto)
library(rmarkdown)
library(systemfonts)

## Registra a fonte para que possa ser usada nos gráficos de barras
systemfonts::register_font("Daggersquare","cidades_docs/DAGGERSQUARE.otf")

## Carrega a função com a versão interativa de ggpath::geom_from_path
source("R/girafa/interactive_images.R")

## Carrega os nomes e códigos IBGE dos municípios
ibge <- readRDS("data/ibge.RDS")

## Carrega as cores dos partidos
cores_part <- readRDS("data/cores.RDS")

## Carrega dados de população estimada
pop <- readRDS("data/pop.RDS")

## Carrega dados de votação presidencial por município
votacao <- readRDS("data/votacao.RDS")

## Carrega dados de candidaturas presidenciais
candidaturas <- readRDS("data/candidaturas.RDS")

# 1. Une, filtra e condensa os dados
## Seleciona e renomeia dados
pop <- pop %>%
  dplyr::select(ibge7 = id_municipio, sigla_uf, populacao)

## Mantém apenas as cidades com os códigos IBGE correntes
df <- votacao %>%
  dplyr::mutate(ibge7 = as.character(ibge7)) %>%
  dplyr::inner_join(pop)

## Insere os nomes dos candidatos no banco de dados
df <- df %>% dplyr::left_join(candidaturas)

## Condensa os números e mantém apenas os principais partidos
## que tiveram votação expressiva em ao menos uma eleição
df <- df %>% 
  dplyr::mutate(numero_cand = factor(numero_cand),
                numero_cand = forcats::fct_other(numero_cand,
                                                 keep = c(12,13,15,17,23,
                                                          30,40,43,45,50),
                                                 other_level = "Outros"))

# 2. Produz vários documentos html com os gráficos
## Obtém códigos das cidades de interesse
lista_codigos <- unique(df$ibge7)

## Define função para gera vários html com o gráfico de cada cidade
renderMyDocument <- function(codigo) {
    glue("{match(codigo,lista_codigos)} de {length(lista_codigos)}...")
    rmarkdown::render("gerador.Rmd",
                      params = list(cidade = codigo),

                      output_file = glue("cidades_docs/{codigo}.html")
    )
}

## Aplica a função para gerar vários html
lapply(lista_codigos, renderMyDocument)

# 3. Gera a página principal que conduz às outras
quarto::quarto_render("index.qmd")
