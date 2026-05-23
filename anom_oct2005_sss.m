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

% 6. Filtrar los datos para octubre de 2005 (mes 10, año 2005)
october_2005_data = data(data.Month == 10 & data.Year == 2005, :);

% 7. Calcular las anomalías de Sos para octubre de 2005
% Usar ismember para hacer coincidir coordenadas y mes entre los datos de octubre y la climatología
[found, idx] = ismember([october_2005_data.Month, october_2005_data.Latitude, october_2005_data.Longitude], ...
                        [climatology_data.Month, climatology_data.Latitude, climatology_data.Longitude], 'rows');

% Inicializar la columna de anomalías para octubre de 2005
october_2005_data.Anomalia = nan(height(october_2005_data), 1);

% Para las filas donde se encontró coincidencia, calcular la anomalía
october_2005_data.Anomalia(found) = october_2005_data.Sos(found) - climatology_data.Sos(idx(found));

% 8. Guardar los resultados de octubre de 2005 en un archivo CSV
output_table_october = table(october_2005_data.Time, october_2005_data.Latitude, october_2005_data.Longitude, ...
                              october_2005_data.Sos, october_2005_data.Anomalia, ...
                              'VariableNames', {'Fecha', 'Latitud', 'Longitud', 'Sos', 'Anomalia'});

writetable(output_table_october, '/Volumes/LLACA/Posdoctorado/Gaby/anomalia_sss_octubre_2005.csv');

disp('Las anomalías de Sos para octubre de 2005 se han guardado en "anomalia_sss_octubre_2005.csv".');
