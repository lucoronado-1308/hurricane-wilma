% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% Asegurarse de que no haya conflicto con 'years' como función
clear years

% Establecer el directorio de trabajo
cd('/Volumes/LLACA/Posdoctorado/Gaby');

%% Cargar el archivo climatologia_sst_mensual.mat
load('climatologia_sst_mensual.mat');

% Verificar que los datos se hayan cargado correctamente
disp('Datos de climatología cargados correctamente.');

% Extraer las variables de interés: SST, Latitud, Mes y Año
months = climatology_data.Month;
latitudes = climatology_data.Latitude;
sst = climatology_data.SST;

% Suponiendo que los datos cubren de 2003 a 2007
num_years = 5;  % Número de años
years_repeated = repmat(2003:2007, 12, 1); % 5 años, 12 meses cada año
years = years_repeated(:); % Convertir a un vector columna

% Ajustar el número de años si hay más o menos datos de los esperados
num_data_points = height(climatology_data); % Número total de puntos de datos
if length(years) > num_data_points
    years = years(1:num_data_points); % Truncar si es necesario
elseif length(years) < num_data_points
    warning('El número de años es menor que el número de puntos de datos. Se ajustará automáticamente.');
    years = repmat(years, ceil(num_data_points / length(years)), 1);
    years = years(1:num_data_points); % Asegurarse de que tenga el tamaño correcto
end

% Crear un vector de tiempo (año-mes) para el eje x
time = datetime(years, months, 1);

% Crear una matriz para el diagrama Hovmöller
% Queremos que el eje X sea tiempo (años), el eje Y sea latitud y el color sea SST
unique_latitudes = unique(latitudes);
unique_time = unique(time);

% Inicializar una matriz para almacenar los valores de SST
hovmoller_matrix = nan(length(unique_latitudes), length(unique_time));

% Llenar la matriz Hovmöller con los valores de SST
for i = 1:length(unique_latitudes)
    for j = 1:length(unique_time)
        % Encontrar los datos correspondientes a esta latitud y tiempo
        idx = (latitudes == unique_latitudes(i)) & (time == unique_time(j));
        if any(idx)
            hovmoller_matrix(i, j) = mean(sst(idx)); % Promedio de SST si hay varios puntos
        end
    end
end

% Graficar el diagrama de Hovmöller
figure;
imagesc(unique_time, unique_latitudes, hovmoller_matrix);
set(gca, 'YDir', 'normal'); % Para que las latitudes menores estén abajo
colorbar;
xlabel('Tiempo (Años)');
ylabel('Latitud');
title('Diagrama de Hovmöller de SST (Climatología)');
datetick('x', 'yyyy', 'keeplimits'); % Mostrar el tiempo en formato de años
colormap jet; % Aplicar un mapa de colores
caxis([min(hovmoller_matrix(:)), max(hovmoller_matrix(:))]); % Ajustar los límites del color según los datos





























% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% Asegurarse de que no haya conflicto con 'years' como función
clear years

% Establecer el directorio de trabajo
cd('/Volumes/LLACA/Posdoctorado/Gaby');

%% Cargar el archivo climatologia_sst_mensual.mat
load('climatologia_sst_mensual.mat');

% Verificar que los datos se hayan cargado correctamente
disp('Datos de climatología cargados correctamente.');

% Extraer las variables de interés: SST, Latitud, Mes y Año
months = climatology_data.Month;
latitudes = climatology_data.Latitude;
sst = climatology_data.SST;

% Suponiendo que los datos cubren de 2003 a 2007
num_years = 5;  % Número de años
years_repeated = repmat(2003:2007, 12, 1); % 5 años, 12 meses cada año
years = years_repeated(:); % Convertir a un vector columna

% Ajustar el número de años si hay más o menos datos de los esperados
num_data_points = height(climatology_data); % Número total de puntos de datos
if length(years) > num_data_points
    years = years(1:num_data_points); % Truncar si es necesario
elseif length(years) < num_data_points
    warning('El número de años es menor que el número de puntos de datos. Se ajustará automáticamente.');
    years = repmat(years, ceil(num_data_points / length(years)), 1);
    years = years(1:num_data_points); % Asegurarse de que tenga el tamaño correcto
end

% Crear un vector de tiempo (año-mes) para el eje x
time = datetime(years, months, 1);

% Crear una matriz para el diagrama Hovmöller
% Queremos que el eje X sea tiempo (años), el eje Y sea SST y el eje Z sea latitud
unique_latitudes = unique(latitudes);
unique_time = unique(time);

