%% *** CONFIGURACIÓN INICIAL ***
% Directorio de archivos
dataDir = '/Volumes/LLACA/Posdoctorado/Gaby';

% Rango geográfico
latMin = 18; latMax = 23;
lonMin = 86; lonMax = 87.5;

% Fechas del huracán Wilma
wilmaStart = datetime(2005, 10, 1);
wilmaEnd = datetime(2005, 10, 31);

% Fechas para la climatología (2000-2004, octubre)
climatologyStart = datetime(2003, 10, 1);
climatologyEnd = datetime(2007, 10, 31);

% Inicialización de variables
anomSST = [];
anomSOS = [];

%% *** SECCIÓN 1: PROCESAR SST ***
% Cargar archivo SST
sstFile = fullfile(dataDir, 'sst_2003_2007.csv');
sstData = readtable(sstFile);

% Mostrar el tamaño original de los datos
disp('Tamaño original de los datos de SST:');
disp(size(sstData));

% Eliminar filas con valores NaN o vacíos
sstData = rmmissing(sstData);

% Mostrar el tamaño después de eliminar NaN
disp('Tamaño de los datos de SST después de eliminar NaN:');
disp(size(sstData));

% Filtrar por coordenadas geográficas
sstData = sstData(sstData.Latitude >= latMin & sstData.Latitude <= latMax & ...
                  sstData.Longitude >= lonMin & sstData.Longitude <= lonMax, :);

% Mostrar el tamaño después de filtrar por coordenadas
disp('Tamaño de los datos de SST después de filtrar por coordenadas:');
disp(size(sstData));

% Filtrar por fechas (considerando el período de huracán Wilma)
sstWilma = sstData(sstData.Time >= wilmaStart & sstData.Time <= wilmaEnd, :);

% Mostrar el tamaño de los datos de SST durante Wilma
disp('Tamaño de los datos de SST durante el huracán Wilma:');
disp(size(sstWilma));

% Filtrar datos climatológicos de octubre (2000-2004)
octoberData = sstData(sstData.Time >= climatologyStart & sstData.Time <= climatologyEnd & ...
                      month(sstData.Time) == 10, :);

% Mostrar el tamaño de los datos climatológicos de octubre (2000-2004)
disp('Tamaño de los datos climatológicos de SST (octubre 2000-2004):');
disp(size(octoberData));

% Calcular climatología promedio
sstClimatology = mean(octoberData.SST, 'omitnan');

% Mostrar el valor de la climatología calculada
disp('Climatología de SST calculada:');
disp(sstClimatology);

% Calcular anomalías SST
anomSST = sstData.SST - sstClimatology;

% Mostrar algunas anomalías antes de eliminar NaN
disp('Primeras anomalías de SST (antes de eliminar NaN):');
disp(anomSST(1:10));  % Mostrar solo las primeras 10 anomalías

% Eliminar NaN de las anomalías de SST
anomSST = anomSST(~isnan(anomSST));  % Elimina las anomalías NaN

% Mostrar el número de anomalías restantes
disp('Número de anomalías de SST restantes después de eliminar NaN:');
disp(length(anomSST));

% Verificar si las anomalías de SST están vacías
if isempty(anomSST)
    error('Las anomalías de SST están vacías después de eliminar NaN.');
end

% Calcular desviación estándar de las anomalías SST
sigmaSST = std(anomSST, 'omitnan');

% Si la desviación estándar es NaN o cero, establecer un valor por defecto
if isnan(sigmaSST) || sigmaSST == 0
    sigmaSST = 1e-6; % Establecer un valor pequeño si la desviación estándar es NaN o cero
    warning('La desviación estándar de SST es NaN o cero. Se ha asignado un valor pequeño.');
end

% Calcular promedio de SST durante Wilma
sstWilmaMean = mean(sstWilma.SST, 'omitnan');

% Diferencia entre Wilma y la climatología
sstDifference = sstWilmaMean - sstClimatology;



%% *** SECCIÓN 2: PROCESAR SOS ***
% Cargar archivo SOS
sosFile = fullfile(dataDir, 'sos_2003_2007.csv');
sosData = readtable(sosFile);

