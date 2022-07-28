clear all
clc
close all   %Comandos para reiniciar y borrar las variables y ventanas externas

%Cargar los valores
load("16265m.mat"); %Carga de los valores usados - ECG usada

noisyECG_withTrend = val(1,:);  %Guardado de la seÃ±al

t = length(noisyECG_withTrend); %DuraciÃ³n de la senal ECG
fs = 128;   %Frecuencia de muestreo
long_sg = t/fs; %DuraciÃ³n de la seÃ±al ECG en segundos

figure()
plot(noisyECG_withTrend, MarkerFaceColor= 'r')
title("SeÃ±al original");   %Figura pintada de la seÃ±al ECG original
grid on
hold on

%Preprocesado de los datos
%%EliminaciÃ³n de continua
ECG_mean = noisyECG_withTrend - mean(noisyECG_withTrend);   %Resta de la seÃ±al original con la media de la seÃ±al
plot(ECG_mean, MarkerFaceColor= 'g');   %Se puede ver cÃ³mo este recalculo no realiza grandes cambios ya que las seÃ±ales se superponen, tintando la grÃ¡fica de amarillo

ECG_detrended = detrend(ECG_mean);  %EliminaciÃ³n de la tendencia lineal de los datos
plot(ECG_detrended, MarkerFaceColor= 'b');   %ComparaciÃ³n con la seÃ±al original, color azul

%%Filtradod e la seÃ±al entre 2 y 20 Hz
fc_low = 2; %Frecuencia de corte inferior
fc_high = 20;   %Frecuencia de corte superior

[b,a] = butter(3,[fc_low,fc_high]/(fs/2),"bandpass");   %Filtro Butterworth - paso banda
ECG_filtered = filtfilt(b,a,ECG_detrended); %Guardado de la seÃ±al filtrada

figure()
plot(ECG_filtered, MarkerFaceColor= 'b');
xlabel("Muestras");
ylabel("Voltaje(mV)");
title("Preprocesado ECG");  %Figura de la seÃ±al sin componente continua ni frecuencias indeseadas
hold on;
plot(noisyECG_withTrend, MarkerFaceColor= 'r'); %ComparaciÃ³n con la seÃ±al original

% Enventanado de la seÃ±al
w=3*fs  %TamaÃ±o de la ventana
num_w=500;  %NÃºmero de ventanas
z = 0;  %InicializaciÃ³n del contador de datos inservibles

for i = 1:num_w %Comienzo del bucle "for" para extraer caracterÃ­sticas en las ventanas
(i-1)*w+1
(i)*w
temp=ECG_filtered((i-1)*w+1:(i)*w); %SeÃ±al recortada durante cada ventana

    %%Se buscan picos QRS
    %DetecciÃ³n Puntos CaracterÃ­stico R
    [Amp_Rwave, locs_Rwave] = findpeaks(temp, MinPeakHeight=50, MinPeakDistance=40);

    %figure();
    %plot(temp);
    %hold on;
    %plot(locs_Rwave, temp(locs_Rwave),'rv', MarkerFaceColor='r');
    
    %DetecciÃ³n Puntos CaracterÃ­stico Q
    [Amp_Qwave, locs_Qwave] = findpeaks(-temp, MinPeakHeight=110, MinPeakDistance=40);

    %DetecciÃ³n Puntos CaracterÃ­stico S
    [min_amp,min_locs] = findpeaks(-temp, MinPeakHeight=100, MinPeakDistance=0.9);
    locs_Swave = min_locs(temp(min_locs)>-min(Amp_Qwave) & temp(min_locs)<-100);    %ExtracciÃ³n de las localizaciones a partir de MÃ­nimos y MÃ¡ximos en las amplitudes
    Amp_Swave = min_amp(temp(min_locs)>-min(Amp_Qwave) & temp(min_locs)<-100);  %ExtracciÃ³n de las amplitudes a partir de MÃ­nimos y MÃ¡ximos en las amplitudes

    %figure();
    %plot(temp);
    %hold on;
    %plot(locs_Swave, temp(locs_Swave),'rv', MarkerFaceColor='b');
    
   if(i==10)    %VisiÃ³n de una ventana aleatoria del estudio
       figure();
       plot(temp);
       hold on;
       plot(locs_Swave, temp(locs_Swave),'rv', MarkerFaceColor='g');
       plot(locs_Rwave, temp(locs_Rwave),'rv', MarkerFaceColor='r');
       plot(locs_Qwave, temp(locs_Qwave),'rv', MarkerFaceColor='b');
    end
    
    %%ExtracciÃ³n de caracterÃ­sticas (descarte cuando no se detecta un pico)
    if (length(locs_Qwave)==length(locs_Rwave) && length(locs_Rwave)==length(locs_Swave)...
            && length(Amp_Qwave)==length(Amp_Rwave) && length(Amp_Rwave)==length(Amp_Swave))    %Condicional para extracciÃ³n de caracterÃ­sticas
        avr_riseTime(i) = mean(locs_Rwave-locs_Qwave);  %ExtracciÃ³n del tiempo que la seÃ±al tarda en subir (de Q a R)
        avr_fallTime(i) = mean(locs_Swave-locs_Rwave);  %ExtracciÃ³n del tiempo que la seÃ±al tarda en bajar (de R a S)
        avr_riseLevel(i) = mean(Amp_Rwave-Amp_Qwave);   %ExtracciÃ³n de la diferencia entre amplitudes (de Q a R)
        avr_fallLevel(i) = mean(Amp_Swave-Amp_Rwave);   %ExtracciÃ³n de la diferencia entre amplitudes (de R a S)
    else
        z = z+1;    %Contador de valores inservibles - Se guarda un 0
        %figure();
        %plot(temp);
        %hold on;
        %plot(locs_Swave, temp(locs_Swave),'rv', MarkerFaceColor='g');
        %plot(locs_Rwave, temp(locs_Rwave),'rv', MarkerFaceColor='r');
        %plot(locs_Qwave, temp(locs_Qwave),'rv', MarkerFaceColor='b');
    end
end

T1 = table(avr_riseTime);   %CreaciÃ³n de una tabla para guardar los datos
T2 = table(avr_fallTime);
T3 = table(avr_riseLevel);
T4 = table(avr_fallLevel);
writetable(T1, 'RiseTime1.txt');    %Escritura de los datos de tiempo de subida en un fichero txt
writetable(T2, 'FallTime1.txt');    %Escritura de los datos de tiempo de bajada en un fichero txt
writetable(T3, 'RiseLevel1.txt');   %Escritura de los datos de diferencia de amplitudes de subida en un fichero txt
writetable(T4, 'FallLevel1.txt');   %Escritura de los datos de diferencia de amplitudes de bajada en un fichero txt
