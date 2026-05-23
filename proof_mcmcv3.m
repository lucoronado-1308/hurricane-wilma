%% *** INICIO ***
% Directorio de archivos
dataDir = '/Volumes/LLACA/Posdoctorado/Gaby';

% Rango geográfico (coordenadas específicas para el área más pequeña)
latMin = 20; latMax = 22;
lonMin = -87.5; lonMax = -86;

% Fechas del huracán Wilma
wilmaStart = datetime(2005, 10, 15);
wilmaEnd = datetime(2005, 10, 25);

% Fechas para la climatología (2000-2004, octubre)
climatologyStart = datetime(2003, 10, 1);
climatologyEnd = datetime(2007, 10, 31);

%% *** PROCESAMIENTO DE SST ***
% archivo SST
sstFile = fullfile(dataDir, 'sst_2003_2007.csv');
sstData = readtable(sstFile);

% Eliminar filas con valores NaN o vacíos
sstData = rmmissing(sstData);

% Filtrar por coordenadas geográficas
sstData = sstData(sstData.Latitude >= latMin & sstData.Latitude <= latMax & ...
                  sstData.Longitude >= lonMin & sstData.Longitude <= lonMax, :);

% Convertir fechas a formato datetime si es necesario
if ~isdatetime(sstData.Time)
    sstData.Time = datetime(sstData.Time, 'InputFormat', 'dd/MM/yyyy');
end

% Filtrar datos climatológicos de octubre (2000-2007)
octoberDataSST = sstData(sstData.Time >= climatologyStart & sstData.Time <= climatologyEnd & ...
                         month(sstData.Time) == 10, :);

% Calcular climatología promedio y desviación estándar
sstClimatology = mean(octoberDataSST.SST, 'omitnan');
sigmaSST = std(octoberDataSST.SST, 'omitnan');

% Calcular promedio de SST durante Wilma
sstWilma = sstData(sstData.Time >= wilmaStart & sstData.Time <= wilmaEnd, :);
sstWilmaMean = mean(sstWilma.SST, 'omitnan');

sstClimatology = sstClimatology - 273.15; % Climatología SST en grados Celsius
sstWilmaMean = sstWilmaMean - 273.15; % SST durante Wilma en grados Celsius


%% *** PROCESAMIENTO DE SOS ***
% Cargar archivo SOS
sosFile = fullfile(dataDir, 'sos_2003_2007.csv');
sosData = readtable(sosFile);

% Eliminar filas con valores NaN o vacíos
sosData = rmmissing(sosData);

% Filtrar por coordenadas geográficas
sosData = sosData(sosData.Latitude >= latMin & sosData.Latitude <= latMax & ...
                  sosData.Longitude >= lonMin & sosData.Longitude <= lonMax, :);

% Convertir fechas a formato datetime si es necesario
if ~isdatetime(sosData.Time)
    sosData.Time = datetime(sosData.Time, 'InputFormat', 'dd/MM/yyyy');
end

% Filtrar datos climatológicos de octubre (2000-2004)
octoberDataSOS = sosData(sosData.Time >= climatologyStart & sosData.Time <= climatologyEnd & ...
                         month(sosData.Time) == 10, :);

% Calcular climatología promedio y desviación estándar
sosClimatology = mean(octoberDataSOS.Sos, 'omitnan');
sigmaSOS = std(octoberDataSOS.Sos, 'omitnan');

% Calcular promedio de SOS durante Wilma
sosWilma = sosData(sosData.Time >= wilmaStart & sosData.Time <= wilmaEnd, :);
sosWilmaMean = mean(sosWilma.Sos, 'omitnan');

%% *** PROCESAMIENTO DE CHL ***
% Cargar archivo CHL
chlFile = fullfile(dataDir, 'chl_2003_2007.csv');
chlData = readtable(chlFile);

% Eliminar filas con valores NaN o vacíos
chlData = rmmissing(chlData);

% Filtrar por coordenadas geográficas
chlData = chlData(chlData.Latitude >= latMin & chlData.Latitude <= latMax & ...
                  chlData.Longitude >= lonMin & chlData.Longitude <= lonMax, :);

% Convertir fechas a formato datetime si es necesario
if ~isdatetime(chlData.Time)
    chlData.Time = datetime(chlData.Time, 'InputFormat', 'dd/MM/yyyy');
end

% Filtrar datos climatológicos de octubre (2000-2004)
octoberDataCHL = chlData(chlData.Time >= climatologyStart & chlData.Time <= climatologyEnd & ...
                         month(chlData.Time) == 10, :);

