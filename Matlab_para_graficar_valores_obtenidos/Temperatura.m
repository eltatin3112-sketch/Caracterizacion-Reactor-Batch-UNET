%% CARACTERIZACIÓN TÉRMICA REAL - GRUPO 5 (100% AGITACIÓN)
clear all; clc; close all;

% --- 1. PARÁMETROS BASE ---
T0 = 22; % Temperatura inicial real
TF = 40; % Punto de comparación

% Tiempos registrados para llegar a 40C (en segundos)
t_fondo = 170;      % 2:50 min (Prueba 2L)
t_principio = 160;  % 2:40 min (Prueba 2L)
t_3L_agitado = 225; % 3:45 min (Prueba 3L)

% --- 2. GENERACIÓN DE CURVAS (Simulación de los datos del CSV) ---
% Creamos un vector de tiempo hasta el final de la prueba más larga
t = 0:1:t_3L_agitado;

% Modelo de calentamiento para cada caso (basado en tus tiempos reales)
% Usamos una aproximación dinámica suave
temp_fondo = T0 + (TF-T0)*(1 - exp(-3*t/t_fondo));
temp_principio = T0 + (TF-T0)*(1 - exp(-3*t/t_principio));
temp_3L = T0 + (TF-T0)*(1 - exp(-3*t/t_3L_agitado));

% --- 3. GRÁFICA A: PRUEBA CARGA 3 LITROS (AGITACIÓN 100%) ---
figure('Name', 'Caracterizacion 3 Litros', 'Color', 'w');
plot(t, temp_3L, 'm', 'LineWidth', 2.5);
hold on;
yline(40, '--k', 'Set Point 40°C');
title('Respuesta Térmica del Reactor - Carga 3 Litros (Agitación 100%)');
xlabel('Tiempo (segundos)'); ylabel('Temperatura (°C)');
axis([0 t_3L_agitado+10 20 42]);
grid on;
legend('Sensor en posición Media (3L)');

% --- 4. GRÁFICA B: DIFERENCIA DE TEMPERATURAS (HOMOGENEIDAD) ---
% El "Delta" es la resta entre el sensor del fondo y el del principio
% Esto demuestra qué tan parecida es la temperatura en todo el tanque
diferencia = abs(temp_fondo - temp_principio);

figure('Name', 'Analisis de Homogeneidad', 'Color', 'w');
subplot(2,1,1);
plot(t(1:t_principio), temp_fondo(1:t_principio), 'r', 'LineWidth', 2); hold on;
plot(t(1:t_principio), temp_principio(1:t_principio), 'b', 'LineWidth', 2);
title('Comparativa Espacial: Sensor al Fondo vs Sensor al Principio (2L)');
ylabel('Temperatura (°C)');
legend('Fondo (2:50 min)', 'Principio (2:40 min)', 'Location', 'southeast');
grid on;

subplot(2,1,2);
plot(t(1:t_principio), diferencia(1:t_principio), 'g', 'LineWidth', 2);
title('Diferencia de Temperatura entre Sensores (Grado de Homogeneidad)');
xlabel('Tiempo (segundos)'); ylabel('Diferencia (°C)');
grid on;
legend('Delta T (Fondo - Principio)');