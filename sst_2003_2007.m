% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% 1. Cargar el archivo CSV
filename = '/Volumes/LLACA/Posdoctorado/Gaby/sst_2003_2007.csv';
data = readtable(filename);

% 2. Convertir Time a formato datetime usando el formato yyyy-MM-dd
data.Time = datetime(data.Time, 'InputFormat', 'yyyy-MM-dd');

% 3. Convertir SST de Kelvin a grados Celsius
data.SST = data.SST - 273.15;

% 4. Rellenar NaN con el promedio mensual de cada año
% Calcular el promedio mensual para cada mes-año, ignorando los NaN
data.Month = month(data.Time);
data.Year = year(data.Time);

% Calcular el promedio mensual sin iteraciones
monthly_mean = varfun(@mean, data(~isnan(data.SST), :), 'InputVariables', 'SST', ...
    'GroupingVariables', {'Year', 'Month'}, 'OutputFormat', 'table');

% Reemplazar NaN con el promedio mensual usando join en lugar de un bucle
data_with_nan = data(isnan(data.SST), :);
filled_data = outerjoin(data_with_nan, monthly_mean, 'Keys', {'Year', 'Month'}, ...
    'LeftVariables', {'Time', 'Latitude', 'Longitude', 'SST', 'Year', 'Month'}, ...
    'RightVariables', 'mean_SST', 'Type', 'left');

% Reemplazar valores de SST NaN por los promedios calculados
data.SST(isnan(data.SST)) = filled_data.mean_SST;

% 5. Filtrar datos excluyendo octubre de 2005
oct_2005_idx = (data.Time >= datetime(2005,10,1) & data.Time <= datetime(2005,10,31));
remaining_data = data(~oct_2005_idx, :);

% 6. Calcular la climatología de SST por mes
% Agrupamos los datos por mes, latitud y longitud
climatology_data = varfun(@mean, remaining_data, 'InputVariables', 'SST', ...
    'GroupingVariables', {'Month', 'Latitude', 'Longitude'}, 'OutputFormat', 'table');

% Reorganizar las columnas y renombrar
climatology_data.Properties.VariableNames{'mean_SST'} = 'SST';

% 7. Guardar la climatología mensual en un archivo .mat
save('/Volumes/LLACA/Posdoctorado/Gaby/climatologia_sst_mensual.mat', 'climatology_data');

% 8. Extraer datos para octubre de 2005
oct_2005_data = data(oct_2005_idx, :);

% 9. Calcular la climatología de SST para octubre (basada en datos 2003-2007, excepto octubre 2005)
oct_climatology = climatology_data(climatology_data.Month == 10, :);

% 10. Calcular la anomalía de SST para octubre de 2005
% Usar ismember para evitar bucles
[found, idx] = ismember([oct_2005_data.Latitude, oct_2005_data.Longitude], ...
                        [oct_climatology.Latitude, oct_climatology.Longitude], 'rows');

% Inicializar la columna de anomalías
anomaly = nan(height(oct_2005_data), 1);

% Para las filas donde se encontró coincidencia, calcular la anomalía
anomaly(found) = oct_2005_data.SST(found) - oct_climatology.SST(idx(found));

% 11. Guardar los resultados en un archivo CSV
output_table = table(oct_2005_data.Time, oct_2005_data.Latitude, oct_2005_data.Longitude, ...
                     oct_2005_data.SST, anomaly, 'VariableNames', {'Fecha', 'Latitud', 'Longitud', 'SST', 'Anomalia'});

writetable(output_table, '/Volumes/LLACA/Posdoctorado/Gaby/anomalia_sst_octubre_2005.csv');

disp('La climatología mensual se ha guardado en "climatologia_mensual.mat".');
disp('Las anomalías de SST para octubre de 2005 se han guardado en "anomalia_octubre_2005.csv".');

