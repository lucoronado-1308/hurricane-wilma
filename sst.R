rm(list = ls())

# Cargar librerías
library(dplyr)
library(ggplot2)
library(lubridate)
library(zoo)

# Leer el archivo CSV y convertir 'NaN' a NA
file_path <- "/Volumes/LLACA/Python/Caribe/sst_data.csv"
data <- read.csv(file_path, stringsAsFactors = FALSE)

# Convertir 'NaN' a NA
data[data == "NaN"] <- NA

# Interpolar los valores faltantes en la columna SST_C
data$SST_C <- na.approx(data$SST_C, na.rm = FALSE)

# Reemplazar los NA restantes por el promedio de SST_C del mes
mean_sst_total <- mean(data$SST_C, na.rm = TRUE)
data$SST_C[is.na(data$SST_C)] <- mean_sst_total

# Verificar datos después de la interpolación
head(data)

# Filtrar los datos para todo el mes de octubre de 2005
october_data <- data %>%
  filter(time >= as.Date("2005-10-01") & time <= as.Date("2005-10-31"))
# Verificar el tamaño del conjunto de datos después del filtro
cat("Número de filas en october_data:", nrow(october_data), "\n")

# Filtrar los días 21 a 23 de octubre
filtered_data <- october_data %>%
  filter(time >= as.Date("2005-10-21") & time <= as.Date("2005-10-23"))
# Verificar el tamaño del conjunto de datos después del filtro
cat("Número de filas en filtered_data:", nrow(filtered_data), "\n")

# Calcular el promedio de SST_C para los días 21-23 de octubre
mean_sst <- mean(filtered_data$SST_C, na.rm = TRUE)

# Calcular la anomalía (SST_C - promedio)
october_data <- october_data %>%
  mutate(anomaly = SST_C - mean_sst)

# Filtrar nuevamente los datos para los días 21 a 23 con anomalías
filtered_data <- october_data %>%
  filter(time >= as.Date("2005-10-21") & time <= as.Date("2005-10-23"))
# Verificar el resultado final de filtered_data
head(filtered_data)

# Graficar la serie temporal completa de SST_C en octubre
ggplot(october_data, aes(x = time, y = SST_C)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(title = "Serie Temporal de la Temperatura Superficial (SST_C) - Octubre 2005",
       x = "Fecha (Día-Mes)", y = "Temperatura (SST_C)") +
  theme_minimal()

# Graficar las anomalías de SST_C del 21 al 23 de octubre
ggplot(filtered_data, aes(x = time, y = anomaly)) +
  geom_line(color = "red") +
  geom_point(color = "red") +
  labs(title = "Anomalía de la Temperatura Superficial (SST_C) - 21 a 23 de Octubre 2005",
       x = "Fecha (Día-Mes)", y = "Anomalía de SST_C") +
  theme_minimal()

######################################################################
######################################################################
######################################################################

# Filtrar los datos para el transecto (Longitude: -87 a -86.46, Latitude: 20.15 a 20.43)
transect_data <- october_data %>%
  filter(longitude >= -87 & longitude <= -86.46 &
           latitude >= 20.15 & latitude <= 20.43)
# Verificar el tamaño del conjunto de datos después del filtro del transecto
cat("Número de filas en transect_data:", nrow(transect_data), "\n")

# Filtrar los datos para los días 21 a 23 de octubre en el transecto
filtered_data_transect <- transect_data %>%
  filter(time >= as.Date("2005-10-21") & time <= as.Date("2005-10-23"))
# Verificar el tamaño del conjunto de datos después del filtro del transecto
cat("Número de filas en filtered_data_transect:", nrow(filtered_data_transect), "\n")

# Calcular el promedio de SST_C para los días 21-23 de octubre en el transecto
mean_sst_transect <- mean(filtered_data_transect$SST_C, na.rm = TRUE)

# Calcular la desviación estándar para los días 21-23 de octubre en el transecto
std_dev <- sd(filtered_data_transect$SST_C, na.rm = TRUE)

# Calcular la anomalía para el transecto
filtered_data_transect <- filtered_data_transect %>%
  mutate(anomaly = SST_C - mean_sst_transect)

# Calcular la incertidumbre (en este caso, la desviación estándar)
uncertainty <- std_dev

# Verificar los resultados
cat("Promedio de SST_C (21-23 octubre):", mean_sst_transect, "\n")
cat("Desviación estándar (21-23 octubre):", std_dev, "\n")
cat("Incertidumbre (21-23 octubre):", uncertainty, "\n")

# Graficar las anomalías de SST_C del 21 al 23 de octubre en el transecto
ggplot(filtered_data_transect, aes(x = time, y = anomaly)) +
  geom_line(color = "red") +
  geom_point(color = "red") +
  labs(title = "Anomalía de la Temperatura Superficial (SST_C) - 21 a 23 de Octubre 2005 en Transecto",
       x = "Fecha (Día-Mes)", y = "Anomalía de SST_C") +
  theme_minimal()

