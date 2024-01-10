

function y_filtrada = setAdcCuenta(adc, sizeConversiones, sizeRecortes)

    persistent auxAdc;
    persistent vectorPesos;
    persistent priv_index_vector_promedios;
    persistent pesoPromediado;
    persistent variableEstatica;


    if isempty(variableEstatica)
        auxAdc = 0;
        vectorPesos = zeros(1,100);
        priv_index_vector_promedios = 1;
        pesoPromediado = 0;
        variableEstatica = 1;
    endif


	flagSort = 0;
	adcPromedio = 0;
	
%{
	if (adc > 0x40000)//40000)
	{
		adc = (0x80000-adc);
		adc *= -1;
		//adc = adc & 0x0007ffff;
	}
%}
		
	vectorPesos(priv_index_vector_promedios) = adc;
	priv_index_vector_promedios++;
	if priv_index_vector_promedios > sizeConversiones
		priv_index_vector_promedios = 1;
		% Sort
		flagSort = 1;
		while flagSort == 1
			flagSort = 0;
			for i = 1:sizeConversiones
				if vectorPesos(i) > vectorPesos(i+1)
					auxAdc = vectorPesos(i);
					vectorPesos(i) = vectorPesos(i+1);
					vectorPesos(i+1) = auxAdc;
					flagSort = 1;
				endif
			endfor
		endwhile
		
		if 2*sizeRecortes < sizeConversiones
			for i = sizeRecortes+1:sizeConversiones-sizeRecortes
				adcPromedio += vectorPesos(i);
			endfor
			adcPromedio /= (sizeConversiones-(2*sizeRecortes));		
		else
			for i = 1:sizeConversiones
				adcPromedio += vectorPesos(i);
			endfor
			adcPromedio /= (sizeConversiones);
		endif	
		pesoPromediado = adcPromedio;	
	endif
    y_filtrada = pesoPromediado;
end
