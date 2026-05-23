#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Sep  9 14:47:33 2024

@author: lucoronado
"""
#Altimeter satellite gridded Sea Level Anomalies (SLA) computed with respect to a twenty-year [1993, 2012] mean. The SLA is estimated by Optimal Interpolation, merging the L3 along-track measurement from the different altimeter missions available. Part of the processing is fitted to the Global ocean. (see QUID document or http://duacs.cls.fr pages for processing details). The product gives additional variables (i.e. Absolute Dynamic Topography and geostrophic currents (absolute and anomalies)). It serves in delayed-time applications. This product is processed by the DUACS multimission altimeter data processing system.

#DOI (product):https://doi.org/10.48670/moi-00148

#lcoronadoalvare

import copernicusmarine 
import os

os.chdir('/Volumes/LLACA/Python/Caribe')
os.getcwd()

copernicusmarine.subset(
  dataset_id="cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D",
  dataset_version="202112",
  variables=["adt"],
  minimum_longitude=-87.5,
  maximum_longitude=-80,
  minimum_latitude=15,
  maximum_latitude=25,
  start_datetime="2003-01-01T00:00:00",
  end_datetime="2007-12-31T00:00:00",
  force_download=True,
  subset_method="strict",
  disable_progress_bar=True,
)
#%% ==========================================================================
# import xarray as xr
# import pandas as pd

# # Ruta al archivo NetCDF
# nc_file_path = '/Volumes/LLACA/Python/Caribe/cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D_adt_87.38W-80.12W_15.12N-24.88N_2003-01-01-2007-12-31.nc'

# # Cargar el archivo NetCDF usando xarray
# ds = xr.open_dataset(nc_file_path)

# # Extraer las variables
# adt = ds['adt']  # Anomalía de la altura dinámica
# latitudes = ds['latitude'].values
# longitudes = ds['longitude'].values
# times = ds['time'].values

# # Crear una lista para almacenar los datos
# data = []

# # Iterar sobre las dimensiones
# for t in range(adt.sizes['time']):
#     for lat in range(adt.sizes['latitude']):
#         for lon in range(adt.sizes['longitude']):
#             data.append({
#                 'Time': pd.to_datetime(times[t]).strftime('%Y-%m-%d'),
#                 'Latitude': latitudes[lat],
#                 'Longitude': longitudes[lon],
#                 'ADT': adt[t, lat, lon].values  # adt en ese punto
#             })

# # Crear un DataFrame de pandas
# df = pd.DataFrame(data)

# #%% ==========================================================================

# import xarray as xr
# import pandas as pd

# # Ruta al archivo NetCDF
# nc_file_path = '/Volumes/LLACA/Python/Caribe/cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D_adt_87.38W-80.12W_15.12N-24.88N_2003-01-01-2007-12-31.nc'

# # Cargar el archivo NetCDF usando xarray
# ds = xr.open_dataset(nc_file_path)

# # Extraer las variables
# adt = ds['adt']  # Anomalía de la altura dinámica
# latitudes = ds['latitude'].values
# longitudes = ds['longitude'].values
# times = ds['time'].values

# # Verificar si hay valores de relleno o faltantes en 'adt'
# if hasattr(adt, '_FillValue'):
#     adt = adt.where(adt != adt._FillValue)
    
# if hasattr(adt, 'missing_value'):
#     adt = adt.where(adt != adt.missing_value)

# # Crear una lista para almacenar los datos
# data = []

# # Iterar sobre las dimensiones
# for t in range(adt.sizes['time']):
#     for lat in range(adt.sizes['latitude']):
#         for lon in range(adt.sizes['longitude']):
#             # Verificar si el valor no es NaN
#             adt_value = adt[t, lat, lon].values
#             if pd.notna(adt_value):
#                 data.append({
#                     'Time': pd.to_datetime(times[t]).strftime('%Y-%m-%d'),
#                     'Latitude': latitudes[lat],
#                     'Longitude': longitudes[lon],
#                     'ADT': adt_value  # ADT en ese punto
#                 })

# # Crear un DataFrame de pandas
# df = pd.DataFrame(data)

# # Guardar el DataFrame en un archivo CSV
# csv_file_path = '/Volumes/LLACA/Python/Caribe/adt_caribe.csv'
# df.to_csv(csv_file_path, index=False)

# print(f'Datos guardados en {csv_file_path}')


# # Guardar el DataFrame en un archivo CSV
# csv_file_path = '/Volumes/LLACA/Python/Caribe/adt_caribe.csv'
# df.to_csv(csv_file_path, index=False)

# print(f'Datos guardados en {csv_file_path}')

#%% ==========================================================================


import xarray as xr
import pandas as pd

# Ruta al archivo NetCDF
nc_file_path = '/Volumes/LLACA/Python/Caribe/cmems_obs-sl_glo_phy-ssh_my_allsat-l4-duacs-0.25deg_P1D_adt_87.38W-80.12W_15.12N-24.88N_2003-01-01-2007-12-31.nc'

# Cargar el archivo NetCDF usando xarray
ds = xr.open_dataset(nc_file_path)

# Extraer las variables
adt = ds['adt']  # Anomalía de la altura dinámica
latitudes = ds['latitude']
longitudes = ds['longitude']
times = ds['time']

# Convertir el dataset a formato pandas en una única operación
df = adt.to_dataframe().reset_index()

# Convertir el tiempo a formato datetime
df['time'] = pd.to_datetime(df['time'])

# Renombrar las columnas para mayor claridad
df.rename(columns={'time': 'Time', 'latitude': 'Latitude', 'longitude': 'Longitude', 'adt': 'ADT'}, inplace=True)

# Guardar el DataFrame en un archivo CSV
csv_file_path = '/Volumes/LLACA/Python/Caribe/adt_caribe.csv'
df.to_csv(csv_file_path, index=False)

print(f'Datos guardados en {csv_file_path}')
