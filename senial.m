% Datos del ensayo, de una descarga lineal
% Se pueden modificar

velocidad_adc = 80; % muestras por segundo
t_final = 120;  % Duración del ensayo
frecuencia_alta = 100;  % Puedes ajustar esta frecuencia según tus necesidades
amplitud_ruido_alta = 5; % Puedes ajustar esta amplitud según tus necesidades
amplitud_ruido_aleatorio = 25;
desface = pi/sqrt(2); % Desface ajustable
fs = 1000;  % Frecuencia de muestreo para comparar la realidad vs adc

% Filtros
conversiones = 10; % de 1 a 99
recortes = 2;
ventana_movil = 10;
kg_filtro = 100;

% Ruido generado por pozos, son vectores y los 3 deben ocupar el mismo espacio
pozos = [10, 20,50,55,85, 100,35]; % el segundo exacto donde se piza el pozo, pueden ser varios
amplitud_de_los_pozos = [-500, 1000, 500,500, 1000, 500,100]; % pico máximo que genera el pozo en kilos
amortiguacion_de_los_pozos = [0.5, 0.8 ,1,1,1, 1,0.3]; % taza de amortiguacion, mientras mas chica los efectos del rebote se siguen sintiendo, minimo 0 se siente para siempre, maximo 10segundos


% Algoritmos, no cambiar
% Definir los parámetros
t = 0:1/fs:t_final-1/fs;  % Vector de tiempo
t_adc = 0:1/velocidad_adc:t_final-1/velocidad_adc;  % Vector de tiempo
fin_ensayo = t_final-(1/velocidad_adc);

% Generar la señal descendente
% senial_descendente = linspace(5000, 1000, length(t));
 senial_descendente = 5000 - (833) * log(1 + t);


% Agregar ruido de alta frecuencia
ruido_alta_frecuencia = amplitud_ruido_alta * sin(2*pi*frecuencia_alta*t+desface);
senial_con_ruido = senial_descendente + ruido_alta_frecuencia;

% Ruido aleatorio
ruido_aleatorio = amplitud_ruido_aleatorio * randn(size(t));
senial_con_ruido = senial_con_ruido + ruido_aleatorio;


% agregar pozos
duracion_pozos = 10;
t_pozo = 0:1/fs:duracion_pozos-1/fs;

% Crear una matriz para almacenar los vectores
% matriz_de_vectores = zeros(length(pozos), length(t_pozo));  % Por ejemplo, cada vector tiene 10 elementos
matriz_de_vectores = zeros(length(pozos), length(t));  % Por ejemplo

% Llenar la matriz con vectores aleatorios (puedes ajustar esto según tus necesidades)
for i = 1:length(pozos)
    A = zeros(1,pozos(i)*fs);
    B = amplitud_de_los_pozos(i) * sin(2 * pi * 1 * t_pozo) .* exp(-1 * amortiguacion_de_los_pozos(i) * t_pozo);
    C = zeros(1, length(t)-(pozos(i)+10)*fs);
    matriz_de_vectores(i, :) = [A,B,C];
    senial_con_ruido = senial_con_ruido + [A,B,C];
end

% interpolar el vector de señal para que sea muestreado a la velocidad del adc
vector_normalizado = interp1(t, senial_con_ruido, 0:1/(velocidad_adc):fin_ensayo);
vector_adc =vector_normalizado; 


% Graficar la señal como la ve el ADC
figure('Position', [0, 0, 1200, 800]);  % [left, bottom, width, height]
hold on;
plot(0:1/(velocidad_adc):fin_ensayo, vector_normalizado, 'LineWidth', 2, 'DisplayName', 'Señal ADC');
title('Señal ADC');
xlabel('Tiempo (s)');
ylabel('Amplitud');
legend('Location', 'southwest');
grid on;
hold off;

%{
% Graficar la señal original
figure('Position', [0, 0, 1200, 800]);  % [left, bottom, width, height]
plot(t, senial_descendente, 'LineWidth', 2, 'DisplayName', 'Señal Descendente');
hold on;
title('Señal Original');
xlabel('Tiempo (s)');
ylabel('Amplitud');
legend('Location', 'southwest');
grid on;
hold off;


% Graficar la señal con ruido
figure('Position', [0, 0, 1200, 800]);  % [left, bottom, width, height]
hold on;
plot(t, senial_con_ruido, 'LineWidth', 1, 'DisplayName', 'Señal con Ruido');
title('Señal con Ruido');
xlabel('Tiempo (s)');
ylabel('Amplitud');
legend('Location', 'southwest');
grid on;
hold off;

% Guardar en un archivo de encabezado (.h)
fid = fopen('datos.h', 'w');
fprintf(fid, 'const double adc_ensayo[] = {');
fprintf(fid, '%d, ', vector_normalizado(1:end-1));
fprintf(fid, '%d};\n', vector_normalizado(end));
fclose(fid);
%}

%{
conversiones = 10;
recortes = 2;
ventana_movil = 10;
kg_filtro = 100;
%}

vector_filtrado = zeros(1,length(vector_adc));
for i=1:length(vector_adc)
%    disp(i);
%    disp(setAdcCuenta(vector_adc(i)))
    vector_filtrado(i) = setAdcCuenta(vector_adc(i),conversiones,recortes);
    % if(i == 51)
    % break;
    % endif
endfor

disp(length(vector_adc)) %= 9600
disp(length(vector_filtrado)) %= 9600

%disp(vector_filtrado)

t_convertio = (conversiones/velocidad_adc):conversiones/(length(vector_filtrado))*(fin_ensayo):fin_ensayo;
t_promediado = 0:1/(length(vector_filtrado)-1)*(fin_ensayo):fin_ensayo;

disp(length(t_convertio)) %= 961

disp(length(t_promediado)) %= 9600



vector_filtrado_acotado = interp1(t_promediado, vector_filtrado, t_convertio);

% Graficar la señal filtrada
figure('Position', [0, 0, 1200, 800]);  % [left, bottom, width, height]
hold on;
plot(0:1/(velocidad_adc):fin_ensayo, vector_filtrado, 'LineWidth', 2, 'DisplayName', 'Señal ADC');
plot(0:1/(velocidad_adc):fin_ensayo, vector_normalizado, 'LineWidth', 2, 'DisplayName', 'Señal ADC');
plot(t_convertio ,vector_filtrado_acotado,'LineWidth', 2, 'DisplayName', 'Señal ADC Real');
title('Señal Filtro conversiones ADC');
xlabel('Tiempo (s)');
ylabel('Amplitud');
legend('Location', 'southwest');
grid on;
hold off;


pause;
