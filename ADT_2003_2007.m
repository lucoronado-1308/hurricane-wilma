% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% 1. Cargar el archivo CSV (ADT)
filename = '/Volumes/LLACA/Posdoctorado/Gaby/adt_caribe.csv';
data = readtable(filename);

% 2. Convertir Time a formato datetime usando el formato yyyy/MM/dd
data.Time = datetime(data.Time, 'InputFormat', 'yyyy/MM/dd');

% 3. Reemplazar valores vacíos en ADT por NaN
data.ADT(isempty(data.ADT)) = NaN; % Verifica los valores vacíos en ADT y reemplázalos con NaN

% 4. Filtrar datos de octubre de 2005
oct_2005_idx = (data.Time >= datetime(2005,10,1) & data.Time <= datetime(2005,10,31));
oct_2005_data = data(oct_2005_idx, :);

% 5. Filtrar los datos restantes (sin octubre de 2005) para calcular la climatología
remaining_data = data(~oct_2005_idx, :);

% 6. Extraer mes y año para el agrupamiento
remaining_data.Month = month(remaining_data.Time);
remaining_data.Year = year(remaining_data.Time);

% 7. Calcular la climatología de ADT por mes, latitud y longitud
% Excluir valores NaN de ADT
climatology_data = varfun(@mean, remaining_data(~isnan(remaining_data.ADT), :), 'InputVariables', 'ADT', ...
    'GroupingVariables', {'Month', 'Latitude', 'Longitude'}, 'OutputFormat', 'table');

% 8. Guardar la climatología mensual en un archivo .mat
save('/Volumes/LLACA/Posdoctorado/Gaby/climatologia_adt_mensual.mat', 'climatology_data');

% 9. Calcular la climatología de ADT para octubre (sin incluir octubre de 2005)
oct_climatology = climatology_data(climatology_data.Month == 10, :);

% 10. Calcular la anomalía de ADT para octubre de 2005
% Usar ismember para hacer coincidir las coordenadas lat/long de octubre 2005 con las de la climatología
[found, idx] = ismember([oct_2005_data.Latitude, oct_2005_data.Longitude], ...
                        [oct_climatology.Latitude, oct_climatology.Longitude], 'rows');

% Inicializar la columna de anomalías
anomaly = nan(height(oct_2005_data), 1);

% Para las filas donde se encontró coincidencia, calcular la anomalía
anomaly(found) = oct_2005_data.ADT(found) - oct_climatology.mean_ADT(idx(found));

% 11. Guardar los resultados en un archivo CSV con la anomalía de octubre de 2005
output_table = table(oct_2005_data.Time, oct_2005_data.Latitude, oct_2005_data.Longitude, ...
                     oct_2005_data.ADT, anomaly, 'VariableNames', {'Fecha', 'Latitud', 'Longitud', 'ADT', 'Anomalia'});

writetable(output_table, '/Volumes/LLACA/Posdoctorado/Gaby/anomalia_adt_octubre_2005.csv');

disp('La climatología mensual de ADT se ha guardado en "climatologia_adt_mensual.mat".');
disp('Las anomalías de ADT para octubre de 2005 se han guardado en "anomalia_octubre_2005.csv".');
