% Limpiar el entorno
clc;
clear;
close all;

file_path_2005 = '/Volumes/LLACA/Python/Caribe/sos_caribe.csv';
file_path_2006 = '/Volumes/LLACA/Python/Caribe/sos_2006.csv';

data_2005 = readtable(file_path_2005, 'TextType', 'string');
data_2006 = readtable(file_path_2006, 'TextType', 'string');

%fecha
data_2005.Time = datetime(data_2005.Time, 'InputFormat', 'yyyy-MM-dd');
data_2006.Time = datetime(data_2006.Time, 'InputFormat', 'yyyy-MM-dd');

% Interpolar 
data_2005.Sos = fillmissing(data_2005.Sos, 'linear');
mean_sos_2005 = mean(data_2005.Sos, 'omitnan');
data_2005.Sos(isnan(data_2005.Sos)) = mean_sos_2005;

data_2006.Sos = fillmissing(data_2006.Sos, 'linear');
mean_sos_2006 = mean(data_2006.Sos, 'omitnan');
data_2006.Sos(isnan(data_2006.Sos)) = mean_sos_2006;

october_data_2005 = data_2005(month(data_2005.Time) == 10, :);
october_data_2006 = data_2006(month(data_2006.Time) == 10, :);

% Calcular la anomalía
mean_sos_2005 = mean(october_data_2005.Sos, 'omitnan');
mean_sos_2006 = mean(october_data_2006.Sos, 'omitnan');

october_data_2005.Anomaly = october_data_2005.Sos - mean_sos_2005;
october_data_2006.Anomaly = october_data_2006.Sos - mean_sos_2006;


% Graficar la serie temporal completa de Sos en octubre para ambos años
figure;
hold on;
%plot(october_data_2005.Time, october_data_2005.Sos, 'o-r', 'DisplayName', '2005'); % Cambiado a 'o' para puntos visibles
plot(october_data_2006.Time, october_data_2006.Sos, '*-b', 'DisplayName', '2006'); % Cambiado a '*' para puntos visibles
xlabel('Fecha (Día-Mes)');
ylabel('Salinidad (Sos)');
title('Salinidad Superficial (Sos) en Octubre 2005 y 2006');
legend;
datetick('x', 'dd-mm', 'keepticks');
xlim([datetime(2005, 10, 1), datetime(2005, 10, 31)]);
grid on;
hold off;

% Graficar la anomalía de Sos en octubre para 2005
figure;
hold on;
plot(october_data_2005.Time, october_data_2005.Anomaly, 'r-', 'DisplayName', '2005');
xlabel('Fecha (Día-Mes)');
ylabel('Anomalía de Sos');
title('Anomalía de la Salinidad Superficial (Sos) en Octubre 2005');
legend;
datetick('x', 'dd-mm', 'keepticks');
xlim([datetime(2005, 10, 1), datetime(2005, 10, 31)]);
grid on;
hold off;

% Graficar la anomalía de Sos en octubre para 2006
figure;
hold on;
plot(october_data_2006.Time, october_data_2006.Anomaly, 'b-', 'DisplayName', '2006');
xlabel('Fecha (Día-Mes)');
ylabel('Anomalía de Sos');
title('Anomalía de la Salinidad Superficial (Sos) en Octubre 2006');
legend;
datetick('x', 'dd-mm', 'keepticks');
xlim([datetime(2006, 10, 1), datetime(2006, 10, 31)]);
grid on;
hold off;

% Filtrar datos para el transecto en octubre
transect_data_2005 = october_data_2005(october_data_2005.Longitude >= -87 & october_data_2005.Longitude <= -86.46 & ...
                                       october_data_2005.Latitude >= 18 & october_data_2005.Latitude <= 22, :);

transect_data_2006 = october_data_2006(october_data_2006.Longitude >= -87 & october_data_2006.Longitude <= -86.46 & ...
                                       october_data_2006.Latitude >= 18 & october_data_2006.Latitude <= 22, :);

% Filtrar los días 21 a 23 de octubre en el transecto
filtered_data_transect_2005 = transect_data_2005(transect_data_2005.Time >= datetime(2005, 10, 20) & ...
                                                  transect_data_2005.Time <= datetime(2005, 10, 23), :);

filtered_data_transect_2006 = transect_data_2006(transect_data_2006.Time >= datetime(2006, 10, 20) & ...
                                                  transect_data_2006.Time <= datetime(2006, 10, 23), :);

% Calcular la anomalía para los días 
mean_sos_transect_2005 = mean(filtered_data_transect_2005.Sos, 'omitnan');
mean_sos_transect_2006 = mean(filtered_data_transect_2006.Sos, 'omitnan');

std_dev_2005 = std(filtered_data_transect_2005.Sos, 'omitnan');
std_dev_2006 = std(filtered_data_transect_2006.Sos, 'omitnan');

filtered_data_transect_2005.Anomaly = filtered_data_transect_2005.Sos - mean_sos_transect_2005;
filtered_data_transect_2006.Anomaly = filtered_data_transect_2006.Sos - mean_sos_transect_2006;

% Verificar resultados de transecto
fprintf('Promedio de Sos en el transecto (21-23 octubre 2005): %.2f\n', mean_sos_transect_2005);
fprintf('Desviación estándar en el transecto (21-23 octubre 2005): %.2f\n', std_dev_2005);
fprintf('Promedio de Sos en el transecto (21-23 octubre 2006): %.2f\n', mean_sos_transect_2006);
fprintf('Desviación estándar en el transecto (21-23 octubre 2006): %.2f\n', std_dev_2006);


% Graficar las anomalías del transecto para el 21 al 23 de octubre 2005
figure;
plot(filtered_data_transect_2005.Time, filtered_data_transect_2005.Anomaly, 'r-', 'DisplayName', '2005');
xlabel('Fecha (Día-Mes)');
ylabel('Anomalía de Sos');
title('Anomalía de la Salinidad Superficial (Sos) en el Transecto - 21 a 23 de Octubre 2005');
legend;
datetick('x', 'dd-mm', 'keepticks');
xlim([datetime(2005, 10, 21), datetime(2005, 10, 23)]);
grid on;


% Graficar las anomalías del transecto para el 21 al 23 de octubre 2006
figure;
plot(filtered_data_transect_2006.Time, filtered_data_transect_2006.Anomaly, 'b-', 'DisplayName', '2006');
xlabel('Fecha (Día-Mes)');
ylabel('Anomalía de Sos');
title('Anomalía de la Salinidad Superficial (Sos) en el Transecto - 21 a 23 de Octubre 2006');
legend;
datetick('x', 'dd-mm', 'keepticks');
xlim([datetime(2006, 10, 21), datetime(2006, 10, 23)]);
grid on;