% Inicializar una matriz para almacenar los valores de SST
hovmoller_matrix = nan(length(unique_latitudes), length(unique_time));

% Llenar la matriz Hovmöller con los valores de SST
for i = 1:length(unique_latitudes)
    for j = 1:length(unique_time)
        % Encontrar los datos correspondientes a esta latitud y tiempo
        idx = (latitudes == unique_latitudes(i)) & (time == unique_time(j));
        if any(idx)
            hovmoller_matrix(i, j) = mean(sst(idx)); % Promedio de SST si hay varios puntos
        end
    end
end

% Graficar el diagrama de Hovmöller
figure;
imagesc(unique_time, unique_latitudes, hovmoller_matrix); % Eje X = tiempo, Y = latitud, colores = SST
set(gca, 'YDir', 'normal'); % Para que las latitudes menores estén abajo
colorbar;
xlabel('Tiempo (Años)');
ylabel('SST (°C)');
title('Diagrama de Hovmöller de SST vs Tiempo y Latitud');
datetick('x', 'yyyy', 'keeplimits'); % Mostrar el tiempo en formato de años
colormap jet; % Aplicar un mapa de colores
caxis([min(hovmoller_matrix(:)), max(hovmoller_matrix(:))]); % Ajustar los límites del color según los datos






























% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% Asegurarse de que no haya conflicto con 'years' como función
clear years

% Establecer el directorio de trabajo
cd('/Volumes/LLACA/Posdoctorado/Gaby');

%% Cargar el archivo climatologia_sst_mensual.mat
load('climatologia_sst_mensual.mat');

% Verificar que los datos se hayan cargado correctamente
disp('Datos de climatología cargados correctamente.');

% Extraer las variables de interés: SST, Latitud, Mes y Año
months = climatology_data.Month;
latitudes = climatology_data.Latitude;
sst = climatology_data.SST;

% Suponiendo que los datos cubren de 2003 a 2007
num_years = 5;  % Número de años
years_repeated = repmat(2003:2007, 12, 1); % 5 años, 12 meses cada año
years = years_repeated(:); % Convertir a un vector columna

% Ajustar el número de años si hay más o menos datos de los esperados
num_data_points = height(climatology_data); % Número total de puntos de datos
if length(years) > num_data_points
    years = years(1:num_data_points); % Truncar si es necesario
elseif length(years) < num_data_points
    warning('El número de años es menor que el número de puntos de datos. Se ajustará automáticamente.');
    years = repmat(years, ceil(num_data_points / length(years)), 1);
    years = years(1:num_data_points); % Asegurarse de que tenga el tamaño correcto
end

% Crear un vector de tiempo (año-mes) para el eje x
time = datetime(years, months, 1);

% Crear una matriz para el diagrama Hovmöller
% Queremos que el eje X sea tiempo (años), el eje Y sea SST y el eje Z sea latitud
unique_latitudes = unique(latitudes);
unique_time = unique(time);

% Inicializar una matriz para almacenar los valores de SST
hovmoller_matrix = nan(length(unique_latitudes), length(unique_time));

% Llenar la matriz Hovmöller con los valores de SST
for i = 1:length(unique_latitudes)
    for j = 1:length(unique_time)
        % Encontrar los datos correspondientes a esta latitud y tiempo
        idx = (latitudes == unique_latitudes(i)) & (time == unique_time(j));
        if any(idx)
            hovmoller_matrix(i, j) = mean(sst(idx)); % Promedio de SST si hay varios puntos
        end
    end
end

% Graficar el diagrama de Hovmöller
figure;
imagesc(unique_time, unique_latitudes, hovmoller_matrix); % Eje X = tiempo, Y = latitud, colores = SST
set(gca, 'YDir', 'normal'); % Para que las latitudes menores estén abajo
colorbar;
xlabel('Tiempo (Años)');
ylabel('SST (°C)');
title('Diagrama de Hovmöller de SST vs Tiempo y Latitud');

% Formatear el eje X para que muestre los años sin repetirse
xticks(unique_time(1:12:end)); % Mostrar solo un tick por cada año
xticklabels(datestr(unique_time(1:12:end), 'yyyy')); % Etiquetas de año solamente

% Ajustar los colores según los valores de SST
colormap jet; % Aplicar un mapa de colores
caxis([min(hovmoller_matrix(:)), max(hovmoller_matrix(:))]); % Ajustar los límites del color según los datos

























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% Establecer el directorio de trabajo donde se encuentra el archivo CSV
cd('/Volumes/LLACA/Posdoctorado/Gaby');