% Calcular climatología promedio y desviación estándar
chlClimatology = mean(octoberDataCHL.Chl, 'omitnan');
sigmaCHL = std(octoberDataCHL.Chl, 'omitnan');

% Calcular promedio de CHL durante Wilma
chlWilma = chlData(chlData.Time >= wilmaStart & chlData.Time <= wilmaEnd, :);
chlWilmaMean = mean(chlWilma.Chl, 'omitnan');

%% *** ANÁLISIS BAYESIANO CON MCMC ***
% Definir los datos relevantes
mu_prior = [sstClimatology, sosClimatology, chlClimatology];
sigma_prior = [sigmaSST, sigmaSOS, sigmaCHL];

% Matriz de covarianza a priori (diagonal con las varianzas)
SIGMA_prior = diag(sigma_prior.^2);

% Medias observadas durante el huracán Wilma
mu_likelihood = [sstWilmaMean, sosWilmaMean, chlWilmaMean];

% Matriz de covarianza del likelihood (diagonal con las varianzas)
SIGMA_likelihood = diag(sigma_prior.^2);

% % Calcular la media posterior
% mu_posterior = (mu_prior ./ diag(SIGMA_prior) + mu_likelihood ./ diag(SIGMA_likelihood)) ./ ...
%                (1 ./ diag(SIGMA_prior) + 1 ./ diag(SIGMA_likelihood));
% 
% mu_posterior= mu_posterior(1:3); % Se ajusta porque debe ser un vector fila
% 
% % Matriz de covarianza posterior
% SIGMA_posterior = diag(1 ./ (1 ./ diag(SIGMA_prior) + 1 ./ diag(SIGMA_likelihood)));
% 
% 
% % Simulación de MCMC
% n_samples = 5000;
% samples_posterior = mvnrnd(mu_posterior, SIGMA_posterior, n_samples);
% 
% % VER resultados
% disp('Primeras muestras generadas:');
% disp(samples_posterior(1:5, :)); % primeras 5 simulaciones

%%
mu_posterior_sst = (mu_prior(1) / SIGMA_prior(1, 1) + mu_likelihood(1) / SIGMA_likelihood(1, 1)) / ...
                   (1 / SIGMA_prior(1, 1) + 1 / SIGMA_likelihood(1, 1));

mu_posterior_sos = (mu_prior(2) / SIGMA_prior(2, 2) + mu_likelihood(2) / SIGMA_likelihood(2, 2)) / ...
                   (1 / SIGMA_prior(2, 2) + 1 / SIGMA_likelihood(2, 2));

mu_posterior_chl = (mu_prior(3) / SIGMA_prior(3, 3) + mu_likelihood(3) / SIGMA_likelihood(3, 3)) / ...
                   (1 / SIGMA_prior(3, 3) + 1 / SIGMA_likelihood(3, 3));
mu_posterior = [mu_posterior_sst, mu_posterior_sos, mu_posterior_chl];

SIGMA_posterior = diag(1 ./ (1 ./ diag(SIGMA_prior) + 1 ./ diag(SIGMA_likelihood)));

% Simulación de MCMC
n_samples = 5000;
samples_posterior = mvnrnd(mu_posterior, SIGMA_posterior, n_samples);



%%
% SIGMA_posterior = diag(1 ./ (1 ./ diag(SIGMA_prior) + 1 ./ diag(SIGMA_likelihood)));
% disp('SIGMA_prior:');
% disp(SIGMA_prior);
% disp('SIGMA_likelihood:');
% disp(SIGMA_likelihood);
% disp('SIGMA_posterior:');
% disp(SIGMA_posterior);
% disp('mu_prior:');
% disp(mu_prior);
% disp('mu_likelihood:');
% disp(mu_likelihood);
% disp('mu_posterior:');
% disp(mu_posterior);
% sigmaSST = max(sigmaSST, 0.5); % 
% 
%%
% Visualización de resultados
figure;
subplot(1, 3, 1);
histogram(samples_posterior(:, 1), 50, 'FaceColor', 'b');
title('Posterior SST');
xlabel('Media de SST');
ylabel('Frecuencia');

subplot(1, 3, 2);
histogram(samples_posterior(:, 2), 50, 'FaceColor', 'r');
title('Posterior SOS');
xlabel('Media de SOS');
ylabel('Frecuencia');

subplot(1, 3, 3);
histogram(samples_posterior(:, 3), 50, 'FaceColor', 'g');
title('Posterior CHL');
xlabel('Media de CHL');
ylabel('Frecuencia');

%%
%% *** INTERVALO DE CREDIBILIDAD (CI) ***
% Calcular intervalos de credibilidad al 95% para las distribuciones posteriores
credibility_interval_95 = prctile(samples_posterior, [2.5, 97.5]);

