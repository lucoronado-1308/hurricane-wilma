% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% Asegurarse de que no haya conflicto con 'years' como función
clear years

% Establecer el directorio de trabajo
cd('/Volumes/LLACA/Posdoctorado/Gaby');

%% Parte 1: Graficar la SST en función del tiempo y latitud usando el archivo .mat

% Cargar el archivo climatologia_sst_mensual.mat
load('climatologia_sst_mensual.mat');

% Verificar que los datos se hayan cargado correctamente
disp('Datos de climatología cargados correctamente.');

% Extraer las variables de interés: SST, Tiempo (crearemos una serie temporal) y Latitud
months = climatology_data.Month;
latitudes = climatology_data.Latitude;
sst = climatology_data.SST;

% Verificar el número total de puntos de datos
num_data_points = height(climatology_data); % Número total de puntos de datos

% Crear una serie de años correspondiente a los datos (suponiendo que van de 2003 a 2007)
% Asegurarse de que el número de años coincida con los datos disponibles

% Suponiendo que tenemos 5 años de datos (2003 a 2007), con 12 meses por año
num_years = 5;  % Número de años
years_repeated = repmat(2003:2007, 12, 1); % 5 años, 12 meses cada año
years = years_repeated(:); % Convertir a un vector columna

% Si hay más o menos datos de los esperados, ajustar 'years'
if length(years) > num_data_points
    years = years(1:num_data_points); % Truncar si es necesario
elseif length(years) < num_data_points
    warning('El número de años es menor que el número de puntos de datos. Se ajustará automáticamente.');
    years = repmat(years, ceil(num_data_points / length(years)), 1);
    years = years(1:num_data_points); % Asegurarse de que tenga el tamaño correcto
end

% Crear vector de fechas (tiempo) a partir de los años y meses
time = datetime(years, months, 1);

% Graficar SST en función del tiempo y la latitud con una barra de colores
figure;
scatter3(time, latitudes, sst, 20, sst, 'filled');
colorbar;
xlabel('Tiempo');
ylabel('Latitud');
zlabel('SST (°C)');
title('SST en función del tiempo y la latitud (Climatología)');
datetick('x', 'yyyy', 'keeplimits'); % Formato del eje x para mostrar el año
grid on;

%% Parte 2: Graficar la anomalía de SST para octubre de 2005

% Cargar el archivo anomalia_sst_octubre_2005.csv
anomalia_data = readtable('anomalia_sst_octubre_2005.csv');

% Verificar que los datos se hayan cargado correctamente
disp('Datos de anomalía cargados correctamente.');

% Extraer las variables de interés: Tiempo, Anomalía, Latitud
oct_time = anomalia_data.Fecha;
anomaly = anomalia_data.Anomalia;
oct_latitudes = anomalia_data.Latitud;

% Graficar la anomalía de SST en función del tiempo y la latitud
figure;
scatter3(oct_time, oct_latitudes, anomaly, 20, anomaly, 'filled');
colorbar;
xlabel('Fecha');
ylabel('Latitud');
zlabel('Anomalía SST (°C)');
title('Anomalía de SST para octubre de 2005');
datetick('x', 'dd-mmm', 'keeplimits'); % Formato del eje x para mostrar día y mes
grid on;

