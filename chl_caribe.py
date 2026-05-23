#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Sep  6 12:45:15 2024

@author: lucoronado
"""
#Global Ocean Biogeochemistry Hindcast
#The biogeochemical hindcast for global ocean is produced at Mercator-Ocean (Toulouse. France). It provides 3D biogeochemical fields since year 1993 at 1/4 degree and on 75 vertical levels. It uses PISCES biogeochemical model (available on the NEMO modelling platform). No data assimilation in this product.
#DOI 10.48670/moi-00019
#lcoronadoalvare

import copernicusmarine

copernicusmarine.subset(
  dataset_id="cmems_mod_glo_bgc_my_0.25deg_P1D-m",
  dataset_version="202406",
  variables=["chl"],
  minimum_longitude=-87.5,
  maximum_longitude=-80,
  minimum_latitude=15,
  maximum_latitude=25,
  start_datetime="2003-01-01T00:00:00",
  end_datetime="2007-12-30T00:00:00",
  minimum_depth=0.5057600140571594,
  maximum_depth=0.5057600140571594,
  force_download=True,
  subset_method="strict",
  disable_progress_bar=True,
)

#%% ==========================================================================
# import xarray as xr
# import pandas as pd

# # Ruta al archivo NetCDF
# nc_file_path = '/Volumes/LLACA/Python/Caribe/cmems_mod_glo_bgc_my_0.25deg_P1D-m_chl_87.50W-80.00W_15.00N-25.00N_0.51m_2006-10-01-2006-10-30.nc'

# # Cargar el archivo NetCDF usando xarray
# ds = xr.open_dataset(nc_file_path)

# # Extraer las variables
# chl = ds['chl']
# latitudes = ds['latitude'].values
# longitudes = ds['longitude'].values
# times = ds['time'].values
# depth = ds['depth'].values[0]  # Asumiendo que hay solo un valor en la dimensión 'depth'

# # Crear una lista para almacenar los datos
# data = []

# # Iterar sobre las dimensiones
# for t in range(chl.sizes['time']):
#     for d in range(chl.sizes['depth']):
#         for lat in range(chl.sizes['latitude']):
#             for lon in range(chl.sizes['longitude']):
#                 data.append({
#                     'Time': pd.to_datetime(times[t]).strftime('%Y-%m-%d'),
#                     'Depth': depth,
#                     'Latitude': latitudes[lat],
#                     'Longitude': longitudes[lon],
#                     'Chl': chl[t, d, lat, lon].values
#                 })

# # Crear un DataFrame de pandas
# df = pd.DataFrame(data)

# # Guardar el DataFrame en un archivo CSV
# csv_file_path = '/Volumes/LLACA/Python/Caribe/chl_2003_2007.csv'
# df.to_csv(csv_file_path, index=False)

# print(f'Datos guardados en {csv_file_path}')


#%% ==========================================================================
#para probar

import xarray as xr
import pandas as pd

# Ruta al archivo NetCDF
nc_file_path = '/Volumes/LLACA/Python/Caribe/cmems_mod_glo_bgc_my_0.25deg_P1D-m_chl_87.50W-80.00W_15.00N-25.00N_0.51m_2003-01-01-2007-12-30.nc'

# Cargar el archivo NetCDF usando xarray
ds = xr.open_dataset(nc_file_path)

# Seleccionar las variables necesarias
chl = ds['chl'].sel(depth=0.51, method='nearest')  # Selecciona la profundidad de 0.51m
latitudes = ds['latitude']
longitudes = ds['longitude']
times = pd.to_datetime(ds['time'].values)

# Convertir el DataArray a un DataFrame, lo cual es más eficiente
df = chl.to_dataframe().reset_index()

# Agregar la columna 'Depth' fija para cada fila
df['Depth'] = 0.51

# Renombrar las columnas para mayor claridad
df.rename(columns={'time': 'Time', 'latitude': 'Latitude', 'longitude': 'Longitude', 'chl': 'Chl'}, inplace=True)

# Guardar el DataFrame en un archivo CSV
csv_file_path = '/Volumes/LLACA/Python/Caribe/chl_2003_2007.csv'
df.to_csv(csv_file_path, index=False)

print(f'Datos guardados en {csv_file_path}')