% Mostrar si los valores climatológicos están dentro del CI
disp('Intervalos de credibilidad al 95% para los parámetros posteriores:');
disp(credibility_interval_95);

disp('¿Están las medias climatológicas dentro del intervalo de credibilidad?');
in_ci = (mu_prior >= credibility_interval_95(1, :) & mu_prior <= credibility_interval_95(2, :));
disp(array2table(in_ci, 'VariableNames', {'SST', 'SOS', 'CHL'}));

%% *** PROBABILIDAD DE DIFERENCIA SIGNIFICATIVA ***
% Calcular probabilidad de que las medias de Wilma sean diferentes de las climatológicas
prob_diff = mean(samples_posterior > mu_prior, 1); % Probabilidad de que Wilma > Climatología
disp('Probabilidades de que Wilma sea significativamente diferente de Climatología:');
disp(array2table(prob_diff, 'VariableNames', {'SST', 'SOS', 'CHL'}));

%% *** VISUALIZACIÓN: HISTOGRAMAS Y CIs ***
figure;

% Histograma para SST
subplot(1, 3, 1);
histogram(samples_posterior(:, 1), 50, 'FaceColor', 'b');
hold on;
xline(mu_prior(1), 'r--', 'LineWidth', 2, 'Label', 'Climatología');
xline(credibility_interval_95(1, 1), 'k:', 'LineWidth', 1.5, 'Label', '2.5%');
xline(credibility_interval_95(2, 1), 'k:', 'LineWidth', 1.5, 'Label', '97.5%');
title('Posterior SST');
xlabel('SST');
ylabel('Frecuencia');

% Histograma para SOS
subplot(1, 3, 2);
histogram(samples_posterior(:, 2), 50, 'FaceColor', 'r');
hold on;
xline(mu_prior(2), 'r--', 'LineWidth', 2, 'Label', 'Climatología');
xline(credibility_interval_95(1, 2), 'k:', 'LineWidth', 1.5, 'Label', '2.5%');
xline(credibility_interval_95(2, 2), 'k:', 'LineWidth', 1.5, 'Label', '97.5%');
title('Posterior SOS');
xlabel('SOS');
ylabel('Frecuencia');

% Histograma para CHL
subplot(1, 3, 3);
histogram(samples_posterior(:, 3), 50, 'FaceColor', 'g');
hold on;
xline(mu_prior(3), 'r--', 'LineWidth', 2, 'Label', 'Climatología');
xline(credibility_interval_95(1, 3), 'k:', 'LineWidth', 1.5, 'Label', '2.5%');
xline(credibility_interval_95(2, 3), 'k:', 'LineWidth', 1.5, 'Label', '97.5%');
title('Posterior CHL');
xlabel('CHL');
ylabel('Frecuencia');

legend('Muestras Posteriores', 'Climatología', 'Intervalo 95%');

%%

%% *** VISUALIZACIÓN DE RESULTADOS POSTERIORES Y CONVERGENCIA ***

% Mostrar las primeras muestras generadas para tener una idea del resultado de la simulación
disp('Primeras muestras generadas:');
disp(samples_posterior(1:5, :)); % Primeras 5 simulaciones

% Verifica la convergencia utilizando la autocorrelación de las muestras
figure;
subplot(1, 3, 1);
autocorr(samples_posterior(:, 1), 'NumLags', 50);
title('Autocorrelación - SST');

subplot(1, 3, 2);
autocorr(samples_posterior(:, 2), 'NumLags', 50);
title('Autocorrelación - SOS');

subplot(1, 3, 3);
autocorr(samples_posterior(:, 3), 'NumLags', 50);
title('Autocorrelación - CHL');

% ** Histograma y comparaciones con valores climatológicos **
% Generar histogramas de las distribuciones posteriores de cada variable (SST, SOS, CHL)
figure;

% Histograma para SST
subplot(1, 3, 1);
histogram(samples_posterior(:, 1), 50, 'FaceColor', 'b');
hold on;
xline(mu_prior(1), 'r--', 'LineWidth', 2, 'Label', 'Climatología');
xline(credibility_interval_95(1, 1), 'k:', 'LineWidth', 1.5, 'Label', '2.5%');
xline(credibility_interval_95(2, 1), 'k:', 'LineWidth', 1.5, 'Label', '97.5%');
title('Posterior SST');
xlabel('SST');
ylabel('Frecuencia');

