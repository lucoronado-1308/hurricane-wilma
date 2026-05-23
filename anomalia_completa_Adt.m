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

% 4. Extraer mes y año para el agrupamiento
data.Month = month(data.Time);
data.Year = year(data.Time);

% 5. Calcular la climatología de ADT por mes, latitud y longitud
% Excluir valores NaN de ADT
climatology_data = varfun(@mean, data(~isnan(data.ADT), :), 'InputVariables', 'ADT', ...
    'GroupingVariables', {'Month', 'Latitude', 'Longitude'}, 'OutputFormat', 'table');

% 6. Guardar la climatología mensual en un archivo .mat
save('/Volumes/LLACA/Posdoctorado/Gaby/climatologia_adt_mensual.mat', 'climatology_data');

% 7. Calcular la anomalía de ADT para toda la serie de tiempo
% Usar ismember para hacer coincidir las coordenadas lat/long y el mes de cada registro con la climatología
[found, idx] = ismember([data.Month, data.Latitude, data.Longitude], ...
                        [climatology_data.Month, climatology_data.Latitude, climatology_data.Longitude], 'rows');

% Inicializar la columna de anomalías
data.Anomalia = nan(height(data), 1);

% Para las filas donde se encontró coincidencia, calcular la anomalía
data.Anomalia(found) = data.ADT(found) - climatology_data.mean_ADT(idx(found));

% 8. Guardar los resultados con anomalías en un archivo CSV
output_table = table(data.Time, data.Latitude, data.Longitude, ...
                     data.ADT, data.Anomalia, 'VariableNames', {'Fecha', 'Latitud', 'Longitud', 'ADT', 'Anomalia'});

writetable(output_table, '/Volumes/LLACA/Posdoctorado/Gaby/anomalia_adt_toda_serie.csv');

disp('La climatología mensual de ADT se ha guardado en "climatologia_adt_mensual.mat".');
disp('Las anomalías de ADT para toda la serie se han guardado en "anomalia_adt_toda_serie.csv".');
