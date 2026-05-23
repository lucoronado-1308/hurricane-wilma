% Limpiar el entorno
clc;
clear;
close all;

% Definir el directorio de los archivos y los archivos a leer
file_path_adt = '/Volumes/LLACA/Python/Caribe/adt_caribe.csv';
file_path_sos = '/Volumes/LLACA/Python/Caribe/sos_2003_2007.csv';
file_path_sst = '/Volumes/LLACA/Python/Caribe/sst_2003_2007.csv';

% Leer los archivos CSV
data_adt = readtable(file_path_adt, 'TextType', 'string');
data_sos = readtable(file_path_sos, 'TextType', 'string');
data_sst = readtable(file_path_sst, 'TextType', 'string');

% Convertir la columna de tiempo a formato datetime
data_adt.Time = datetime(data_adt.Time, 'InputFormat', 'yyyy-MM-dd');
data_sos.Time = datetime(data_sos.Time, 'InputFormat', 'yyyy-MM-dd');
data_sst.Time = datetime(data_sst.Time, 'InputFormat', 'yyyy-MM-dd');

% Rellenar valores faltantes con el promedio de los valores más cercanos
data_adt.Adt = fillmissing(data_adt.ADT, 'linear');
data_adt.Adt(isnan(data_adt.ADT)) = mean(data_adt.ADT, 'omitnan');

data_sos.Sos = fillmissing(data_sos.Sos, 'linear');
data_sos.Sos(isnan(data_sos.Sos)) = mean(data_sos.Sos, 'omitnan');

data_sst.Sst = fillmissing(data_sst.SST, 'linear');
data_sst.Sst(isnan(data_sst.SST)) = mean(data_sst.SST, 'omitnan');

% Convertir SST de Kelvin a Celsius
data_sst.Sst = data_sst.Sst - 273.15;

% 1. Cálculo de Anomalías Temporales Mensuales
% Calcular la media mensual para cada año de 2003 a 2007
monthly_mean_adt = zeros(5,1);
monthly_mean_sos = zeros(5,1);
monthly_mean_sst = zeros(5,1);

for year = 2003:2007
    monthly_mean_adt(year-2002,1) = mean(data_adt(data_adt.Time.Year == year & month(data_adt.Time) == 10, :).ADT, 'omitnan');
    monthly_mean_sos(year-2002,1) = mean(data_sos(data_sos.Time.Year == year & month(data_sos.Time) == 10, :).Sos, 'omitnan');
    monthly_mean_sst(year-2002,1) = mean(data_sst(data_sst.Time.Year == year & month(data_sst.Time) == 10, :).SST, 'omitnan');
end

% Cálculo de anomalías en octubre de cada año
anomaly_adt = data_adt.ADT - mean(monthly_mean_adt);
anomaly_sos = data_sos.Sos - mean(monthly_mean_sos);
anomaly_sst = data_sst.SST - mean(monthly_mean_sst);

% Visualización de anomalías mensuales
figure;
subplot(3,1,1);
plot(data_adt.Time, anomaly_adt, 'r');
title('Anomalía de ADT de 2003 a 2007');
ylabel('Anomalía ADT');
xlabel('Año');

subplot(3,1,2);
plot(data_sos.Time, anomaly_sos, 'b');
title('Anomalía de SOS de 2003 a 2007');
ylabel('Anomalía SOS');
xlabel('Año');

subplot(3,1,3);
plot(data_sst.Time, anomaly_sst, 'g');
title('Anomalía de SST de 2003 a 2007');
ylabel('Anomalía SST (°C)');
xlabel('Año');

% Añadir un recuadro rojo para el periodo del 14 al 19 de octubre
%annotation('rectangle', [0.2, 0.3, 0.3, 0.3], 'EdgeColor', 'r', 'LineWidth', 1.5);

% 2. Análisis Espacial de Anomalías en el Área de Estudio
% Filtrar el área geográfica y graficar mapas de calor
area_filter = @(data) data(data.Longitude >= -87 & data.Longitude <= -86.46 & ...
                           data.Latitude >= 18 & data.Latitude <= 22, :);