% Eliminar filas con valores NaN o vacíos
sosData = rmmissing(sosData);

% Filtrar por coordenadas geográficas
sosData = sosData(sosData.Latitude >= latMin & sosData.Latitude <= latMax & ...
                  sosData.Longitude >= lonMin & sosData.Longitude <= lonMax, :);

% Convertir fechas
sosData.Time = datetime(sosData.Time, 'InputFormat', 'dd/MM/yyyy');

% Filtrar datos del huracán Wilma
sosWilma = sosData(sosData.Time >= wilmaStart & sosData.Time <= wilmaEnd, :);

% Filtrar datos climatológicos de octubre (2000-2004)
octoberData = sosData(sosData.Time >= climatologyStart & sosData.Time <= climatologyEnd & ...
                      month(sosData.Time) == 10, :);

% Calcular climatología promedio
sosClimatology = mean(octoberData.Sos, 'omitnan');

% Calcular anomalías SOS
anomSOS = sosData.Sos - sosClimatology;

% Eliminar NaN de las anomalías de SOS
anomSOS = anomSOS(~isnan(anomSOS));  % Elimina las anomalías NaN

% Verificar que anomSOS no esté vacío después de eliminar NaN
if isempty(anomSOS)
    error('Las anomalías de SOS están vacías después de eliminar NaN.');
end

% Calcular desviación estándar de las anomalías SOS
sigmaSOS = std(anomSOS, 'omitnan');

% Si la desviación estándar es NaN o cero, establecer un valor por defecto
if isnan(sigmaSOS) || sigmaSOS == 0
    sigmaSOS = 1e-6; % Establecer un valor pequeño si la desviación estándar es NaN o cero
    warning('La desviación estándar de SOS es NaN o cero. Se ha asignado un valor pequeño.');
end

% Calcular promedio de SOS durante Wilma
sosWilmaMean = mean(sosWilma.Sos, 'omitnan');

% Diferencia entre Wilma y la climatología
sosDifference = sosWilmaMean - sosClimatology;

%% *** ANÁLISIS BAYESIANO CON MCMC ***
% Definir los datos relevantes
mu_prior = [sstClimatology, sosClimatology]; % Media a priori de SST y SOS

% Desviaciones estándar de las anomalías generales (como estimación de incertidumbre a priori)
sigma_prior = [sigmaSST, sigmaSOS];

% Verificar que las desviaciones estándar no sean NaN
if any(isnan(sigma_prior))
    error('Algunas desviaciones estándar son NaN. Verifica que las anomalías estén bien calculadas.');
end

% Matriz de covarianza a priori (diagonal con las varianzas)
SIGMA_prior = diag(sigma_prior.^2);  % Esto asegura que sea una matriz diagonal

% Asegurarse de que SIGMA_prior es simétrica
SIGMA_prior = (SIGMA_prior + SIGMA_prior') / 2; % Asegura simetría

% Verificar la matriz de covarianza
disp('Matriz de covarianza SIGMA_prior:');
disp(SIGMA_prior);

% Calcular las medias de las anomalías durante Wilma
mu_likelihood = [sstWilmaMean, sosWilmaMean];

% Desviaciones estándar de las anomalías durante Wilma
sigma_likelihood = sigma_prior; % Asumiendo misma desviación estándar

% Matriz de covarianza del likelihood (diagonal con las varianzas)
SIGMA_likelihood = diag(sigma_likelihood.^2);

% Verificar que mu_likelihood tiene exactamente 2 elementos
assert(numel(mu_likelihood) == 2, 'mu_likelihood debe tener exactamente 2 elementos');

% Combinar prior y likelihood para generar la posterior
mu_posterior = (mu_prior ./ diag(SIGMA_prior) + ...
                mu_likelihood ./ diag(SIGMA_likelihood)) ./ ...
                (1 ./ diag(SIGMA_prior) + 1 ./ diag(SIGMA_likelihood));

% Número de muestras
n_samples = 5000; 

% Simulación de MCMC
samples_posterior = mvnrnd(mu_posterior, SIGMA_prior, n_samples);

