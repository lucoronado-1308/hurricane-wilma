
rm(list= ls())

# Cargar librerías
library(dplyr)
library(ggplot2)
library(lubridate)
library(zoo)

# Leer el archivo CSV y convertir 'nan' a NA
file_path <- "/Volumes/LLACA/Python/Caribe/sos_caribe.csv"
# Leer el archivo CSV sin convertir 'nan' a NA
data <- read.csv(file_path, stringsAsFactors = FALSE)
#data[data == "NaN"] <- NA

# Verificar los primeros valores de la columna Time
head(data$Time)
# Convertir la columna Time al formato correcto
data$Time <- as.Date(data$Time, format = "%Y-%m-%d")
# Verificar la conversión de fechas
head(data$Time)

# Interpolar los valores faltantes en la columna Sos
data$Sos <- na.approx(data$Sos, na.rm = FALSE)
# Reemplazar los NA restantes por el promedio de Sos
mean_sos_total <- mean(data$Sos, na.rm = TRUE)
data$Sos[is.na(data$Sos)] <- mean_sos_total
# Verificar los datos después de la interpolación
head(data)

# Filtrar los datos para octubre de 2005
october_data <- data %>%
  filter(Time >= as.Date("2005-10-01") & Time <= as.Date("2005-10-31"))
# Filtrar los días 21 a 23 de octubre
filtered_data <- october_data %>%
  filter(Time >= as.Date("2005-10-21") & Time <= as.Date("2005-10-23"))
# Calcular el promedio de Sos para los días 21-23 de octubre
mean_sos <- mean(filtered_data$Sos, na.rm = TRUE)
# Verificar el valor de mean_sos
print(mean_sos)
# Calcular la anomalía (Sos - promedio)
october_data <- october_data %>%
  mutate(anomaly = Sos - mean_sos)
# Verificar si la columna anomaly se creó correctamente
head(october_data)
# Filtrar nuevamente los datos para los días 21 a 23 con anomalías
filtered_data <- october_data %>%
  filter(Time >= as.Date("2005-10-21") & Time <= as.Date("2005-10-23"))
# Verificar el resultado final de filtered_data
head(filtered_data)

# Graficar la serie temporal completa de Sos en octubre
ggplot(october_data, aes(x = Time, y = Sos)) +
  geom_line(color = "blue") +
  geom_point(color = "blue") +
  labs(title = "Serie temporal de la Salinidad Superficial (Sos) - Octubre 2005",
       x = "Fecha (Día-Mes)", y = "Salinidad (Sos)") +
  theme_minimal()

# Graficar las anomalías de Sos del 21 al 23 de octubre
ggplot(filtered_data, aes(x = Time, y = anomaly)) +
  geom_line(color = "red") +
  geom_point(color = "red") +
  labs(title = "Anomalía de la Salinidad Superficial (Sos) - 21 a 23 de Octubre 2005",
       x = "Fecha (Día-Mes)", y = "Anomalía de Sos") +
  theme_minimal()

######################################################################
######################################################################
######################################################################

# Cargar librerías
library(dplyr)
library(ggplot2)
library(lubridate)
library(zoo)

# Leer el archivo CSV y convertir 'nan' a NA
file_path <- "/Volumes/LLACA/Python/Caribe/sos_caribe.csv"
# Leer el archivo CSV sin convertir 'nan' a NA
data <- read.csv(file_path, stringsAsFactors = FALSE)
# Verificar los primeros valores de la columna Time
head(data$Time)
# Convertir la columna Time al formato correcto
data$Time <- as.Date(data$Time, format = "%Y-%m-%d")
# Verificar la conversión de fechas
head(data$Time)

# Interpolar los valores faltantes en la columna Sos
data$Sos <- na.approx(data$Sos, na.rm = FALSE)
# Reemplazar los NA restantes por el promedio de Sos
mean_sos_total <- mean(data$Sos, na.rm = TRUE)
data$Sos[is.na(data$Sos)] <- mean_sos_total
# Verificar los datos después de la interpolación
head(data)
# Filtrar los datos para todo el mes de octubre de 2005
october_data <- data %>%
  filter(Time >= as.Date("2005-10-01") & Time <= as.Date("2005-10-31"))

# Filtrar los datos para el transecto (Longitud: -87 a -86.46, Latitud: 20.15 a 20.43)
transect_data <- october_data %>%
  filter(Longitude >= -87.4 & Longitude <= -83 &
           Latitude >= 16 & Latitude <= 25)

# Filtrar los datos para los días 21 a 23 de octubre en el transecto
filtered_data_transect <- transect_data %>%
  filter(Time >= as.Date("2005-10-21") & Time <= as.Date("2005-10-23"))

# Calcular la anomalía para los días 21 a 23 de octubre
# Calcular la media de Sos para el periodo específico
mean_sos <- mean(filtered_data_transect$Sos, na.rm = TRUE)

# Calcular la desviación estándar para el periodo específico
std_dev <- sd(filtered_data_transect$Sos, na.rm = TRUE)

# Calcular la anomalía
filtered_data_transect <- filtered_data_transect %>%
  mutate(anomaly = Sos - mean_sos)

# Calcular la incertidumbre (en este caso, la desviación estándar)
uncertainty <- std_dev

# Verificar los resultados
cat("Promedio de Sos (21-23 octubre):", mean_sos, "\n")
cat("Desviación estándar (21-23 octubre):", std_dev, "\n")
cat("Incertidumbre (21-23 octubre):", uncertainty, "\n")

# Graficar las anomalías de Sos del 21 al 23 de octubre
ggplot(filtered_data_transect, aes(x = Time, y = anomaly)) +
  geom_line(color = "red") +
  geom_point(color = "red") +
  labs(title = "Anomalía de la Salinidad Superficial (Sos) - 21 a 23 de Octubre 2005",
       x = "Fecha (Día-Mes)", y = "Anomalía de Sos") +
  theme_minimal()

