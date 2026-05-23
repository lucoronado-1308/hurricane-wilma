% Definir la carpeta donde se guardarán los archivos MAT
carpeta_guardado = '/Volumes/LLACA/Posdoc_matlab/SSS_SST_WIND/';

% Definir el nombre del archivo netCDF
nombre_archivo_nc = 'RSS_smap_SSS_L3_8day_running_2015_091_FNL_v05.0.nc';
ncdips
% Abre el archivo netCDF
nc = netcdf.open(nombre_archivo_nc, 'NOWRITE');

% Leer el número total de días en el archivo (desde el día 091 de 2015 al día 185 de 2023)
num_dias = netcdf.getVar(nc, netcdf.inqDimID(nc, 'time'));

% Leer la variable de tiempo (en segundos desde '2000-01-01T00:00:00Z')
tiempo = netcdf.getVar(nc, netcdf.inqVarID(nc, 'time'));

% Calcular la fecha de referencia
fecha_referencia = datenum('2000-01-01T00:00:00Z', 'yyyy-mm-ddTHH:MM:SSZ');

% Bucle para procesar datos por día
for dia = 1:num_dias
    % Calcular la fecha actual
    fecha_actual = fecha_referencia + tiempo(dia) / (24 * 3600); % Convertir segundos a días
    
    % Obtener el año, mes y día actual
    year_actual = year(fecha_actual);
    mes_actual = month(fecha_actual);
    dia_actual = day(fecha_actual);
    
    % Leer datos de salinidad para el día actual
    salinidad = netcdf.getVar(nc, netcdf.inqVarID(nc, 'sss_smap'), [0, 0, dia-1], [Inf, Inf, 1]);
    
    % Construir el nombre del archivo MAT para el año, mes y día actual
    nombre_archivo_mat = sprintf('salinidad_%d_%02d_%03d.mat', year_actual, mes_actual, dia_actual - 90); % Restar 90 para ajustar a la numeración de días
    
    % Guardar los datos de salinidad en un archivo MAT
    save(fullfile(carpeta_guardado, nombre_archivo_mat), 'salinidad');
end

% Cerrar el archivo netCDF
netcdf.close(nc);
