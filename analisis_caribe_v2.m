% Limpiar el entorno
clc;
clear;
close all;

% directorio 
file_path_adt = '/Volumes/LLACA/Python/Caribe/adt_caribe.csv';
file_path_sos = '/Volumes/LLACA/Python/Caribe/sos_2003_2007.csv';
file_path_sst = '/Volumes/LLACA/Python/Caribe/sst_2003_2007.csv';

% Leer los archivos
data_adt = readtable(file_path_adt, 'TextType', 'string');
data_sos = readtable(file_path_sos, 'TextType', 'string');
data_sst = readtable(file_path_sst, 'TextType', 'string');

% Convertir  a formato datetime
data_adt.Time = datetime(data_adt.Time, 'InputFormat', 'yyyy-MM-dd');
data_sos.Time = datetime(data_sos.Time, 'InputFormat', 'yyyy-MM-dd');
data_sst.Time = datetime(data_sst.Time, 'InputFormat', 'yyyy-MM-dd');

% Sustituir con promedio más cercano
data_adt.Adt = fillmissing(data_adt.ADT, 'linear');
data_adt.Adt(isnan(data_adt.ADT)) = mean(data_adt.ADT, 'omitnan');

data_sos.Sos = fillmissing(data_sos.Sos, 'linear');
data_sos.Sos(isnan(data_sos.Sos)) = mean(data_sos.Sos, 'omitnan');

data_sst.Sst = fillmissing(data_sst.SST, 'linear');
data_sst.Sst(isnan(data_sst.SST)) = mean(data_sst.SST, 'omitnan');

% Convertir SST de Kelvin a Celsius, así están en el producto L4
data_sst.Sst = data_sst.Sst - 273.15; 

% 1. Calcular la media mensual de todo el year - del 2003 al 2007 
monthly_mean_adt = zeros(5,1);
monthly_mean_sos = zeros(5,1);
monthly_mean_sst = zeros(5,1);

for year = 2003:2007
    monthly_mean_adt(year-2002,1) = mean(data_adt(data_adt.Time.Year == year & month(data_adt.Time) == 10, :).ADT, 'omitnan');
    monthly_mean_sos(year-2002,1) = mean(data_sos(data_sos.Time.Year == year & month(data_sos.Time) == 10, :).Sos, 'omitnan');
    monthly_mean_sst(year-2002,1) = mean(data_sst(data_sst.Time.Year == year & month(data_sst.Time) == 10, :).Sst, 'omitnan'); % Cambiar a Sst
end

% Cálculo de anomalías en octubre de cada año
anomaly_adt = data_adt.ADT - mean(monthly_mean_adt);
anomaly_sos = data_sos.Sos - mean(monthly_mean_sos);
anomaly_sst = data_sst.Sst - mean(monthly_mean_sst); 

% Figura -hay que cambiar colores -proof
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

%  
% Comparar los días del paso de Wilma con años anteriores
wilma_dates = datetime(2005,10,15):datetime(2005,10,25);
% Obtener datos de otros años para las mismas fechas
other_years_data = [];

% Calcular los días del año para las fechas de Wilma
wilma_day_of_year = day(wilma_dates, 'dayofyear');

% Definir años para el análisis excluyendo 2005
years = [2003, 2004, 2006, 2007];

for year = years
    for day_of_year = wilma_day_of_year
        % Filtrar datos para otros años
        other_year_data = data_sst(data_sst.Time.Year == year & ...
            day(data_sst.Time, 'dayofyear') == day_of_year, :);
        other_years_data = [other_years_data; other_year_data]; % Almacenar los datos
    end
end

% 
wilma_data = data_sst(data_sst.Time >= datetime(2005,10,15) & ...
                       data_sst.Time <= datetime(2005,10,25), :).Sst;
other_years_sst = other_years_data.Sst;

% Contar los datos válidos--- esto porque no filtraba bien-- se resolvió
num_wilma_data = sum(~isnan(wilma_data));  
num_other_years_data = sum(~isnan(other_years_sst)); 

if num_wilma_data > 0 && num_other_years_data > 0
    % Realizar la prueba T
    [h, p] = ttest2(wilma_data, other_years_sst, 'Vartype', 'unequal');
    disp(['Resultado de la prueba T: h = ', num2str(h), ', p = ', num2str(p)]);
else
    disp('No hay suficientes datos para realizar la prueba T.');
end

% Cálculo de IC 
credibility_intervals = struct();
for var = {'Adt', 'Sos', 'Sst'}
    var_name = var{1};
    october_data = [];

    for year = years
        if strcmp(var_name, 'Adt')
            monthly_data = data_adt(data_adt.Time.Year == year & month(data_adt.Time) == 10, :);
            october_data = [october_data; monthly_data.ADT];
        elseif strcmp(var_name, 'Sos')
            monthly_data = data_sos(data_sos.Time.Year == year & month(data_sos.Time) == 10, :);
            october_data = [october_data; monthly_data.Sos];
        elseif strcmp(var_name, 'Sst')
            monthly_data = data_sst(data_sst.Time.Year == year & month(data_sst.Time) == 10, :);
            october_data = [october_data; monthly_data.Sst]; % Cambiar a Sst
        end
    end

    % Calcular IC(95%)
    credibility_intervals.(var_name) = prctile(october_data, [2.5, 97.5]);
    disp(['Intervalo de credibilidad para ', var_name, ': [', ...
        num2str(credibility_intervals.(var_name)(1)), ', ', ...
        num2str(credibility_intervals.(var_name)(2)), ']']);
end