data_adt_area = area_filter(data_adt);
data_sos_area = area_filter(data_sos);
data_sst_area = area_filter(data_sst);

% Visualización de las anomalías espaciales
figure;
subplot(3,1,1);
scatter(data_adt_area.Longitude, data_adt_area.Latitude, 20, data_adt_area.ADT, 'filled');
colorbar;
title('Anomalía Espacial de ADT');
xlabel('Longitud');
ylabel('Latitud');

subplot(3,1,2);
scatter(data_sos_area.Longitude, data_sos_area.Latitude, 20, data_sos_area.Sos, 'filled');
colorbar;
title('Anomalía Espacial de SOS');
xlabel('Longitud');
ylabel('Latitud');

subplot(3,1,3);
scatter(data_sst_area.Longitude, data_sst_area.Latitude, 20, data_sst_area.Sst, 'filled');
colorbar;
title('Anomalía Espacial de SST (°C)');
xlabel('Longitud');
ylabel('Latitud');

% 3. Análisis de Tendencias Temporales y Cambios Estacionales
% Serie temporal para cambios estacionales
figure;
subplot(3,1,1);
plot(data_adt.Time, data_adt.ADT, 'r');
title('Serie Temporal de ADT');
xlabel('Año');
ylabel('ADT');

subplot(3,1,2);
plot(data_sos.Time, data_sos.Sos, 'b');
title('Serie Temporal de SOS');
xlabel('Año');
ylabel('SOS');

subplot(3,1,3);
plot(data_sst.Time, data_sst.Sst, 'g');
title('Serie Temporal de SST (°C)');
xlabel('Año');
ylabel('SST (°C)');

% 4. Análisis Estadístico de Cambios Significativos
% Bayesian t-test para comparar datos de octubre de 2005 con años anteriores
disp('Prueba de cambio significativo utilizando test bayesiano:');
% Ejemplo simplificado de comparación bayesiana


% Asegúrate de que no haya variable llamada 'day'
clear day; 

% 4. Análisis Estadístico de Cambios Significativos
% Comparar los días del paso de Wilma (14 al 19 de octubre) con años anteriores
wilma_dates = datetime(2005,10,14):datetime(2005,10,19);
% Obtener datos de otros años para las mismas fechas
other_years_data = [];

% Calcular los días del año para las fechas de Wilma
wilma_day_of_year = day(wilma_dates, 'dayofyear');

for year = years'
    if year ~= 2005
        for day_of_year = wilma_day_of_year
            % Filtrar datos para otros años
            other_year_data = data_sst(data_sst.Time.Year == year & ...
                day(data_sst.Time, 'dayofyear') == day_of_year, :);
            other_years_data = [other_years_data; other_year_data]; % Almacenar los datos
        end
    end
end

% Preparar datos para el análisis
wilma_data = data_sst(data_sst.Time >= datetime(2005,10,14) & ...
                       data_sst.Time <= datetime(2005,10,19), :).Sst;
other_years_sst = other_years_data.Sst;

% Prueba T de diferencias
[h, p] = ttest2(wilma_data, other_years_sst, 'Vartype', 'unequal');
disp(['P-valor de la prueba T: ', num2str(p)]);

% Intervalos de Credibilidad
credibility_interval_wilma = prctile(wilma_data, [2.5 97.5]);
credibility_interval_other = prctile(other_years_sst, [2.5 97.5]);

disp(['Intervalo de credibilidad para los días de Wilma: [', ...
    num2str(credibility_interval_wilma(1)), ', ', ...
    num2str(credibility_interval_wilma(2)), ']']);
disp(['Intervalo de credibilidad para otros años: [', ...
    num2str(credibility_interval_other(1)), ', ', ...
    num2str(credibility_interval_other(2)), ']']);






% Filtrar los datos de otros años (excluir del 14 al 19 de octubre de 2005)
other_years_data = data_sst(data_sst.Time < datetime(2005, 10, 14) | ...
                             data_sst.Time > datetime(2005, 10, 19), :);

