# reset -f 
# clear
#%% ==========================================================================
# BSQ_plataforma_BGC_automate : Descarga datos automaticos (tests)
# SQ_copernicus_bgq_12_may_24 : Analiza variables para plataforma online BSQ

#%% ==========================================================================
# Nombre: Chl_caribe.py
# Objetivo: Descarga datos automaticos
# Descripcion: Genera bases de datos y graficos
# 
# 
# Copernicus // Global Ocean Biogeochemistry Hindcast  // doi 10.48670/moi-00019
# Solo mares de Mexico: 33, -120 // 12, -120 *//* 33, -80 // 12, -80
# Username: lcoronadoalvare  //   Temporary Password: Rova_1318

import copernicusmarine as cm
import os

os.chdir('/Volumes/LLACA/Python/Caribe')
os.getcwd()

# cmems_mod_glo_bgc-pft_anfc_0.25deg_P1D-m
cm.subset(
  dataset_id="cmems_mod_glo_bgc_my_0.25deg_P1D-m",
  # dataset_version="202311",
  variables=["chl"],
  minimum_longitude=-87.5,
  maximum_longitude=-80,
  minimum_latitude=15,
  maximum_latitude=25,
  start_datetime="2005-10-01T00:00:00",
  end_datetime="2005-10-30T00:00:00",
  minimum_depth=0.4940253794193268,
  maximum_depth=0.4940253794193268,
)

#%% ==========================================================================

# ===  Libs ===
import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import pandas as pd
import xarray as xr
from scipy import signal
import matplotlib.dates as mdates

# import pathlib
# import matplotlib.animation as animation
# import seaborn as sns

# ===  Database paths and names ===
os.chdir('/home/oem/Documents/Aqua-Cult/Plataforma BSQ/datos_on/copermarbgc')
os.getcwd()

# Carga base de datos individual //  '/full_path/filename.nc'
data = xr.open_dataset('/home/oem/Documents/Aqua-Cult/Plataforma BSQ/datos_on/copermarbgc/cmems_mod_glo_bgc-pft_anfc_0.25deg_P1D-m_chl-phyc_120.00W-80.00W_12.00N-33.00N_0.49m_2021-11-01-2024-07-24.nc')

# print(data.info) # Muestra la info del archivo
# Data coordinates = time: 365, depth: 1, latitude: 85, longitude: 161
# Data variables = chl, phyc
variable = data['chl'] # Extrae la variable

nlag = 10

# Serie de tiempo

yy = []; mm = []; dd = []
cla_ave = []; cla_sd = []

for i in range(len(variable)):
    kk1 = variable[i,0,70:75,12:18]
    yy.append(kk1.time.dt.year.values)
    mm.append(kk1.time.dt.month.values)
    dd.append(kk1.time.dt.day.values)
    cla_ave.append(np.nanmean(kk1))
    cla_sd.append(np.nanstd(kk1))

del(kk1, i)

yy = np.array(yy)
mm = np.array(mm)
dd = np.array(dd)
cla_ave = np.array(cla_ave)
cla_sd  = np.array(cla_sd)

alls ={'Year': yy, 'Month': mm, 'Day': dd, 'Chl_av': cla_ave, 'Chl_sd': cla_sd}

df = pd.DataFrame(alls)
df['Date'] = pd.to_datetime(df[['Year', 'Month', 'Day']]) # Crear una columna de fecha combinando las columnas de año, mes y día
df.set_index('Date', inplace=True)

del(data,alls, cla_ave, cla_sd, dd, yy, mm)

#  Acondicionamiento de TSs
sugus = df.Chl_av.rolling(nlag, center=True).mean()
anm_cla = df.Chl_av - sugus
anm_cla_av = (df.Chl_av - np.nanmean(df.Chl_av))/np.nanstd(df.Chl_av)
anm_cla_fill = anm_cla.interpolate(method='nearest')
anm_cla_filna = anm_cla.fillna(value=0)

anm_cla_raw = df.Chl_av - np.nanmean(df.Chl_av)
sugus3 = plt.mlab.detrend(df.Chl_av, key='linear')

# %%  FIGURAS
os.chdir('/home/oem/Documents/Aqua-Cult/Plataforma BSQ/datos_on/subidos/Jul17-Jul24-2024_set7/Cla')

last = len(df)-1
print("last date is ", df.index[last],"  and index  ", last)
last15= last-15

lastyr = last-365
lastyr15 = lastyr-15

lastyr2 = last-(365*2)
lastyr215 = lastyr2-15

# %%  FIG - HISTORICO

fig, ax = plt.subplots(nrows = 1, ncols = 1, figsize=(13,4.5))

ax.plot(df.index, df.Chl_av,'o-', color='0.4', linewidth=1.5, markersize=5)

ax.plot(df.index, sugus, '-', color="C1", linewidth=2.5)

ax.plot(df.index[lastyr215:lastyr2], df.Chl_av[lastyr215:lastyr2],'o-', color='r', linewidth=1.5, markersize=5)
ax.plot(df.index[lastyr15:lastyr], df.Chl_av[lastyr15:lastyr],'o-', color='r', linewidth=1.5, markersize=5)
ax.plot(df.index[last15:last], df.Chl_av[last15:last],'o-', color='g', linewidth=1.5, markersize=5)

ax.set_xlabel('Tiempo (Mes/Año)', weight='bold')
ax.set_ylabel('Clorofila-A', weight='bold')
ax.set_ylim([0, 2])
ax.grid(True, color='0.8')
date_format = mdates.DateFormatter('%m/%y')
ax.xaxis.set_major_formatter(date_format)

