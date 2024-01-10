function y_filtrada = filtroPromedio(x, n)
    N = length(x);
    num_segmentos = floor(N/n);
    y_filtrada = zeros(1, num_segmentos);


    for i = 1:num_segmentos
        % Calcular el promedio de los siguientes 'n' valores
        inicio_segmento = (i-1)*n + 1;
        fin_segmento = i*n;
        y_filtrada(i) = mean(x(inicio_segmento:fin_segmento));
    end
end
