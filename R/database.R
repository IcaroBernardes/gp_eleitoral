library(cepespR)
library(purrr)
library(dplyr)
library(basedosdados)
library(forcats)
library(ggplot2)
library(tidyr)
library(ggstream)
library(ggiraph)
library(scales)
library(ggtext)
library(glue)
library(geobr)
library(ggfx)

## Associa cores aos partidos
cores_part <- tibble(
  numero_cand = c(12,13,15,
                  23,30,40,
                  43,45,50,
                  17,"Outros"),
  partido = c("PDT","PT","MDB",
              "CIDADANIA","NOVO","PSB",
              "PV","PSDB","PSOL",
              "PSL","OUTROS"),
  cor = c("#FE8E6D","#C4122D","#00AA4F",
          "#EC008C","#F3701B","#FFCC00",
          "#006600","#0080FF","#FFEE57",
          "#054577","#7f7f7f"),
  texto = c("black","white","white",
            "white","black","black",
            "white","white","black",
            "white","white")
)
saveRDS(cores_part, "data/cores.RDS")

## Obtém dados de estimativa do tamanho
## da população dos municípios em 2021 (IBGE)
query <- basedosdados::bdplyr("br_ibge_populacao.municipio") %>% 
  dplyr::filter(ano == 2021)
pop <- basedosdados::bd_collect(query)
saveRDS(pop, "data/pop.RDS")

## Obtém resultados de 20 anos de votação para presidente a nível municipal
anos <- seq(1998, 2018, by = 4)
votacao <- purrr::map_df(anos, function(x) {
  cepespR::get_votes(year = x, position = "President") %>% 
    dplyr::select(ano = ANO_ELEICAO, 
                  turno = NUM_TURNO,
                  numero_cand = NUMERO_CANDIDATO,
                  ibge7 = COD_MUN_IBGE,
                  votos = QTDE_VOTOS)
})
saveRDS(votacao, "data/votacao.RDS")

## Obtém nomes dos candidatos de 20 anos de votação para presidente.
## Mantém apenas candidaturas não impugnadas
candidaturas <- purrr::map_df(anos, function(x) {
  cepespR::get_candidates(year = x, position = "President") %>% 
    dplyr::select(ano = ANO_ELEICAO, 
                  numero_cand = NUMERO_CANDIDATO,
                  cand = NOME_URNA_CANDIDATO,
                  status = COD_SITUACAO_CANDIDATURA)
})
candidaturas <- candidaturas %>% 
  dplyr::filter(status %in% c(2,12)) %>% 
  dplyr::select(-status) %>% 
  dplyr::distinct()
saveRDS(candidaturas, "data/candidaturas.RDS")
