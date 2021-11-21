#Analisis de Sentimientos Cuentos Hermanos Grimm

library(tidyverse)
library(tidytext)

library(rvest)
library(readr)

sentimientos <- read_tsv("https://raw.githubusercontent.com/7PartidasDigital/AnaText/master/datos/diccionarios/sentimientos_2.txt",
                         col_types = "cccn",
                         locale = default_locale())

#Función getsentiments

source("https://raw.githubusercontent.com/7PartidasDigital/R-LINHD-18/master/get_sentiments.R")

#Cargar Cuentos

Blancanieve_y_rojarosa <- readLines("datos/cuentos/Blancanieve_y_rojarosa.txt", encoding = "UTF-8")
El_hombre_de_la_piel_de_oso <- readLines("datos/cuentos/El_hombre_de_la_piel_de_oso.txt", encoding = "UTF-8")
El_joven_gigante <- readLines("datos/cuentos/El_joven_gigante.txt", encoding = "UTF-8")
El_judio_en_las_espinas <- readLines("datos/cuentos/El_judio_en_las_espinas.txt", encoding = "UTF-8")
La_madre_vieja <- readLines("datos/cuentos/La_madre_vieja.txt", encoding = "UTF-8")
Juan_el_fiel <- readLines("datos/cuentos/Juan_el_fiel.txt", encoding = "UTF-8")
Juan_en_la_prosperidad <- readLines("datos/cuentos/Juan_en_la_prosperidad.txt", encoding = "UTF-8")
La_carga_ligera <- readLines("datos/cuentos/La_carga_ligera.txt", encoding = "UTF-8")
La_reina_de_las_abejas <- readLines("datos/cuentos/La_reina_de_las_abejas.txt", encoding = "UTF-8")
Las_tres_hilanderas <- readLines("datos/cuentos/Las_tres_hilanderas.txt", encoding = "UTF-8")
Los_doce_cazadores <- readLines("datos/cuentos/Los_doce_cazadores.txt", encoding = "UTF-8")
Los_musicos_de_Brema <- readLines("datos/cuentos/Los_musicos_de_Brema.txt", encoding = "UTF-8")
Los_tres_herederos_afortunados <- readLines("datos/cuentos/Los_tres_herederos_afortunados.txt", encoding = "UTF-8")
Rosa_con_espinas <- readLines("datos/cuentos/Rosa_con_espinas.txt", encoding = "UTF-8")
Ruiponche <- readLines("datos/cuentos/Ruiponche.txt", encoding = "UTF-8")

#Títulos


titulos <- c("Blancanieve y rojarosa",
             "El hombre de la piel de oso",
             "El joven gigante",
             "El Judio en las espinas",
             "La madre vieja",
             "Juan el fiel",
             "Juan en la prosperidad",
             "La carga ligera",
             "La reina de las abejas",
             "Las tres hilanderas",
             "Los doce cazadores",
             "Los musicos de Brema",
             "Los tres herederos afortunados",
             "Rosa con Espinas",
             "Ruiponche")



#Crear Lista
libros <- list(Blancanieve_y_rojarosa,
               El_hombre_de_la_piel_de_oso,
               El_joven_gigante,
               El_judio_en_las_espinas,
               Juan_el_fiel,
               Juan_en_la_prosperidad,
               La_carga_ligera,
               La_madre_vieja,
               La_reina_de_las_abejas,
               Las_tres_hilanderas,
               Los_doce_cazadores,
               Los_musicos_de_Brema,
               Los_tres_herederos_afortunados,
               Rosa_con_espinas,
               Ruiponche)


#Crear Gran tabla
install.packages("dplyr")
library(dplyr)

serie <- NULL

for(i in seq_along(titulos)) {
  limpio <- tibble(capitulo = seq_along(libros[[i]]),
                   texto = libros[[i]]) %>%
    unnest_tokens(palabra, texto) %>%
    mutate(libro = titulos[i]) %>%
    select(libro, everything())
  serie <- bind_rows(serie, limpio)
}


#convertir en factores

serie$libro <- factor(serie$libro, levels = rev(titulos))

