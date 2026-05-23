% Asegurarse de que no haya conflicto con 'years' como función
clear years

% Establecer el directorio de trabajo
cd('/Volumes/LLACA/Posdoctorado/Gaby');

%% Parte 1: Cargar datos de climatología de SST mensual

% Cargar el archivo climatologia_sst_mensual.mat
load('climatologia_sst_mensual.mat');

% Verificar que los datos se hayan cargado correctamente
disp('Datos de climatología cargados correctamente.');

% Extraer las variables de interés
months = climatology_data.Month;
latitudes = climatology_data.Latitude;
sst = climatology_data.SST;

% Crear una serie de años correspondiente a los datos (suponiendo que van de 2003 a 2007)
num_years = 5;  % Número de años
years_repeated = repmat(2003:2007, 12, 1); % 5 años, 12 meses cada año
years = years_repeated(:); % Convertir a un vector columna

% Ajustar 'years' si el número de datos es diferente
num_data_points = height(climatology_data); % Número total de puntos de datos
if length(years) > num_data_points
    years = years(1:num_data_points); % Truncar si es necesario
elseif length(years) < num_data_points
    warning('El número de años es menor que el número de puntos de datos. Se ajustará automáticamente.');
    years = repmat(years, ceil(num_data_points / length(years)), 1);
    years = years(1:num_data_points); % Asegurarse de que tenga el tamaño correcto
end

% Crear vector de fechas (tiempo) a partir de los años y meses
time = datetime(years, months, 1);

%% Parte 2: Cargar datos de anomalía de SST para octubre de 2005

% Cargar el archivo anomalia_sst_octubre_2005.csv
anomalia_data = readtable('anomalia_sst_octubre_2005.csv');

% Verificar que los datos se hayan cargado correctamente
disp('Datos de anomalía cargados correctamente.');

% Extraer las variables de interés
oct_time = anomalia_data.Fecha;
anomaly = anomalia_data.Anomalia;
oct_latitudes = anomalia_data.Latitud;

% Filtrar SST para octubre de 2005
october_index = (months == 10) & (year(time) == 2005);
sst_october = sst(october_index);
latitudes_october = latitudes(october_index);

% Eliminar duplicados en las anomalías de octubre
[unique_oct_latitudes, unique_idx_oct] = unique(oct_latitudes);
unique_anomaly = anomaly(unique_idx_oct);

% Eliminar duplicados en las latitudes de SST para octubre de 2005
[unique_latitudes_october, unique_idx_sst] = unique(latitudes_october);
unique_sst_october = sst_october(unique_idx_sst);

% Interpolar las anomalías para que coincidan con las latitudes de SST
% Suponiendo que las anomalías y SST están ahora alineados por latitud
anomaly_interp = interp1(unique_oct_latitudes, unique_anomaly, unique_latitudes_october, 'linear', 'extrap');

% Verificar si las dimensiones coinciden
if length(unique_sst_october) ~= length(anomaly_interp)
    error('Las dimensiones de los datos de SST y anomalías no coinciden después de la interpolación.');
end

%% Calcular las estadísticas

% Calcular ECM (Error Cuadrático Medio)
ecm = mean((unique_sst_october - anomaly_interp).^2);

% Calcular RMSE (Raíz del Error Cuadrático Medio)
rmse = sqrt(ecm);

% Calcular EAM (Error Absoluto Medio)
eam = mean(abs(unique_sst_october - anomaly_interp));

% Estimar la incertidumbre (desviación estándar de los errores)
incertidumbre = std(unique_sst_october - anomaly_interp);

% Mostrar los resultados
fprintf('ECM: %.4f\n', ecm);
fprintf('RMSE: %.4f\n', rmse);
fprintf('EAM: %.4f\n', eam);
fprintf('Incertidumbre: %.4f\n', incertidumbre);