% Filtrar  octubre de 2005 --modifiqué 15 al 25 de octubre de 2005
wilma_period = data_adt.Time >= datetime(2005,10,15) & data_adt.Time <= datetime(2005,10,25);
time_wilma = data_adt.Time(wilma_period); % Tiempo para los días de Wilma

% Extraer los datos de ADT, SOS, y SST durante el evento de Wilma
adt_wilma = data_adt.ADT(wilma_period);
sos_wilma = data_sos.Sos(wilma_period);
sst_wilma = data_sst.Sst(wilma_period);


% Figura
figure;
tiledlayout(3, 1); % 

%  ADT
nexttile;
plot(time_wilma, adt_wilma, 'or', 'LineWidth', 1.5);
%title('(ADT) durante el paso de Wilma');
ylabel('ADT (m)');
xlabel('Fecha');
grid on;

% SOS
nexttile;
plot(time_wilma, sos_wilma, 'ob', 'LineWidth', 1.5);
ylabel('SOS');
xlabel('Fecha');
grid on;

% SST
nexttile;
plot(time_wilma, sst_wilma, 'og', 'LineWidth', 1.5);
ylabel('SST (°)'); %modificar a Celsius, verificar!
xlabel('Fecha');
grid on;



%REPETI FILTRADO PORQUE ME PRODUJO ERROR (NO SUPE POR QUE)
% 
wilma_period = (data_adt.Time >= datetime(2005,10,14) & data_adt.Time <= datetime(2005,10,19));

% Extraer los datos de Latitud, ADT, SOS y SST durante el evento de Wilma
lat_wilma = data_adt.Latitude(wilma_period); % Latitud para los días de Wilma
adt_wilma = data_adt.ADT(wilma_period);
sos_wilma = data_sos.Sos(wilma_period);
sst_wilma = data_sst.Sst(wilma_period);

% Crear subplots función de la latitud
figure;
tiledlayout(3, 1); % 

% ADT vs Latitud
nexttile;
plot(lat_wilma, adt_wilma, 'or', 'LineWidth', 1.5);
%title(' ADT vs Latitud durante el paso de Wilma');
ylabel('ADT (m)');
xlabel('Latitud');
grid on;

% SOS vs Latitud
nexttile;
plot(lat_wilma, sos_wilma, 'ob', 'LineWidth', 1.5);
ylabel('SOS');
xlabel('Latitud');
grid on;

% SST vs Latitud
nexttile;
plot(lat_wilma, sst_wilma, 'og', 'LineWidth', 1.5);
ylabel('SST (°)');
xlabel('Latitud');
grid on;


%OTRA VEZ AQUI...
% Filtrar los datos entre el 14 y el 19 de octubre de 2005
wilma_period = (data_adt.Time >= datetime(2005,10,14) & data_adt.Time <= datetime(2005,10,19));

% Extraer los datos de latitud y anomalías de ADT, SOS y SST durante el evento de Wilma
lat_wilma = data_adt.Latitude(wilma_period); 
anomaly_adt_wilma = anomaly_adt(wilma_period); 
anomaly_sos_wilma = anomaly_sos(wilma_period); 
anomaly_sst_wilma = anomaly_sst(wilma_period); 

% subplots para cada anomalía en función de la latitud
figure;
tiledlayout(3, 1); 

% Anomalía de ADT vs Latitud
nexttile;
plot(lat_wilma, anomaly_adt_wilma, 'or', 'LineWidth', 1.5);
title('Anomalía de ADT vs Latitud durante el paso de Wilma');
ylabel('Anomalía ADT (m)');
xlabel('Latitud');
grid on;

% Anomalía de SOS vs Latitud
nexttile;
plot(lat_wilma, anomaly_sos_wilma, 'ob', 'LineWidth', 1.5);
title('Anomalía de SOS vs Latitud durante el paso de Wilma');
ylabel('Anomalía SOS');
xlabel('Latitud');
grid on;

% Anomalía de SST vs Latitud
nexttile;
plot(lat_wilma, anomaly_sst_wilma, 'og', 'LineWidth', 1.5);
title('Anomalía de SST vs Latitud durante el paso de Wilma');
ylabel('Anomalía SST (°)');
xlabel('Latitud');
grid on;


%REPETI PORQUE NO ME SALIA
% Filtrar los datos entre el 14 y el 19 de octubre de 2005
wilma_period = (data_adt.Time >= datetime(2005,10,14) & data_adt.Time <= datetime(2005,10,19));

% Extraer los datos de latitud y anomalías de ADT, SOS y SST durante el evento de Wilma
lat_wilma = data_adt.Latitude(wilma_period); % Latitud para los días de Wilma
anomaly_adt_wilma = anomaly_adt(wilma_period); 
anomaly_sos_wilma = anomaly_sos(wilma_period); 
anomaly_sst_wilma = anomaly_sst(wilma_period); 

% Subplots 
figure;
tiledlayout(3, 1); 

% 
nexttile;
plot(lat_wilma, anomaly_adt_wilma, 'or', 'LineWidth', 1.5);
ylabel('Anomalía ADT (m)');
xlabel('Latitud');
grid on;

% 
nexttile;
plot(lat_wilma, anomaly_sos_wilma, 'ob', 'LineWidth', 1.5);
ylabel('Anomalía SOS');
xlabel('Latitud');
grid on;

% 
nexttile;
plot(lat_wilma, anomaly_sst_wilma, 'og', 'LineWidth', 1.5);
ylabel('Anomalía SST (°C)');
xlabel('Latitud');
grid on;

