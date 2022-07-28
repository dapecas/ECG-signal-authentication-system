clear all
clc
close all

%%%%%%%%SEÑAL NO UTILIZADA%%%%%%%%

%Cargar los valores
load("16272m.mat");

noisyECG_withTrend = val(1,:);

t = length(noisyECG_withTrend);
fs = 128;
long_sg = t/fs;

figure()
plot(noisyECG_withTrend, MarkerFaceColor= 'r')
title("Señal original");   %Figura pintada de la señal ECG original
grid on
hold on

%Preprocesado de los datos
%Eliminación de continua
ECG_mean = noisyECG_withTrend - mean(noisyECG_withTrend);
plot(ECG_mean, MarkerFaceColor= 'g');

ECG_detrended = detrend(ECG_mean);
plot(ECG_detrended, MarkerFaceColor= 'b');

%%Filtradod e la señal entre 2 y 20 Hz
fc_low = 2;
fc_high = 20;

[b,a] = butter(3,[fc_low,fc_high]/(fs/2),"bandpass");
ECG_filtered = filtfilt(b,a,ECG_detrended);

figure()
plot(ECG_filtered, MarkerFaceColor= 'b');
xlabel("Muestras");
ylabel("Voltaje(mV)");
title("Preprocesado ECG");  %Figura de la señal sin componente continua ni frecuencias indeseadas
hold on;
plot(noisyECG_withTrend, MarkerFaceColor= 'r'); %Comparación con la señal original