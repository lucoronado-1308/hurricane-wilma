% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% 1. Cargar el archivo CSV
filename = '/Volumes/LLACA/Posdoctorado/Gaby/sos_2003_2007.csv';
data = readtable(filename);

% 2. Convertir Time a formato datetime usando el formato yyyy/MM/dd
data.Time = datetime(data.Time, 'InputFormat', 'yyyy/MM/dd');

% 3. Verificar si la columna 'Sos' es de tipo celda y manejar los valores vacíos
if iscell(data.Sos)
    % Si 'Sos' es una celda, reemplazar celdas vacías con NaN
    data.Sos(cellfun('isempty', data.Sos)) = {NaN};
    data.Sos = cell2mat(data.Sos);  % Convertir a formato numérico si es necesario
else
    % Si 'Sos' no es una celda, reemplazar directamente valores vacíos con NaN
    data.Sos(isnan(data.Sos)) = NaN;  % Esto maneja directamente los NaN
end

% 4. Agregar columna de mes y año para cálculos posteriores
data.Month = month(data.Time);
data.Year = year(data.Time);

% 5. Calcular la climatología de Sos por mes, latitud y longitud
climatology_data = varfun(@mean, data(~isnan(data.Sos), :), 'InputVariables', 'Sos', ...
    'GroupingVariables', {'Month', 'Latitude', 'Longitude'}, 'OutputFormat', 'table');

% Renombrar columna resultante de la climatología
climatology_data.Properties.VariableNames{'mean_Sos'} = 'Sos';

% 6. Guardar la climatología mensual en un archivo .mat
save('/Volumes/LLACA/Posdoctorado/Gaby/climatologia_sos_mensual.mat', 'climatology_data');

% 7. Calcular las anomalías de Sos para toda la serie
% Usar ismember para hacer coincidir coordenadas y mes entre los datos originales y la climatología
[found, idx] = ismember([data.Month, data.Latitude, data.Longitude], ...
                        [climatology_data.Month, climatology_data.Latitude, climatology_data.Longitude], 'rows');

% Inicializar la columna de anomalías
data.Anomalia = nan(height(data), 1);

% Para las filas donde se encontró coincidencia, calcular la anomalía
data.Anomalia(found) = data.Sos(found) - climatology_data.Sos(idx(found));

% 8. Guardar los resultados en un archivo CSV
output_table = table(data.Time, data.Latitude, data.Longitude, ...
                     data.Sos, data.Anomalia, 'VariableNames', {'Fecha', 'Latitud', 'Longitud', 'Sos', 'Anomalia'});

writetable(output_table, '/Volumes/LLACA/Posdoctorado/Gaby/anomalia_sos_toda_serie.csv');

disp('La climatología mensual de Sos se ha guardado en "climatologia_sos_mensual.mat".');
disp('Las anomalías de Sos para toda la serie se han guardado en "anomalia_sos_toda_serie.csv".');
