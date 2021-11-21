quincecuentos <- list.files(path = "datos/cuentos",
                       pattern = "*.txt")

cuento <- gsub("\\.txt",
             "",
             quincecuentos,
             perl = TRUE)

library(tidytext)
library(tidyverse)
tablacuentos <- NULL
for (i in 1:length(quincecuentos)){
  historias <- readLines(paste("datos/cuentos",
                              quincecuentos[i],
                              sep = "/"), encoding = "UTF-8")
  temporal <- tibble(cuento = cuento[i],
                     parrafo = seq_along(historias),
                     texto = historias)
  tablacuentos <- bind_rows(tablacuentos, temporal)
}

cuentos_palabras <- tablacuentos %>%
  unnest_tokens(palabra, texto)

cuentos_palabras %>%
  count(palabra, sort = T) %>%
  mutate(relativa = n / sum(n))

frecuencias_cuento <- cuentos_palabras %>%
  group_by(cuento) %>%
  count(palabra, sort =T) %>%
  mutate(relativa = n / sum(n)) %>%
  ungroup()

cuentos_palabras %>%
  group_by(cuento) %>%
  count() %>%
  ggplot() +
  geom_bar(aes(cuento,
               n),
           stat = 'identity')

cuentos_palabras %>%
  group_by(cuento) %>%
  count() %>%
  ggplot() +
  geom_bar(aes(cuento, n),
           stat = 'identity',
           fill = "orange") +
  theme(legend.position = 'none',
        axis.text.x = element_text(angle = 45,
                                   hjust = 1)) +
  labs(x = "Cuento",
       y = "Número de palabras") +
  ggtitle("Cuentos de los hermanos Grimm",
          subtitle = "Número de palabras por cuento")

rm(temporal,historias,i)
vacias <- get_stopwords("es")

vacias <- vacias %>%
  rename(palabra = word)

vaciado_cuentos <- cuentos_palabras %>%
  anti_join(vacias)

vacias <- read_csv("https://tinyurl.com/7PartidasVacias",
                   locale = default_locale())

vaciado_cuentos <- cuentos_palabras %>%
  anti_join(vacias)

vaciado_cuentos %>%
  count(palabra, sort = T)

vaciado_cuentos %>%
  count(palabra, sort = T) %>%
  filter(n > 65) %>%
  mutate(palabra = reorder(palabra, n)) %>%
  ggplot(aes(x = palabra, y = n, fill = palabra)) +
  geom_bar(stat="identity") +
  theme_minimal() +
  theme(legend.position = "none") +
  ylab("Número de veces que aparecen") +
  xlab(NULL) +
  ggtitle("Cuentos de los hermanos Grimm") +
  coord_flip()
