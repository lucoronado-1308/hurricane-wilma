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

% 6. Filtrar los datos para octubre de 2005 (mes 10, año 2005)
october_2005_data = data(data.Month == 10 & data.Year == 2005, :);

% 7. Calcular las anomalías de SST para octubre de 2005
% Usar ismember para hacer coincidir coordenadas y mes entre datos de octubre y climatología
[found, idx] = ismember([october_2005_data.Month, october_2005_data.Latitude, october_2005_data.Longitude], ...
                        [climatology_data.Month, climatology_data.Latitude, climatology_data.Longitude], 'rows');

% Inicializar la columna de anomalías para octubre de 2005
october_2005_data.Anomalia = nan(height(october_2005_data), 1);

% Para las filas donde se encontró coincidencia, calcular la anomalía
october_2005_data.Anomalia(found) = october_2005_data.SST(found) - climatology_data.mean_SST(idx(found));

% 8. Guardar los resultados de octubre de 2005 en un archivo CSV
output_table_october = table(october_2005_data.Time, october_2005_data.Latitude, october_2005_data.Longitude, ...
                              october_2005_data.SST, october_2005_data.Anomalia, ...
                              'VariableNames', {'Fecha', 'Latitud', 'Longitud', 'SST', 'Anomalia'});

writetable(output_table_october, '/Volumes/LLACA/Posdoctorado/Gaby/anomalia_sst_octubre_2005.csv');

disp('Las anomalías de SST para octubre de 2005 se han guardado en "anomalia_sst_octubre_2005.csv".');