% Histograma para SOS
subplot(1, 3, 2);
histogram(samples_posterior(:, 2), 50, 'FaceColor', 'r');
hold on;
xline(mu_prior(2), 'r--', 'LineWidth', 2, 'Label', 'Climatología');
xline(credibility_interval_95(1, 2), 'k:', 'LineWidth', 1.5, 'Label', '2.5%');
xline(credibility_interval_95(2, 2), 'k:', 'LineWidth', 1.5, 'Label', '97.5%');
title('Posterior SOS');
xlabel('SOS');
ylabel('Frecuencia');

% Histograma para CHL
subplot(1, 3, 3);
histogram(samples_posterior(:, 3), 50, 'FaceColor', 'g');
hold on;
xline(mu_prior(3), 'r--', 'LineWidth', 2, 'Label', 'Climatología');
xline(credibility_interval_95(1, 3), 'k:', 'LineWidth', 1.5, 'Label', '2.5%');
xline(credibility_interval_95(2, 3), 'k:', 'LineWidth', 1.5, 'Label', '97.5%');
title('Posterior CHL');
xlabel('CHL');
ylabel('Frecuencia');

legend('Muestras Posteriores', 'Climatología', 'Intervalo 95%');
sgtitle('Distribuciones Posteriores y Comparación con Climatología');

%% *** ANÁLISIS DE SENSIBILIDAD A PRIORI ***

% Probar con diferentes valores a priori (más informativos o más difusos)
new_sigma_prior = [sigmaSST*1.5, sigmaSOS*1.5, sigmaCHL*1.5];  % Aumentando las desviaciones estándar
new_SIGMA_prior = diag(new_sigma_prior.^2);

% Recalcular la media posterior con los nuevos valores de sigma_prior
new_mu_posterior_sst = (mu_prior(1) / new_SIGMA_prior(1, 1) + mu_likelihood(1) / SIGMA_likelihood(1, 1)) / ...
                       (1 / new_SIGMA_prior(1, 1) + 1 / SIGMA_likelihood(1, 1));

new_mu_posterior_sos = (mu_prior(2) / new_SIGMA_prior(2, 2) + mu_likelihood(2) / SIGMA_likelihood(2, 2)) / ...
                       (1 / new_SIGMA_prior(2, 2) + 1 / SIGMA_likelihood(2, 2));

new_mu_posterior_chl = (mu_prior(3) / new_SIGMA_prior(3, 3) + mu_likelihood(3) / SIGMA_likelihood(3, 3)) / ...
                       (1 / new_SIGMA_prior(3, 3) + 1 / SIGMA_likelihood(3, 3));

new_mu_posterior = [new_mu_posterior_sst, new_mu_posterior_sos, new_mu_posterior_chl];
new_SIGMA_posterior = diag(1 ./ (1 ./ diag(new_SIGMA_prior) + 1 ./ diag(SIGMA_likelihood)));

% Simulación de MCMC con nuevos priors
new_samples_posterior = mvnrnd(new_mu_posterior, new_SIGMA_posterior, n_samples);

% Comparación con las distribuciones anteriores
figure;

subplot(1, 3, 1);
histogram(new_samples_posterior(:, 1), 50, 'FaceColor', 'b');
hold on;
xline(mu_prior(1), 'r--', 'LineWidth', 2);
title('Posterior SST - Nuevo Prior');

subplot(1, 3, 2);
histogram(new_samples_posterior(:, 2), 50, 'FaceColor', 'r');
hold on;
xline(mu_prior(2), 'r--', 'LineWidth', 2);
title('Posterior SOS - Nuevo Prior');

subplot(1, 3, 3);
histogram(new_samples_posterior(:, 3), 50, 'FaceColor', 'g');
hold on;
xline(mu_prior(3), 'r--', 'LineWidth', 2);
title('Posterior CHL - Nuevo Prior');

sgtitle('Comparación con Nuevo Prior');

%% *** CÁLCULO DE PROBABILIDADES DE DIFERENCIAS SIGNIFICATIVATIVAS ***

% Probabilidad de que las medias de Wilma sean mayores que las medias climatológicas
prob_diff = mean(samples_posterior > mu_prior, 1); % Probabilidad de que Wilma > Climatología
disp('Probabilidades de que Wilma sea significativamente diferente de Climatología:');
disp(array2table(prob_diff, 'VariableNames', {'SST', 'SOS', 'CHL'}));

% Compara las probabilidades para los nuevos priors
new_prob_diff = mean(new_samples_posterior > mu_prior, 1); % Probabilidad con nuevo prior
disp('Probabilidades con Nuevo Prior:');
disp(array2table(new_prob_diff, 'VariableNames', {'SST', 'SOS', 'CHL'}));