% Cargar el archivo CSV con las anomalías de SST
% Asegúrate de que el nombre del archivo coincida exactamente con el que estás utilizando
data = readtable('anomalia_sst_octubre_2005.csv');

% Verificar que los datos se hayan cargado correctamente
disp('Datos de anomalía de SST cargados correctamente.');

% Extraer las variables de interés: Fecha, Latitud, y Anomalía
fechas = data.Fecha;         % Suponiendo que esta columna contiene las fechas
latitudes = data.Latitud;     % Suponiendo que esta columna contiene las latitudes
sst_anomalies = data.Anomalia; % Columna de anomalías de SST

% Convertir las fechas a formato datetime con el formato dd/mm/yyyy
fechas = datetime(fechas, 'InputFormat', 'dd/MM/yyyy');

% Crear un vector único de latitudes y fechas
unique_latitudes = unique(latitudes);
unique_dates = unique(fechas);

% Inicializar una matriz para almacenar los valores de anomalías de SST
hovmoller_matrix = nan(length(unique_latitudes), length(unique_dates));

% Llenar la matriz Hovmöller con los valores de anomalía de SST
for i = 1:length(unique_latitudes)
    for j = 1:length(unique_dates)
        % Encontrar los datos correspondientes a esta latitud y fecha
        idx = (latitudes == unique_latitudes(i)) & (fechas == unique_dates(j));
        if any(idx)
            hovmoller_matrix(i, j) = mean(sst_anomalies(idx)); % Promedio de las anomalías de SST si hay varios puntos
        end
    end
end

% Graficar el diagrama de Hovmöller
figure;
imagesc(unique_dates, unique_latitudes, hovmoller_matrix); % Eje X = tiempo, Y = latitud, colores = anomalías de SST
set(gca, 'YDir', 'normal'); % Para que las latitudes menores estén abajo
colorbar;
xlabel('Tiempo (Días de Octubre 2005)');
ylabel('Latitud');
title('Diagrama de Hovmöller de Anomalías de SST (Octubre 2005)');

% Formatear el eje X para que muestre los días con marcas claras
xticks(unique_dates(1:round(length(unique_dates)/10):end)); % Mostrar aproximadamente 10 ticks a lo largo del tiempo
xtickformat('dd-MMM-yyyy'); % Formato de fecha para los ticks

% Ajustar los colores según las anomalías de SST
colormap jet; % Aplicar un mapa de colores
caxis([min(hovmoller_matrix(:)), max(hovmoller_matrix(:))]); % Ajustar los límites del color según los datos

























































































%gráfica de anomalía 

% Cerrar todo, limpiar el espacio de trabajo y limpiar la consola
close all
clear all
clc

% Establecer el directorio de trabajo donde se encuentra el archivo CSV
cd('/Volumes/LLACA/Posdoctorado/Gaby');

% Cargar el archivo CSV con las anomalías de SST
% Asegúrate de que el nombre del archivo coincida exactamente con el que estás utilizando
data = readtable('anomalia_sst_octubre_2005.csv');

% Verificar que los datos se hayan cargado correctamente
disp('Datos de anomalía de SST cargados correctamente.');

% Extraer las variables de interés: Fecha, Latitud, y Anomalía
fechas = data.Fecha;         % Suponiendo que esta columna contiene las fechas
latitudes = data.Latitud;     % Suponiendo que esta columna contiene las latitudes
sst_anomalies = data.Anomalia; % Columna de anomalías de SST

% Convertir las fechas a formato datetime con el formato dd/mm/yyyy
fechas = datetime(fechas, 'InputFormat', 'dd/MM/yyyy');

% Graficar los datos
figure;
scatter(fechas, sst_anomalies, 20, latitudes, 'filled'); % Eje X = tiempo, Y = anomalía, tamaño/color de marcador = latitud
colorbar; % Mostrar una barra de color para la latitud
xlabel('Tiempo (Días de Octubre 2005)');
ylabel('Anomalía de SST');
title('Distribución de Anomalías de SST (Octubre 2005)');

% Formatear el eje X para que muestre los días con marcas claras
xticks(fechas(1:round(length(fechas)/10):end)); % Mostrar aproximadamente 10 ticks a lo largo del tiempo
xtickformat('dd-MMM-yyyy'); % Formato de fecha para los ticks

% Ajustar los colores según la latitud
colormap jet; % Aplicar un mapa de colores
