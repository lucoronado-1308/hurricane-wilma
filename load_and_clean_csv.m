function data = load_and_clean_csv(filename)
    % Cargar datos desde archivo CSV
    data = readtable(filename);

    % Reemplazar celdas vacías con NaN
    data = standardizeMissing(data, {'', 'NA', 'N/A'});
    
    % Llenar NaN con el promedio del vecino más cercano
    data = fillmissing(data, 'nearest');
end
