#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Sep  6 13:34:36 2024

@author: lucoronado
"""

#Multi Observation Global Ocean Sea Surface Salinity and Sea Surface Density
#This product consits of daily global gap-free Level-4 (L4) analyses of the Sea Surface Salinity (SSS) and Sea Surface Density (SSD) at 1/8° of resolution, obtained through a multivariate optimal interpolation algorithm that combines sea surface salinity images from multiple satellite sources as NASA’s Soil Moisture Active Passive (SMAP) and ESA’s Soil Moisture Ocean Salinity (SMOS) satellites with in situ salinity measurements and satellite SST information. The product was developed by the Consiglio Nazionale delle Ricerche (CNR) and includes 4 datasets:
#10.48670/moi-00051
#lcoronadoalvare

import copernicusmarine 
import os

os.chdir('/Volumes/LLACA/Python/Caribe')
os.getcwd()

copernicusmarine.subset(
  dataset_id="cmems_obs-mob_glo_phy-sss_my_multi_P1D",
  dataset_version="202311",
  variables=["sos", "sos_error", "dos"],
  minimum_longitude=-87.5,
  maximum_longitude=-80,
  minimum_latitude=15,
  maximum_latitude=25,
  start_datetime="2003-01-01T00:00:00",
  end_datetime="2007-12-31T00:00:00",
  minimum_depth=0,
  maximum_depth=0,
  force_download=True,
  subset_method="strict",
  disable_progress_bar=True,
)


#%% ==========================================================================
#para probar
import xarray as xr
import pandas as pd

# Ruta al archivo NetCDF
nc_file_path = '/Volumes/LLACA/Python/Caribe/cmems_obs-mob_glo_phy-sss_my_multi_P1D_multi-vars_87.44W-80.06W_15.06N-24.94N_0.00m_2003-01-01-2007-12-31.nc'

# Cargar el archivo NetCDF usando xarray
ds = xr.open_dataset(nc_file_path)

# Seleccionar variables necesarias
sos = ds['sos']  # Salinidad de superficie
latitudes = ds['latitude']
longitudes = ds['longitude']
times = pd.to_datetime(ds['time'].values)
depth = ds['depth'].values[0]  # Solo una profundidad

# Crear un DataFrame de pandas directamente desde el DataArray
df = sos.sel(depth=depth).to_dataframe().reset_index()

# Agregar la columna 'Depth' fija para cada fila
df['Depth'] = depth

# Convertir la columna de tiempo a formato datetime si no está ya en ese formato
df['time'] = pd.to_datetime(df['time'])

# Renombrar las columnas para mayor claridad
df.rename(columns={'time': 'Time', 'latitude': 'Latitude', 'longitude': 'Longitude', 'sos': 'Sos'}, inplace=True)

# Guardar el DataFrame en un archivo CSV
csv_file_path = '/Volumes/LLACA/Python/Caribe/sos_2003_2007.csv'
df.to_csv(csv_file_path, index=False)

print(f'Datos guardados en {csv_file_path}')