plt.savefig("SQ_Cla_av_His.png", format="png", dpi=800)

# %%  FIG - SEMANAL

fig, ax = plt.subplots(nrows = 1, ncols = 1, figsize=(13,4.5))

ax.errorbar(df.index[last15:last], df.Chl_av[last15:last], yerr=df.Chl_sd[last15:last], 
            marker='o', markersize=7, linestyle='-', capsize=3.0, ecolor='0.6')
ax.set_xlabel('Tiempo (Dia/Mes)', weight='bold')
ax.set_ylabel('Clorofila-A', weight='bold')
ax.set_ylim([0, 2.5])
ax.grid(True)
date_format = mdates.DateFormatter('%d/%m')
ax.xaxis.set_major_formatter(date_format)

plt.savefig("SQ_Cla_av_sd_Sem.png", format="png", dpi=800)

# %% Anomalias

fig, ax = plt.subplots(nrows = 1, ncols = 1, figsize=(13,4.5))

ax.plot(df.index, (sugus3*0),'o-', color='k', linewidth=1, markersize=1)

ax.plot(df.index, sugus3,'o-', color='0.6', linewidth=1.5, markersize=5)

ax.plot(df.index[lastyr215:lastyr2], sugus3[lastyr215:lastyr2],'o-', color='c', linewidth=1.5, markersize=5)
ax.plot(df.index[lastyr15:lastyr], sugus3[lastyr15:lastyr],'o-', color='b', linewidth=1.5, markersize=5)
ax.plot(df.index[last15:last], sugus3[last15:last],'o-', color='r', linewidth=1.5, markersize=5)

ax.plot(df.index, (np.ones((len(df),1))*np.nanmean(sugus3[last15:last])),'.', color='r', linewidth=0.5, markersize=0.5)
ax.plot(df.index, (np.ones((len(df),1))*np.nanmean(sugus3[lastyr15:lastyr])),'.', color='b', linewidth=0.5, markersize=0.5)
ax.plot(df.index, (np.ones((len(df),1))*np.nanmean(sugus3[lastyr215:lastyr2])),'.', color='c', linewidth=0.5, markersize=0.5)

ax.set_xlabel('Tiempo (Mes/Año)', weight='bold')
ax.set_ylabel('Clorofila-A', weight='bold')
# ax.set_ylim([-0.25, 0.25])
ax.grid(True, color='0.8')
date_format = mdates.DateFormatter('%m/%y')
ax.xaxis.set_major_formatter(date_format)

plt.savefig("SQ_Cla_av_His_Anm.png", format="png", dpi=800)

# %% Analisis espectral

fig, axs = plt.subplots(nrows=1, ncols=2,figsize=(12,4))

axs[0].specgram(anm_cla_filna, Fs=1, cmap="rainbow")
axs[0].set_title('Espectrograma', weight='bold')
axs[0].set_xlabel("nDatos", weight='bold')
axs[0].set_ylabel("Frec.", weight='bold')

freq, power = signal.periodogram(anm_cla_filna, fs=1, detrend= 'constant', return_onesided=True, scaling='spectrum')
pow_mx = power/np.max(power)
cycles = 1/freq
axs[1].plot(cycles, pow_mx)
axs[1].set_xlim([0, 60])
axs[1].set_ylim([0, 1])
axs[1].set_title('Periodograma', weight='bold')
axs[1].set_xlabel('Dias (Ciclos)', weight='bold')
axs[1].set_ylabel('PSD (Unidades^2)', weight='bold')

plt.savefig("SQ_Cla_Anm_Spectral.png", format="png", dpi=800)

#%% ==========================================================================
#  EXTRAS
#% ==========================================================================
# %%

fig, axs = plt.subplots(nrows = 3, ncols = 1, figsize=(15,8))

axs[0].plot(df.index, df.Chl_av,'b', df.index, sugus, 'r-')
axs[0].set_xlabel('Time')
axs[0].set_ylabel('Cla mg/L')

axs[1].plot(df.index, anm_cla,'b', df.index, np.zeros((len(df),1)), 'k-')
axs[1].set_xlabel('Time')
axs[1].set_ylabel('anm_Cla')

axs[2].plot(df.index, anm_cla_av,'b', df.index, np.zeros((len(df),1)), 'k-')
axs[2].set_xlabel('Time')
axs[2].set_ylabel('anm_std_Cla')

# %% 

fig, axs = plt.subplots(nrows=1, ncols=2,figsize=(12,4))

axs[0].specgram(anm_cla_filna, Fs=1, cmap="rainbow")
axs[0].set_title('Spectrogram')
axs[0].set_xlabel("Cla-a")
axs[0].set_ylabel("Time")

freq, power = signal.periodogram(anm_cla_filna, fs=1, detrend= 'constant', return_onesided=True, scaling='spectrum')

pow_mx = power/np.max(power)
cycles = 1/freq

axs[1].plot(cycles, pow_mx)
axs[1].set_xlim([0, 60])
axs[1].set_title('Periodogram')
axs[1].set_xlabel('Days (Cycles)')
axs[1].set_ylabel('PSD (U^2)')

plt.show()

# %%
plt.figure(figsize=(10, 6))

plt.plot(df.index, df.Chl_av, marker='o', linestyle='-')
plt.title('Serie de tiempo')
plt.xlabel('Tiempo')
plt.ylabel('Chl-a (mg/L)')
plt.grid(True)
plt.show()

# %%


# %%
