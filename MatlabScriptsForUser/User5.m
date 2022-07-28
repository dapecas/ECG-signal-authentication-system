clear all
clc
close all

%%Cargar los valores
load("16483m.mat");

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
%%Eliminación de continua
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
plot(noisyECG_withTrend, MarkerFaceColor= 'r');

% Enventanado de la señal
w=3*fs
num_w=500;
z = 0;

for i = 1:num_w
(i-1)*w+1
(i)*w
temp=ECG_filtered((i-1)*w+1:(i)*w);

    %%Se buscan picos QRS
    %Detección Puntos Característico R
    [Amp_Rwave, locs_Rwave] = findpeaks(temp, MinPeakHeight=100, MinPeakDistance=40);

    %figure();
    %plot(temp);
    %hold on;
    %plot(locs_Rwave, temp(locs_Rwave),'rv', MarkerFaceColor='r');
    
    %Detección Puntos Característico S
    [Amp_Swave, locs_Swave] = findpeaks(-temp, MinPeakHeight=50, MinPeakDistance=40);

    %Detección Puntos Característico Q
    [min_amp,min_locs] = findpeaks(-temp, MinPeakHeight=50, MinPeakDistance=0.9);
    locs_Qwave = min_locs(temp(min_locs)>-min(Amp_Swave) & temp(min_locs)<-50);
    Amp_Qwave = min_amp(temp(min_locs)>-min(Amp_Swave) & temp(min_locs)<-50);

    %figure();
    %plot(temp);
    %hold on;
    %plot(locs_Swave, temp(locs_Swave),'rv', MarkerFaceColor='b');
    
   if(i==1)
       figure();
       plot(temp);
       hold on;
       plot(locs_Swave, temp(locs_Swave),'rv', MarkerFaceColor='g');
       plot(locs_Rwave, temp(locs_Rwave),'rv', MarkerFaceColor='r');
       plot(locs_Qwave, temp(locs_Qwave),'rv', MarkerFaceColor='b');
   end

    %%Extracción de características (descarte cuando no se detecta un pico)
    if (length(locs_Qwave)==length(locs_Rwave) && length(locs_Rwave)==length(locs_Swave)...
            && length(Amp_Qwave)==length(Amp_Rwave) && length(Amp_Rwave)==length(Amp_Swave)) 
        avr_riseTime(i) = mean(locs_Rwave-locs_Qwave);
        avr_fallTime(i) = mean(locs_Swave-locs_Rwave);
        avr_riseLevel(i) = mean(Amp_Rwave-Amp_Qwave);
        avr_fallLevel(i) = mean(Amp_Swave-Amp_Rwave);
    else
        z = z+1;
        %figure();
        %plot(temp);
        %hold on;
        %plot(locs_Swave, temp(locs_Swave),'rv', MarkerFaceColor='g');
        %plot(locs_Rwave, temp(locs_Rwave),'rv', MarkerFaceColor='r');
        %plot(locs_Qwave, temp(locs_Qwave),'rv', MarkerFaceColor='b');
    end
end

T1 = table(avr_riseTime);
T2 = table(avr_fallTime);
T3 = table(avr_riseLevel);
T4 = table(avr_fallLevel);
writetable(T1, 'RiseTime4.txt');
writetable(T2, 'FallTime4.txt');
writetable(T3, 'RiseLevel4.txt');
writetable(T4, 'FallLevel4.txt');