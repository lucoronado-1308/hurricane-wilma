# Limpiar el entorno
rm(list=ls())

# Cargar librerías
library(dplyr)
library(ggplot2)
library(lubridate)
library(zoo)

# Leer el archivo CSV y convertir 'nan' a NA
file_path <- "/Volumes/LLACA/Python/Caribe/chl_2006.csv"
data <- read.csv(file_path, stringsAsFactors = FALSE)
data[data == "nan"] <- NA

# Verificar los primeros registros del archivo CSV
head(data)

# Convertir la columna Time al formato correcto (yyyy-mm-dd)
data$Time <- as.Date(data$Time, format = "%Y-%m-%d")

# Verificar la conversión de fechas
head(data$Time)

# Interpolar los valores faltantes en la columna Chl
data$Chl <- na.approx(data$Chl, na.rm = FALSE)

# Reemplazar los NA restantes por el promedio de Chl
mean_chl_total <- mean(data$Chl, na.rm = TRUE)
data$Chl[is.na(data$Chl)] <- mean_chl_total

# Verificar los datos después de la interpolación
head(data)

# Filtrar los datos para octubre de 2005
october_data <- data %>%
  filter(Time >= as.Date("2006-10-01") & Time <= as.Date("2006-10-31"))

# Filtrar los datos para el transecto (Longitud: -87 a -86.46, Latitud: 20.15 a 20.43)
transect_data <- october_data %>%
  filter(Longitude >= -87 & Longitude <= -86.46 &
           Latitude >= 20.15 & Latitude <= 20.43)

# Filtrar los datos para los días 21 a 23 de octubre en el transecto
filtered_data_transect <- transect_data %>%
  filter(Time >= as.Date("2006-10-21") & Time <= as.Date("2006-10-23"))

# Calcular el promedio de Chl para el periodo específico
mean_chl <- mean(filtered_data_transect$Chl, na.rm = TRUE)

# Calcular la desviación estándar para el periodo específico
std_dev <- sd(filtered_data_transect$Chl, na.rm = TRUE)

# Calcular la anomalía
filtered_data_transect <- filtered_data_transect %>%
  mutate(anomaly = Chl - mean_chl)

# Calcular la incertidumbre (en este caso, la desviación estándar)
uncertainty <- std_dev

# Verificar los resultados
cat("Promedio de Chl (21-23 octubre):", mean_chl, "\n")
cat("Desviación estándar (21-23 octubre):", std_dev, "\n")
cat("Incertidumbre (21-23 octubre):", uncertainty, "\n")

# Graficar las anomalías de Chl del 21 al 23 de octubre
ggplot(filtered_data_transect, aes(x = Time, y = anomaly)) +
  geom_line(color = "red") +
  geom_point(color = "red") +
  labs(title = "Anomalía de la Clorofila (Chl) - 21 a 23 de Octubre 2005",
       x = "Fecha (Día-Mes)", y = "Anomalía de Chl") +
  theme_minimal()

######################################################################

# Filtrar los datos para el transecto (Longitud: -87 a -86.46, Latitud: 20.15 a 20.43)
transect_data <- october_data %>%
  filter(Longitude >= -87 & Longitude <= -86.46 &
           Latitude >= 20.15 & Latitude <= 20.43)

# Filtrar los datos para los días 21 a 23 de octubre en el transecto
filtered_data_transect <- transect_data %>%
  filter(Time >= as.Date("2006-10-21") & Time <= as.Date("2006-10-23"))

# Calcular la anomalía para los días 21 a 23 de octubre en el transecto
# Calcular el promedio de Chl para el periodo específico
mean_chl_transect <- mean(filtered_data_transect$Chl, na.rm = TRUE)

# Calcular la desviación estándar para el periodo específico
std_dev_transect <- sd(filtered_data_transect$Chl, na.rm = TRUE)

# Calcular la anomalía
filtered_data_transect <- filtered_data_transect %>%
  mutate(anomaly = Chl - mean_chl_transect)

# Calcular la incertidumbre (en este caso, la desviación estándar)
uncertainty_transect <- std_dev_transect

# Verificar los resultados
cat("Promedio de Chl (21-23 octubre, transecto):", mean_chl_transect, "\n")
cat("Desviación estándar (21-23 octubre, transecto):", std_dev_transect, "\n")
cat("Incertidumbre (21-23 octubre, transecto):", uncertainty_transect, "\n")

# Graficar las anomalías de Chl del 21 al 23 de octubre en el transecto
ggplot(filtered_data_transect, aes(x = Time, y = anomaly)) +
  geom_line(color = "red") +
  geom_point(color = "red") +
  labs(title = "Anomalía de Clorofila (Chl) en el Transecto - 21 a 23 de Octubre 2005",
       x = "Fecha (Día-Mes)", y = "Anomalía de Chl") +
  theme_minimal()