%% *** CALCULO DE INTERVALOS DE CREDIBILIDAD (CI) ***

% Intervalos de credibilidad para los nuevos resultados
new_credibility_interval_95 = prctile(new_samples_posterior, [2.5, 97.5]);

disp('Nuevo Intervalo de Credibilidad (95%) con nuevo prior:');
disp(array2table(new_credibility_interval_95, 'VariableNames', {'SST', 'SOS', 'CHL'}));

% Visualizar los intervalos de credibilidad para las distribuciones posteriores
figure;
subplot(1, 3, 1);
histogram(new_samples_posterior(:, 1), 50, 'FaceColor', 'b');
hold on;
xline(new_credibility_interval_95(1, 1), 'k:', 'LineWidth', 1.5, 'Label', '2.5%');
xline(new_credibility_interval_95(2, 1), 'k:', 'LineWidth', 1.5, 'Label', '97.5%');
title('SST - CI 95% con nuevo prior');

subplot(1, 3, 2);
histogram(new_samples_posterior(:, 2), 50, 'FaceColor', 'r');
hold on;
xline(new_credibility_interval_95(1, 2), 'k:', 'LineWidth', 1.5, 'Label', '2.5%');
xline(new_credibility_interval_95(2, 2), 'k:', 'LineWidth', 1.5, 'Label', '97.5%');
title('SOS - CI 95% con nuevo prior');

subplot(1, 3, 3);
histogram(new_samples_posterior(:, 3), 50, 'FaceColor', 'g');
hold on;
xline(new_credibility_interval_95(1, 3), 'k:', 'LineWidth', 1.5, 'Label', '2.5%');
xline(new_credibility_interval_95(2, 3), 'k:', 'LineWidth', 1.5, 'Label', '97.5%');
title('CHL - CI 95% con nuevo prior');

sgtitle('Intervalos de Credibilidad (CI) con nuevo prior');


%%
%% *** ANÁLISIS DE LA PROBABILIDAD DE DIFERENCIA ESPECÍFICA ***
% Se calcula la diferencia entre las muestras posterior y las medias climatológicas
diff_sst = samples_posterior(:, 1) - mu_prior(1);  % Diferencia SST
diff_sos = samples_posterior(:, 2) - mu_prior(2);  % Diferencia SOS
diff_chl = samples_posterior(:, 3) - mu_prior(3);  % Diferencia CHL

% Probabilidad de que la diferencia sea mayor que 0 (Wilma > Climatología)
prob_diff_sst_pos = mean(diff_sst > 0);  % Probabilidad SST
prob_diff_sos_pos = mean(diff_sos > 0);  % Probabilidad SOS
prob_diff_chl_pos = mean(diff_chl > 0);  % Probabilidad CHL

% Probabilidad de que la diferencia sea menor que 0 (Wilma < Climatología)
prob_diff_sst_neg = mean(diff_sst < 0);  % Probabilidad SST
prob_diff_sos_neg = mean(diff_sos < 0);  % Probabilidad SOS
prob_diff_chl_neg = mean(diff_chl < 0);  % Probabilidad CHL

% Probabilidad de que la diferencia esté dentro de un rango específico
% Definir un umbral para el rango de diferencia
threshold = 0.1;  % Puedes ajustar este valor según tus necesidades

prob_diff_sst_range = mean(abs(diff_sst) < threshold);  % Probabilidad SST dentro de umbral
prob_diff_sos_range = mean(abs(diff_sos) < threshold);  % Probabilidad SOS dentro de umbral
prob_diff_chl_range = mean(abs(diff_chl) < threshold);  % Probabilidad CHL dentro de umbral

% Mostrar resultados
disp('Probabilidad de que Wilma sea mayor que la climatología:');
disp(['SST: ', num2str(prob_diff_sst_pos)]);
disp(['SOS: ', num2str(prob_diff_sos_pos)]);
disp(['CHL: ', num2str(prob_diff_chl_pos)]);

disp('Probabilidad de que Wilma sea menor que la climatología:');
disp(['SST: ', num2str(prob_diff_sst_neg)]);
disp(['SOS: ', num2str(prob_diff_sos_neg)]);
disp(['CHL: ', num2str(prob_diff_chl_neg)]);

disp('Probabilidad de que la diferencia esté dentro del umbral especificado:');
disp(['SST (dentro de ', num2str(threshold), '): ', num2str(prob_diff_sst_range)]);
disp(['SOS (dentro de ', num2str(threshold), '): ', num2str(prob_diff_sos_range)]);
disp(['CHL (dentro de ', num2str(threshold), '): ', num2str(prob_diff_chl_range)]);

