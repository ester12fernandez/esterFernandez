getwd()
cosa1 <- readLines("datos/cuentos/Blancanieve_y_Rojarosa.txt", encoding = "UTF-8")
library(tidytext)
library(tidyverse)
grimmcuentos <- tibble(parrafo = seq_along(cuentos),
                       texto = cuentos)

grimmcuentos_palabras <- grimmcuentos %>%
  unnest_tokens(palabra, texto)         

grimmcuentos %>%
  unnest_tokens(oraciones,
                texto,
                token = "sentences")

grimmcuentos_enunciados <- grimmcuentos %>%
  unnest_tokens(oracion,
                texto,
                token = "sentences") %>%
  mutate(NumPal = str_count(oracion,
                            pattern = "\\w+"))

grimmcuentos_palabras %>%
  count(palabra,
        sort = TRUE)

grimmcuentos_palabras <- grimmcuentos_palabras %>%
  mutate(NumLetras = nchar(palabra))

grimmcuentos_frecuencias <- grimmcuentos_palabras %>%
  count(palabra, sort = T) %>%
  mutate(relativa = n / sum(n)) 

View(grimmcuentos_enunciados)

ggplot(grimmcuentos_enunciados,
       aes(1:nrow(grimmcuentos_enunciados),
           NumPal)) +
  geom_bar(stat = 'identity')

ggplot(grimmcuentos_enunciados,
       aes(1:nrow(grimmcuentos_enunciados),
           NumPal)) +
  geom_line () + 
  labs(x = "Número de oración") +
  ggtitle("Número de palabras por oración",
          subtitle = "Seleccion de cuentos de los hermanos Grimm")

summary(grimmcuentos_enunciados$NumPal)

ggplot(grimmcuentos_enunciados,
       aes(1:nrow(grimmcuentos_enunciados),
           NumPal)) +
  geom_bar(stat = 'identity') +
  geom_hline(yintercept = mean(grimmcuentos_enunciados$NumPal),
             linetype = "dotted",
             colour = "blue",
             size = 0.9) +
  geom_hline(yintercept = median(grimmcuentos_enunciados$NumPal),
             linetype = "dashed",
             colour = "red",
             size = 0.9) +
  labs(x = "Número de oración") +
  ggtitle("Número de palabras por oración",
          subtitle = "Seleccion de cuentos de los hermanos Grimm")
