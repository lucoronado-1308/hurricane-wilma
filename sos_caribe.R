# Limpiar el entorno
rm(list = ls())

# Cargar librerías
library(dplyr)
library(ggplot2)
library(lubridate)
library(zoo)

# Leer los archivos CSV y convertir 'nan' a NA
file_path_2005 <- "/Volumes/LLACA/Python/Caribe/sos_caribe.csv"
file_path_2006 <- "/Volumes/LLACA/Python/Caribe/sos_2006.csv"

data_2005 <- read.csv(file_path_2005, stringsAsFactors = FALSE)
data_2006 <- read.csv(file_path_2006, stringsAsFactors = FALSE)

# Convertir 'nan' a NA
data_2005[data_2005 == "NaN"] <- NA
data_2006[data_2006 == "NaN"] <- NA

# Convertir la columna Time al formato correcto
data_2005$Time <- as.Date(data_2005$Time, format = "%Y-%m-%d")
data_2006$Time <- as.Date(data_2006$Time, format = "%Y-%m-%d")

# Interpolar los valores faltantes en la columna Sos y reemplazar los NA restantes por el promedio
data_2005$Sos <- na.approx(data_2005$Sos, na.rm = FALSE)
mean_sos_2005 <- mean(data_2005$Sos, na.rm = TRUE)
data_2005$Sos[is.na(data_2005$Sos)] <- mean_sos_2005

data_2006$Sos <- na.approx(data_2006$Sos, na.rm = FALSE)
mean_sos_2006 <- mean(data_2006$Sos, na.rm = TRUE)
data_2006$Sos[is.na(data_2006$Sos)] <- mean_sos_2006

# Filtrar datos para octubre en ambos años
october_data_2005 <- data_2005 %>%
  filter(format(Time, "%m") == "10")

october_data_2006 <- data_2006 %>%
  filter(format(Time, "%m") == "10")

# Calcular la anomalía
mean_sos_2005 <- mean(october_data_2005$Sos, na.rm = TRUE)
mean_sos_2006 <- mean(october_data_2006$Sos, na.rm = TRUE)

october_data_2005 <- october_data_2005 %>%
  mutate(anomaly = Sos - mean_sos_2005)

october_data_2006 <- october_data_2006 %>%
  mutate(anomaly = Sos - mean_sos_2006)

# Graficar la serie temporal completa de Sos en octubre para ambos años
ggplot() +
  geom_line(data = october_data_2005, aes(x = Time, y = Sos), color = "red") +
  geom_point(data = october_data_2005, aes(x = Time, y = Sos), color = "red") +
  geom_line(data = october_data_2006, aes(x = Time, y = Sos), color = "blue") +
  geom_point(data = october_data_2006, aes(x = Time, y = Sos), color = "blue") +
  labs(title = "Salinidad Superficial (Sos) en Octubre 2005 y 2006",
       x = "Fecha (Día-Mes)", y = "Salinidad (Sos)") +
  scale_x_date(date_labels = "%d-%m", date_breaks = "1 day", limits = as.Date(c("2005-10-01", "2005-10-31"))) +
  theme_minimal()

# Graficar las anomalías de Sos en octubre para ambos años
ggplot() +
  geom_line(data = october_data_2005, aes(x = Time, y = anomaly), color = "red") +
  geom_point(data = october_data_2005, aes(x = Time, y = anomaly), color = "red") +
  geom_line(data = october_data_2006, aes(x = Time, y = anomaly), color = "blue") +
  geom_point(data = october_data_2006, aes(x = Time, y = anomaly), color = "blue") +
  labs(title = "Anomalía de la Salinidad Superficial (Sos) en Octubre 2005 y 2006",
       x = "Fecha (Día-Mes)", y = "Anomalía de Sos") +
  scale_x_date(date_labels = "%d-%m", date_breaks = "1 day", limits = as.Date(c("2005-10-01", "2005-10-31"))) +
  theme_minimal()

# Filtrar datos para el transecto en octubre
transect_data_2005 <- october_data_2005 %>%
  filter(Longitude >= -87 & Longitude <= -86.46 &
           Latitude >= 20.15 & Latitude <= 20.43)

transect_data_2006 <- october_data_2006 %>%
  filter(Longitude >= -87 & Longitude <= -86.46 &
           Latitude >= 20.15 & Latitude <= 20.43)

# Filtrar los días 21 a 23 de octubre en el transecto
filtered_data_transect_2005 <- transect_data_2005 %>%
  filter(Time >= as.Date("2005-10-21") & Time <= as.Date("2005-10-23"))

filtered_data_transect_2006 <- transect_data_2006 %>%
  filter(Time >= as.Date("2006-10-21") & Time <= as.Date("2006-10-23"))

# Calcular la anomalía para los días 21 a 23 de octubre en el transecto
mean_sos_transect_2005 <- mean(filtered_data_transect_2005$Sos, na.rm = TRUE)
mean_sos_transect_2006 <- mean(filtered_data_transect_2006$Sos, na.rm = TRUE)

std_dev_2005 <- sd(filtered_data_transect_2005$Sos, na.rm = TRUE)
std_dev_2006 <- sd(filtered_data_transect_2006$Sos, na.rm = TRUE)

filtered_data_transect_2005 <- filtered_data_transect_2005 %>%
  mutate(anomaly = Sos - mean_sos_transect_2005)

filtered_data_transect_2006 <- filtered_data_transect_2006 %>%
  mutate(anomaly = Sos - mean_sos_transect_2006)

# Verificar resultados de transecto
cat("Promedio de Sos en el transecto (21-23 octubre 2005):", mean_sos_transect_2005, "\n")
cat("Desviación estándar en el transecto (21-23 octubre 2005):", std_dev_2005, "\n")
cat("Promedio de Sos en el transecto (21-23 octubre 2006):", mean_sos_transect_2006, "\n")
cat("Desviación estándar en el transecto (21-23 octubre 2006):", std_dev_2006, "\n")

# Graficar las anomalías del transecto para el 21 al 23 de octubre
ggplot() +
  geom_line(data = filtered_data_transect_2005, aes(x = Time, y = anomaly), color = "red") +
  geom_point(data = filtered_data_transect_2005, aes(x = Time, y = anomaly), color = "red") +
  geom_line(data = filtered_data_transect_2006, aes(x = Time, y = anomaly), color = "blue") +
  geom_point(data = filtered_data_transect_2006, aes(x = Time, y = anomaly), color = "blue") +
  labs(title = "Anomalía de la Salinidad Superficial (Sos) en el Transecto - 21 a 23 de Octubre 2005 y 2006",
       x = "Fecha (Día-Mes)", y = "Anomalía de Sos") +
  scale_x_date(date_labels = "%d-%m", date_breaks = "1 day", limits = as.Date(c("2005-10-21", "2005-10-23"))) +
  theme_minimal()
