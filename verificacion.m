%% *** CONFIGURACIÓN INICIAL ***
dataDir = '/Volumes/LLACA/Posdoctorado/Gaby'; % Ruta del directorio

% Nombres de los archivos
chlFile = fullfile(dataDir, 'chl_2003_2007.csv');
sosFile = fullfile(dataDir, 'sos_2003_2007.csv');
sstFile = fullfile(dataDir, 'sst_2003_2007.csv');

%% *** CARGAR LOS ARCHIVOS Y VERIFICAR LATITUDES Y LONGITUDES ***
% Cargar y verificar CHL
try
    chlData = readtable(chlFile);
    disp('Rango de latitudes y longitudes en CHL:');
    disp(['Latitudes: ', num2str(min(chlData.Latitude)), ' a ', num2str(max(chlData.Latitude))]);
    disp(['Longitudes: ', num2str(min(chlData.Longitude)), ' a ', num2str(max(chlData.Longitude))]);
catch ME
    disp('Error al cargar CHL:');
    disp(ME.message);
end

% Cargar y verificar SOS
try
    sosData = readtable(sosFile);
    disp('Rango de latitudes y longitudes en SOS:');
    disp(['Latitudes: ', num2str(min(sosData.Latitude)), ' a ', num2str(max(sosData.Latitude))]);
    disp(['Longitudes: ', num2str(min(sosData.Longitude)), ' a ', num2str(max(sosData.Longitude))]);
catch ME
    disp('Error al cargar SOS:');
    disp(ME.message);
end

% Cargar y verificar SST
try
    sstData = readtable(sstFile);
    disp('Rango de latitudes y longitudes en SST:');
    disp(['Latitudes: ', num2str(min(sstData.Latitude)), ' a ', num2str(max(sstData.Latitude))]);
    disp(['Longitudes: ', num2str(min(sstData.Longitude)), ' a ', num2str(max(sstData.Longitude))]);
catch ME
    disp('Error al cargar SST:');
    disp(ME.message);
end