% Contar los datos válidos en Wilma
wilma_data = data_sst(data_sst.Time >= datetime(2005, 10, 14) & ...
                      data_sst.Time <= datetime(2005, 10, 19), :);
num_wilma_data = sum(~isnan(wilma_data.Sst));  % Contar valores no NaN en Wilma

% Contar los datos válidos en otros años
num_other_years_data = sum(~isnan(other_years_data.Sst));  % Contar valores no NaN en otros años

disp(['Número de datos válidos en Wilma: ', num2str(num_wilma_data)]);
disp(['Número de datos válidos en otros años: ', num2str(num_other_years_data)]);
if num_wilma_data > 0 && num_other_years_data > 0
    % Realizar la prueba T
    [h, p] = ttest2(wilma_data.Sst, other_years_data.Sst, 'Vartype', 'unequal');
    disp(['Resultado de la prueba T: h = ', num2str(h), ', p = ', num2str(p)]);
else
    disp('No hay suficientes datos para realizar la prueba T.');
end

if num_wilma_data > 0 && num_other_years_data > 0
    % Realizar la prueba T
    [h, p] = ttest2(wilma_data.Sst, other_years_data.Sst, 'Vartype', 'unequal');
    disp(['Resultado de la prueba T: h = ', num2str(h), ', p = ', num2str(p)]);
else
    disp('No hay suficientes datos para realizar la prueba T.');
end


% Convertir SST de Kelvin a Celsius
data_sst.Sst = data_sst.Sst - 273.15;
% Definir años para el análisis
years = [2003, 2004, 2006, 2007];

% Inicializar estructuras para guardar los intervalos de credibilidad
credibility_intervals = struct();

% Calcular intervalos de credibilidad para cada variable
variables = {'Adt', 'Sos', 'Sst'};
for var = variables
    var_name = var{1};
    
    % Datos de octubre para cada año
    october_data = [];
    for year = years
        monthly_data = data_adt(data_adt.Time.Year == year & month(data_adt.Time) == 10, :);
        if strcmp(var_name, 'Adt')
            october_data = [october_data; monthly_data.ADT];
        elseif strcmp(var_name, 'Sos')
            monthly_data = data_sos(data_sos.Time.Year == year & month(data_sos.Time) == 10, :);
            october_data = [october_data; monthly_data.Sos];
        elseif strcmp(var_name, 'Sst')
            monthly_data = data_sst(data_sst.Time.Year == year & month(data_sst.Time) == 10, :);
            october_data = [october_data; monthly_data.SST];
        end
    end

    % Calcular el intervalo de credibilidad (95%)
    credibility_intervals.(var_name) = prctile(october_data, [2.5, 97.5]);
    
    % Mostrar resultados
    disp(['Intervalo de credibilidad para ', var_name, ' en octubre de 2003, 2004, 2006 y 2007: [', ...
        num2str(credibility_intervals.(var_name)(1)), ', ', ...
        num2str(credibility_intervals.(var_name)(2)), ']']);
end

% Intervalos de Credibilidad durante el evento de Wilma (14 al 19 de octubre de 2005)
wilma_dates = datetime(2005, 10, 14):datetime(2005, 10, 19);
wilma_intervals = struct();

for var = variables
    var_name = var{1};
    
    % Obtener datos de Wilma
    if strcmp(var_name, 'Adt')
        wilma_data = data_adt(data_adt.Time >= wilma_dates(1) & data_adt.Time <= wilma_dates(end), :).ADT;
    elseif strcmp(var_name, 'Sos')
        wilma_data = data_sos(data_sos.Time >= wilma_dates(1) & data_sos.Time <= wilma_dates(end), :).Sos;
    elseif strcmp(var_name, 'Sst')
        wilma_data = data_sst(data_sst.Time >= wilma_dates(1) & data_sst.Time <= wilma_dates(end), :).SST;
    end
    
    % Calcular el intervalo de credibilidad (95%)
    wilma_intervals.(var_name) = prctile(wilma_data, [2.5, 97.5]);
    
    % Mostrar resultados
    disp(['Intervalo de credibilidad para ', var_name, ' durante Wilma: [', ...
        num2str(wilma_intervals.(var_name)(1)), ', ', ...
        num2str(wilma_intervals.(var_name)(2)), ']']);
