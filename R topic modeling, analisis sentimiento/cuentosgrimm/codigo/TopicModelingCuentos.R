install.packages("tm")
install.packages("topicmodels")
install.packages("scales")

library(tidyverse)
library(tidytext)
library(tm)
library(topicmodels)
library(scales)

#Cargar palabras vacías

vacias <- read_tsv("https://tinyurl.com//7PartidasVacias",
                   locale = default_locale())


titulos <- c("Blancanieve y Rojarosa",
             "El Hombre de la piel de oso",
             "El joven gigante",
             "El judio en las espinas",
             "La madre vieja",
             "Juan el fiel",
             "Juan en la prosperidad")

ficheros <- c("Blancanieve_y_rojarosa.txt",
              "El_hombre_de_la_piel_de_oso.txt",
              "El_joven_gigante.txt",
              "El_judio_en_las_espinas.txt",
              "la_madre_vieja.txt",
              "Juan_el_fiel.txt",
              "Juan_en_la_prosperidad.txt")

ruta <- "datos/cuentos/"

cuentos <- tibble(texto = character(),
                  titulo = character(),
                  pagina = numeric())
                  






for (j in 1:length(ficheros)){
  texto.entrada <- read_lines(paste(ruta,
                                    ficheros[j],
                                    sep = ""), 
                              locale = default_locale())
  texto.todo <- paste(texto.entrada, collapse = " ")
  por.palabras <- strsplit(texto.todo, " ")
  texto.palabras <- por.palabras[[1]]
  trozos <- split(texto.palabras,
                  ceiling(seq_along(texto.palabras)/2299))
  for (i in 1:length(trozos)){
    fragmento <- trozos[i]
    fragmento.unido <- tibble(texto = paste(unlist(fragmento),
                                            collapse = " "),
                              titulo = titulos[j],
                              pagina = i)
    cuentos <- bind_rows(cuentos, fragmento.unido)
  }
}


rm(ficheros, titulos, trozos, fragmento,
   fragmento.unido, ruta, texto.entrada,
   texto.palabras, texto.todo, por.palabras, i, j)

por_pagina_palabras <- cuentos %>%
  unite(titulo_pagina, titulo, pagina) %>%
  unnest_tokens(palabra, texto)


por_pagina_palabras %>%
  count(palabra, sort = T)

palabra_conteo <- por_pagina_palabras %>%
  anti_join(vacias) %>% 
  count(titulo_pagina, palabra, sort = TRUE) %>%
  ungroup()

paginas_dtm <- palabra_conteo %>%
  cast_dtm(titulo_pagina, palabra, n)

#modelo LDA

paginas_lda <- LDA(paginas_dtm, k = 7, control = list(seed = 1234))

paginas_lda_td <- tidy(paginas_lda, matrix = "beta")

terminos_frecuentes <- paginas_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

terminos_frecuentes %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

#Clasificacion por documento
paginas_lda_gamma <- tidy(paginas_lda, matrix = "gamma")

paginas_lda_gamma <- paginas_lda_gamma %>%
  separate(document,
           c("titulo", "pagina"),
           sep = "_", convert = TRUE)

ggplot(paginas_lda_gamma, aes(gamma, fill = factor(topic))) +
  geom_histogram() +
  facet_wrap(~ titulo, nrow = 2)

paginas_clasificaciones <- paginas_lda_gamma %>%
  group_by(titulo, pagina) %>%
  top_n(1, gamma) %>%
  ungroup() %>%
  arrange(gamma)

topico_cuento <- paginas_clasificaciones %>%
  count(titulo, topic) %>%
  group_by(titulo) %>%
  top_n(1, n) %>%
  ungroup() %>%
  transmute(consenso = titulo, topic)

#paginas erroneamente asignadas

paginas_clasificaciones %>%
  inner_join(topico_cuento, by = "topic") %>%
  filter(titulo != consenso)

#Asignaciones por palabras

asignaciones <- augment(paginas_lda, data = paginas_dtm)

asignaciones <- asignaciones %>%
  separate(document, c("titulo",
                       "pagina"),
           convert = TRUE) %>%
  inner_join(topico_cuento,
             by = c(".topic" = "topic"))

asignaciones %>%
  count(titulo, consenso, wt = count) %>%
  group_by(titulo) %>%
  mutate(porcentaje = n / sum(n)) %>%
  ggplot(aes(consenso, titulo, fill = porcentaje)) +
  geom_tile() +
  scale_fill_gradient2(high = "blue", label = percent_format()) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        panel.grid = element_blank()) +
  labs(x = "Asignó las palabras a…",
       y = "Las palabras procedían de…",
       fill = "% de asignaciones")

palabras_equivocadas <- asignaciones %>%
  filter(titulo != consenso)

palabras_equivocadas %>%
  count(titulo, consenso, term, wt = count) %>%
  ungroup() %>%
  arrange(desc(n))

