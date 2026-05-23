% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% 1. Cargar el archivo CSV
filename = '/Volumes/LLACA/Posdoctorado/Gaby/chl_2003_2007.csv';
data = readtable(filename);

% 2. Convertir Time a formato datetime usando el formato yyyy/MM/dd
data.Time = datetime(data.Time, 'InputFormat', 'yyyy/MM/dd');

% 3. Reemplazar los valores vacíos de Chl por NaN
data.Chl(ismissing(data.Chl)) = NaN;

% 4. Agregar columnas para el mes y el año
data.Month = month(data.Time);
data.Year = year(data.Time);

% 5. Filtrar y excluir datos de octubre de 2005
oct_2005_idx = (data.Time >= datetime(2005,10,1) & data.Time <= datetime(2005,10,31));
remaining_data = data(~oct_2005_idx, :);

% 6. Calcular la climatología de Chl por mes
% Agrupar los datos por mes, latitud y longitud
climatology_data = varfun(@mean, remaining_data, 'InputVariables', 'Chl', ...
    'GroupingVariables', {'Month', 'Latitude', 'Longitude'}, 'OutputFormat', 'table');

% Reorganizar las columnas y renombrar
climatology_data.Properties.VariableNames{'mean_Chl'} = 'Chl_Climatology';

% 7. Guardar la climatología mensual en un archivo .mat
save('/Volumes/LLACA/Posdoctorado/Gaby/climatologia_chl_mensual.mat', 'climatology_data');

% 8. Extraer los datos para octubre de 2005
oct_2005_data = data(oct_2005_idx, :);

% 9. Calcular la climatología de Chl para octubre (basada en datos de otros años, excepto octubre 2005)
oct_climatology = climatology_data(climatology_data.Month == 10, :);

% 10. Calcular la anomalía de Chl para octubre de 2005
% Usar ismember para evitar bucles
[found, idx] = ismember([oct_2005_data.Latitude, oct_2005_data.Longitude], ...
                        [oct_climatology.Latitude, oct_climatology.Longitude], 'rows');

% Inicializar la columna de anomalías
anomaly = nan(height(oct_2005_data), 1);

% Para las filas donde se encontró coincidencia, calcular la anomalía
anomaly(found) = oct_2005_data.Chl(found) - oct_climatology.Chl_Climatology(idx(found));

% 11. Guardar los resultados en un archivo CSV
output_table = table(oct_2005_data.Time, oct_2005_data.Latitude, oct_2005_data.Longitude, ...
                     oct_2005_data.Chl, anomaly, 'VariableNames', {'Fecha', 'Latitud', 'Longitud', 'Chl', 'Anomalia'});

writetable(output_table, '/Volumes/LLACA/Posdoctorado/Gaby/anomalia_chl_octubre_2005.csv');

disp('La climatología mensual se ha guardado en "climatologia_mensual.mat".');
disp('Las anomalías de Chl para octubre de 2005 se han guardado en "anomalia_octubre_2005.csv".');
