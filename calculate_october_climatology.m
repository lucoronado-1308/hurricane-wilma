function climatology = calculate_october_climatology(data, dateColumn, variableColumn)
    % Asegúrate de que las fechas estén en formato datetime
    data.Date = datetime(data.(dateColumn), 'InputFormat', 'dd/MM/yyyy');
    
    % Filtrar los datos para el mes de octubre
    octoberData = data(month(data.Date) == 10, :);
    
    % Calcular el promedio de la variable para octubre
    climatology = mean(octoberData.(variableColumn), 'omitnan');
end
