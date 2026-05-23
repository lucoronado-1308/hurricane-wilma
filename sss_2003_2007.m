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

% 4. Filtrar datos excluyendo octubre de 2005
oct_2005_idx = (data.Time >= datetime(2005,10,1) & data.Time <= datetime(2005,10,31));
remaining_data = data(~oct_2005_idx, :);

% 5. Agregar columna de mes y año para cálculos posteriores
remaining_data.Month = month(remaining_data.Time);
remaining_data.Year = year(remaining_data.Time);

% 6. Calcular la climatología de Sos por mes, latitud y longitud
climatology_data = varfun(@mean, remaining_data, 'InputVariables', 'Sos', ...
    'GroupingVariables', {'Month', 'Latitude', 'Longitude'}, 'OutputFormat', 'table');

% Renombrar columna resultante de la climatología
climatology_data.Properties.VariableNames{'mean_Sos'} = 'Sos';

% 7. Guardar la climatología mensual en un archivo .mat
save('/Volumes/LLACA/Posdoctorado/Gaby/climatologia_sos_mensual.mat', 'climatology_data');

% 8. Extraer los datos para octubre de 2005
oct_2005_data = data(oct_2005_idx, :);

% 9. Calcular la climatología de Sos para octubre (basada en datos 2003-2007, excepto octubre 2005)
oct_climatology = climatology_data(climatology_data.Month == 10, :);

% 10. Calcular la anomalía de Sos para octubre de 2005
% Usar ismember para evitar bucles
[found, idx] = ismember([oct_2005_data.Latitude, oct_2005_data.Longitude], ...
                        [oct_climatology.Latitude, oct_climatology.Longitude], 'rows');

% Inicializar la columna de anomalías
anomaly = nan(height(oct_2005_data), 1);

% Para las filas donde se encontró coincidencia, calcular la anomalía
anomaly(found) = oct_2005_data.Sos(found) - oct_climatology.Sos(idx(found));

% 11. Guardar los resultados en un archivo CSV
output_table = table(oct_2005_data.Time, oct_2005_data.Latitude, oct_2005_data.Longitude, ...
                     oct_2005_data.Sos, anomaly, 'VariableNames', {'Fecha', 'Latitud', 'Longitud', 'Sos', 'Anomalia'});

writetable(output_table, '/Volumes/LLACA/Posdoctorado/Gaby/anomalia_sos_octubre_2005.csv');

disp('La climatología mensual de Sos se ha guardado en "climatologia_sos_mensual.mat".');
disp('Las anomalías de Sos para octubre de 2005 se han guardado en "anomalia_sos_octubre_2005.csv".');
