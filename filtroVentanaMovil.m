function pesoFiltrado = filtroVentanaMovil(pesoPromediado)
    sizeVentanaMovil = 10;
    kgFiltroMovimiento = 100;
	salidaFiltro = 0;
    persistent priv_ventanaCargada;
    persistent variableEstatica;
    persistent indiceVentana;
    persistent priv_pesoFisicoAnterior;
    persistent pesoFiltrado_anterior;
    persistent vectorFiltro;

    if isempty(variableEstatica)
        priv_ventanaCargada = 0;
        variableEstatica = 1;
        indiceVentana = 1;
        priv_pesoFisicoAnterior = 0;
        pesoFiltrado_anterior = 0;
        vectorFiltro = zeros(1,100);
    endif

	priv_ventanaCargada++;
	if (priv_ventanaCargada > sizeVentanaMovil)
		priv_ventanaCargada = sizeVentanaMovil;
	endif
				
	if (kgFiltroMovimiento)
		salidaFiltro = abs(pesoPromediado - pesoFiltrado_anterior);
		if(salidaFiltro > converPesoToCuentas(kgFiltroMovimiento))
			priv_ventanaCargada = 1;
			indiceVentana = 1;
		endif
		priv_pesoFisicoAnterior = pesoPromediado;
	endif
		
	vectorFiltro(indiceVentana) = pesoPromediado;
	indiceVentana++;
		
	if(indiceVentana > sizeVentanaMovil)
		indiceVentana = 1;
	endif
		
	salidaFiltro = 0;
	for i = 1:priv_ventanaCargada
		salidaFiltro += vectorFiltro(i);
	endfor
	salidaFiltro /= priv_ventanaCargada;
    pesoFiltrado_anterior = salidaFiltro;
	pesoFiltrado = salidaFiltro;
end