#cuántas palabras positivas y cuántas negativas hay y sus sentimientos 
serie %>%
  right_join(get_sentiments("nrc")) %>%
  filter(!is.na(sentimiento)) %>%
  count(sentimiento, sort = TRUE)

#solo palabras positivas y negativas (menos resultados por el diccionario bing)
serie %>%
  right_join(get_sentiments("bing")) %>%
  filter(!is.na(sentimiento)) %>%
  count(sentimiento, sort = TRUE)

#Visualización de los resultados

serie %>%
  group_by(libro) %>%
  mutate(recuento_palabras = 1:n(),
         indice = recuento_palabras %/% 500 + 1) %>%
  inner_join(get_sentiments("nrc")) %>%
  count(libro, indice = indice , sentimiento) %>%
  ungroup() %>%
  spread(sentimiento, n, fill = 0) %>%
  mutate(sentimiento = positivo - negativo, libro = factor(libro, levels = titulos)) %>%
  ggplot(aes(indice, sentimiento, fill = libro)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  facet_wrap(~ libro, ncol = 2, scales = "free_x")


recuenta_palabras_bing <- serie %>%
  inner_join(get_sentiments("bing")) %>%
  count(palabra, sentimiento, sort = TRUE)

recuenta_palabras_bing %>%
  group_by(sentimiento) %>%
  top_n(25) %>%
  ggplot(aes(reorder(palabra, n), n, fill = sentimiento)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  facet_wrap(~sentimiento, scales = "free_y") +
  labs(y = "Contribución al sentimiento", x = NULL) +
  coord_flip()



#Package syuzhet


install.packages("syuzhet")
library(tidyverse)
library(tidytext)
library(syuzhet)


#Diccionario
sentimientos <- read_tsv("https://raw.githubusercontent.com/7PartidasDigital/AnaText/master/datos/diccionarios/sentimientos_2.txt",
                         col_types = "cccn",
                         locale = default_locale())
source("https://raw.githubusercontent.com/7PartidasDigital/R-LINHD-18/master/get_sentiments.R")

#Aqui poner los cuentos individuales
texto_entrada <-cuentos
texto_analizar <- tibble(texto = texto_entrada)

#Dividir en palabras token



texto_analizar <- texto_analizar %>%
  unnest_tokens(palabra, texto) %>%
  mutate(pagina = (1:n()) %/% 400 + 1) %>%
  inner_join(get_sentiments("nrc")) %>%
  count(sentimiento, pagina = pagina) %>%
  spread(sentimiento, n, fill = 0) %>%
  mutate(negativo = negativo*-1)

puntuacion <- texto_analizar %>%
  mutate(sentimiento = positivo+negativo) %>%
  select(pagina, sentimiento)

#Grafica

ggplot(data = puntuacion, aes(x = pagina, y = sentimiento)) +
  geom_bar(stat = "identity", color = "midnightblue") +
  theme_minimal() +
  ylab("Sentimiento") +
  xlab("Tiempo narrativo") +
  ggtitle(expression(paste("Sentimiento en ",
                           italic("Cuentos de los hermanos Grimm")))) +
  theme(legend.justification=c(0.91,0), legend.position=c(1, 0))


texto_trans <- get_dct_transform(puntuacion$sentimiento,
                                 low_pass_size = 10,
                                 #x_reverse_len = nrow(puntuacion),
                                 scale_range = TRUE)

texto_trans <- tibble(pagina = seq_along(texto_trans),
                      ft = texto_trans)

ggplot(texto_trans, aes(x = pagina, y = ft)) +
  geom_bar(stat = "identity", alpha = 0.8,
           color = "aquamarine3", fill = "aquamarine3") +
  theme_minimal() +
  labs(x = "Tiempo narrativo",
       y = "Transformación Valorada del Sentimiento") +
  ggtitle(expression(paste("Forma de la historia de ",
                           italic("Cuentos de los Hermanos Grimm"))))

plot(texto_trans,
     type = "l",
     yaxt = 'n',
     ylab = "",
     xlab = "Tiempo narrativo",
     main = "La forma de la historia:\nCuentos de los Hermanos Grimm")
abline(h = 0.0, col = "red")

