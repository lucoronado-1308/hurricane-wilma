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
% Extraer mes y año
data.Month = month(data.Time);
data.Year = year(data.Time);

% Calcular el promedio mensual por mes y año, ignorando NaN
monthly_mean = varfun(@mean, data(~isnan(data.SST), :), 'InputVariables', 'SST', ...
    'GroupingVariables', {'Year', 'Month'}, 'OutputFormat', 'table');

% Unir los datos originales con los promedios mensuales
data_with_nan = data(isnan(data.SST), :);
filled_data = outerjoin(data_with_nan, monthly_mean, 'Keys', {'Year', 'Month'}, ...
    'LeftVariables', {'Time', 'Latitude', 'Longitude', 'SST', 'Year', 'Month'}, ...
    'RightVariables', 'mean_SST', 'Type', 'left');

% Reemplazar valores de SST NaN con los promedios calculados
data.SST(isnan(data.SST)) = filled_data.mean_SST;

% 5. Calcular la climatología de SST por mes, latitud y longitud
climatology_data = varfun(@mean, data, 'InputVariables', 'SST', ...
    'GroupingVariables', {'Month', 'Latitude', 'Longitude'}, 'OutputFormat', 'table');

% Guardar la climatología mensual en un archivo .mat
save('/Volumes/LLACA/Posdoctorado/Gaby/climatologia_sst_mensual.mat', 'climatology_data');

% 6. Calcular las anomalías de SST para toda la serie
% Usar ismember para hacer coincidir coordenadas y mes entre datos originales y climatología
[found, idx] = ismember([data.Month, data.Latitude, data.Longitude], ...
                        [climatology_data.Month, climatology_data.Latitude, climatology_data.Longitude], 'rows');

% Inicializar la columna de anomalías
data.Anomalia = nan(height(data), 1);

% Para las filas donde se encontró coincidencia, calcular la anomalía
data.Anomalia(found) = data.SST(found) - climatology_data.mean_SST(idx(found));

% 7. Guardar los resultados en un archivo CSV
output_table = table(data.Time, data.Latitude, data.Longitude, ...
                     data.SST, data.Anomalia, 'VariableNames', {'Fecha', 'Latitud', 'Longitud', 'SST', 'Anomalia'});

writetable(output_table, '/Volumes/LLACA/Posdoctorado/Gaby/anomalia_sst_toda_serie.csv');

disp('La climatología mensual se ha guardado en "climatologia_sst_mensual.mat".');
disp('Las anomalías de SST para toda la serie se han guardado en "anomalia_sst_toda_serie.csv".');
