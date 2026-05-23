#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Sep  6 13:10:45 2024

@author: lucoronado
"""

#Global Ocean Physics Reanalysis
#The GLORYS12V1 product is the CMEMS global ocean eddy-resolving (1/12° horizontal resolution, 50 vertical levels) reanalysis covering the altimetry (1993 onward).
#It is based largely on the current real-time global forecasting CMEMS system. The model component is the NEMO platform driven at surface by ECMWF ERA-Interim then ERA5 reanalyses for recent years. Observations are assimilated by means of a reduced-order Kalman filter. Along track altimeter data (Sea Level Anomaly), Satellite Sea Surface Temperature, Sea Ice Concentration and In situ Temperature and Salinity vertical Profiles are jointly assimilated. Moreover, a 3D-VAR scheme provides a correction for the slowly-evolving large-scale biases in temperature and salinity.
#This product includes daily and monthly mean files for temperature, salinity, currents, sea level, mixed layer depth and ice parameters from the top to the bottom. The global ocean output files are displayed on a standard regular grid at 1/12° (approximatively 8 km) and on 50 standard levels.
#https://doi.org/10.48670/moi-00021
#lcoronadoalvare

import copernicusmarine 
import os

os.chdir('/Volumes/LLACA/Python/Caribe')
os.getcwd()


copernicusmarine.subset(
  dataset_id="METOFFICE-GLO-SST-L4-REP-OBS-SST",
  dataset_version="202003",
  variables=["analysed_sst"],
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
# nc_file_path = '/Volumes/LLACA/Python/Caribe/METOFFICE-GLO-SST-L4-REP-OBS-SST_analysed_sst_87.47W-80.03W_15.02N-24.98N_2006-10-01-2006-10-31.nc'

# # Cargar el archivo NetCDF usando xarray
# ds = xr.open_dataset(nc_file_path)

# # Extraer las variables
# sst = ds['analysed_sst']
# latitudes = ds['latitude'].values
# longitudes = ds['longitude'].values
# times = ds['time'].values

# # Crear una lista para almacenar los datos
# data = []

# # Iterar sobre las dimensiones
# for t in range(sst.sizes['time']):
#     for lat in range(sst.sizes['latitude']):
#         for lon in range(sst.sizes['longitude']):
#             data.append({
#                 'Time': pd.to_datetime(times[t]).strftime('%Y-%m-%d'),
#                 'Latitude': latitudes[lat],
#                 'Longitude': longitudes[lon],
#                 'SST': sst[t, lat, lon].values
#             })

# # Crear un DataFrame de pandas
# df = pd.DataFrame(data)

# # Guardar el DataFrame en un archivo CSV
# csv_file_path = '/Volumes/LLACA/Python/Caribe/sst_2003_2007.csv'
# df.to_csv(csv_file_path, index=False)

# print(f'Datos guardados en {csv_file_path}')

# #%% ==========================================================================
# import xarray as xr
# import pandas as pd

# # Ruta al archivo NetCDF
# nc_file_path = '/Volumes/LLACA/Python/Caribe/METOFFICE-GLO-SST-L4-REP-OBS-SST_analysed_sst_87.47W-80.03W_15.02N-24.98N_2005-10-01-2005-10-31.nc'

# # Cargar el archivo NetCDF usando xarray
# ds = xr.open_dataset(nc_file_path)

# # Extraer las variables y crear un DataFrame directamente
# df = ds['analysed_sst'].to_dataframe().reset_index()

# # Guardar el DataFrame en un archivo CSV
# csv_file_path = '/Volumes/LLACA/Python/Caribe/sst_2003_2007.csv'
# df.to_csv(csv_file_path, index=False)

# print(f'Datos guardados en {csv_file_path}')

#%% ==========================================================================
#para probar

import xarray as xr
import pandas as pd

# Ruta al archivo NetCDF
nc_file_path = '/Volumes/LLACA/Python/Caribe/METOFFICE-GLO-SST-L4-REP-OBS-SST_analysed_sst_87.47W-80.03W_15.02N-24.98N_2003-01-01-2007-12-31.nc'

# Cargar el archivo NetCDF usando xarray
ds = xr.open_dataset(nc_file_path)

# Convertir directamente a DataFrame usando el método optimizado de xarray
df = ds['analysed_sst'].to_dataframe().reset_index()

# Convertir la columna de tiempo a formato datetime
df['time'] = pd.to_datetime(df['time'])

# Renombrar columnas para mayor claridad
df.rename(columns={'time': 'Time', 'latitude': 'Latitude', 'longitude': 'Longitude', 'analysed_sst': 'SST'}, inplace=True)

# Guardar el DataFrame en un archivo CSV
csv_file_path = '/Volumes/LLACA/Python/Caribe/sst_2003_2007.csv'
df.to_csv(csv_file_path, index=False)

print(f'Datos guardados en {csv_file_path}')