end




























% Filtrar los datos entre el 14 y el 19 de octubre de 2005
wilma_period = data_adt.Time >= datetime(2005,10,14) & data_adt.Time <= datetime(2005,10,19);
time_wilma = data_adt.Time(wilma_period); % Tiempo para los días de Wilma

% Extraer los datos de ADT, SOS, y SST durante el evento de Wilma
adt_wilma = data_adt.ADT(wilma_period);
sos_wilma = data_sos.Sos(wilma_period);
sst_wilma = data_sst.Sst(wilma_period);

% Crear la figura con subplots
figure;
tiledlayout(3, 1); % Crear un layout con tres filas y una columna

% Primer subplot para ADT
nexttile;
plot(time_wilma, adt_wilma, '-or', 'LineWidth', 1.5);
title('Anomalía de Altura Dinámica (ADT) durante el paso de Wilma');
ylabel('ADT (m)');
xlabel('Fecha');
grid on;

% Segundo subplot para SOS
nexttile;
plot(time_wilma, sos_wilma, '-ob', 'LineWidth', 1.5);
title('Anomalía de Salinidad Superficial (SOS) durante el paso de Wilma');
ylabel('SOS');
xlabel('Fecha');
grid on;

% Tercer subplot para SST
nexttile;
plot(time_wilma, sst_wilma, '-og', 'LineWidth', 1.5);
title('Anomalía de Temperatura Superficial del Mar (SST) durante el paso de Wilma');
ylabel('SST (°C)');
xlabel('Fecha');
grid on;

% Mejorar la visualización
sgtitle('Variación de ADT, SOS y SST durante el paso del huracán Wilma');


% Filtrar los datos entre el 14 y el 19 de octubre de 2005
wilma_period = (data_adt.Time >= datetime(2005,10,14) & data_adt.Time <= datetime(2005,10,19));

% Extraer los datos de latitud y anomalías de ADT, SOS y SST durante el evento de Wilma
lat_wilma = data_adt.Latitude(wilma_period); % Latitud para los días de Wilma
anomaly_adt_wilma = anomaly_adt(wilma_period); % Anomalía de ADT
anomaly_sos_wilma = anomaly_sos(wilma_period); % Anomalía de SOS
anomaly_sst_wilma = anomaly_sst(wilma_period); % Anomalía de SST

% Crear la figura con subplots para cada anomalía en función de la latitud
figure;
tiledlayout(3, 1); % Crear un layout con tres filas y una columna

% Primer subplot para Anomalía de ADT vs Latitud
nexttile;
plot(lat_wilma, anomaly_adt_wilma, 'or', 'LineWidth', 1.5);
title('Anomalía de ADT vs Latitud durante el paso de Wilma');
ylabel('Anomalía ADT (m)');
xlabel('Latitud');
grid on;

% Segundo subplot para Anomalía de SOS vs Latitud
nexttile;
plot(lat_wilma, anomaly_sos_wilma, 'ob', 'LineWidth', 1.5);
title('Anomalía de SOS vs Latitud durante el paso de Wilma');
ylabel('Anomalía SOS');
xlabel('Latitud');
grid on;

% Tercer subplot para Anomalía de SST vs Latitud
nexttile;
plot(lat_wilma, anomaly_sst_wilma, 'og', 'LineWidth', 1.5);
title('Anomalía de SST vs Latitud durante el paso de Wilma');
ylabel('Anomalía SST (°C)');
xlabel('Latitud');
grid on;

% Mejorar la visualización
sgtitle('Variación de Anomalías de ADT, SOS y SST en función de la Latitud durante el paso del huracán Wilma');



















