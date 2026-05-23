function filteredData = filter_by_date(data, dateColumn, startDate, endDate)
    % Convertir columna de fechas a formato datetime
    data.Date = datetime(data.(dateColumn), 'InputFormat', 'dd/MM/yyyy');
    % Filtrar filas dentro del rango de fechas
    filteredData = data(data.Date >= startDate & data.Date <= endDate, :);
end
