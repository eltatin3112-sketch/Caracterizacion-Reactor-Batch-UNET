Reactor Batch Automatizado: Caracterización de Mezcla Homogénea y Dinámica Térmica
1. Objetivo del Proyecto
Este proyecto tiene como finalidad la caracterización experimental de un Reactor Batch de escala industrial para la preparación de soluciones térmicas. El enfoque principal es cuantificar el acoplamiento entre la agitación mecánica (subsistema motorreductor) y la transferencia de calor (subsistema térmico).
El objetivo técnico es obtener los parámetros dinámicos del proceso (Ganancia, Constante de tiempo y Retardo) bajo diferentes regímenes de mezcla, permitiendo construir un modelo matemático fiel que sirva de base para el diseño de un controlador PID robusto.
1.1. Justificación en Sistemas de Control II
A diferencia de un calentamiento estático, este proyecto analiza cómo el transporte de masa (agitación) altera la eficiencia térmica. Se busca identificar:
La relación PWM-RPM del agitador y su zona muerta.
La mejora en la constante de tiempo térmica (tau) mediante convección forzada.
La reducción del tiempo muerto (theta) por homogeneización del fluido.
2. Componentes Utilizados
Para garantizar la precisión en la identificación de las variables, se ha seleccionado el siguiente hardware:
Unidad de Control: ESP32 DevKit V1 (Soporte nativo para interrupciones y PWM de alta resolución).
Subsistema Térmico: Resistencia de inmersión de 110V AC y Relé de Estado Sólido (SSR-50 DA).
Subsistema Mecánico: Motorreductor TT de 12V con hélice de agitación y Driver L298N.
Sensórica de Retroalimentación:
Sensor de temperatura digital DS18B20 (Bus One-Wire).
Encoder óptico FC-03 con disco de 20 ranuras (Medición de velocidad).
Alimentación: Fuente de poder ATX de PC (Rieles de 5V y 12V) y red eléctrica de 110V AC para el calefactor.
3. Advertencias Eléctricas (Seguridad Crítica)
PELIGRO DE ALTO VOLTAJE: El subsistema térmico opera con 110V AC. Bajo ninguna circunstancia se debe manipular el cableado de la resistencia o del SSR mientras el sistema esté energizado.
Aislamiento Galvánico: Se debe verificar que el Relé de Estado Sólido (SSR) proporcione aislamiento total entre el circuito de control (ESP32) y la red de 110V.
Voltajes Lógicos: Alimentar el sensor de temperatura DS18B20 y el encoder FC-03 estrictamente con 3.3V desde el pin 3V3 del ESP32. No conectarlos a 5V para evitar daños irreversibles en los pines GPIO.
Tierra Común (GND): Es obligatorio unificar el GND de la fuente ATX con el GND del ESP32 y el borne GND del driver L298N. Sin esta referencia común, el sensor de velocidad y las señales PWM presentarán inestabilidad.
Gestión Térmica: El MOSFET interno del L298N y el SSR pueden generar calor considerable bajo carga. Se recomienda el uso de disipadores de calor para pruebas de larga duración (>10 min).
Protección de Motores: Instalar un capacitor cerámico de 100nF entre los terminales del motor TT para filtrar el ruido electromagnético que podría afectar la red One-Wire del sensor de temperatura.
4. Tabla de Conexiones Propuesta
Pines definidos en el firmware para la placa ESP32 DevKit V1:
Origen (ESP32)	Pin / Señal	Destino	Notas
ESP32 GPIO25	D25	L298N ENA	Control de velocidad PWM Agitador
ESP32 GPIO26	D26	L298N IN1	Dirección de giro Agitador
ESP32 GPIO27	D27	L298N IN2	Dirección de giro Agitador
ESP32 GPIO33	D33	FC-03 D0	Entrada de pulsos (Encoder)
ESP32 GPIO4	D4	DS18B20 Data	Bus de datos Temperatura (Requiere Pull-up)
ESP32 GPIO18	D18	SSR Terminal 3 (+)	Mando del calefactor (Control PID)
ESP32 VIN	5V	Fuente ATX 5V	Alimentación de lógica (Cable Rojo)
ESP32 3V3	3.3V	VCC Sensores	Alimentación DS18B20 y FC-03
Fuente ATX 12V	12V	L298N VCC	Alimentación motor (Cable Amarillo)
Conexiones Prohibidas o No Recomendadas:
No conectar la resistencia de 110V directamente al ESP32 o al L298N.
No omitir la resistencia de pull-up (4.7k - 10k) en la línea de datos del sensor DS18B20.
No alimentar el motor TT desde el pin 3V3 del ESP32; la demanda de corriente causará el reinicio del controlador.
No alimentar el ESP32 con 12V por el pin VIN.
5. Estructura del Proyecto
El firmware está desarrollado bajo el entorno PlatformIO utilizando el framework de Arduino, lo que permite una gestión modular del código. La organización de archivos en el repositorio es la siguiente:
platformio.ini: Archivo de configuración del proyecto, definición de placa (esp32dev) y gestión de librerías.
src/main.cpp: Código fuente principal que contiene la máquina de estados para la caracterización.
include/config.h: Definición de constantes, pines de hardware y parámetros de red (WiFi/mDNS).
data/: Carpeta para el sistema de archivos LittleFS que aloja la interfaz web (HTML/JS) para la visualización de datos.
docs/: Contiene el Diagrama de Proceso (P&ID) y el esquema de conexiones detallado.
data/results.json: Archivo generado automáticamente donde se persisten los datos de las pruebas experimentales.
6. Librerías y Dependencias
Para el funcionamiento correcto del caracterizador, se han integrado las siguientes bibliotecas:
OneWire & DallasTemperature: Para la gestión del bus de datos y lectura del sensor digital DS18B20.
PID_v1: Implementación del algoritmo de control para el lazo térmico (utilizado en la fase de sostenimiento).
LittleFS: Para la gestión de almacenamiento de datos en la memoria flash del ESP32.
ESPAsyncWebServer: Para servir la interfaz de monitoreo inalámbrico en tiempo real.
ArduinoJson: Para la estructuración y exportación de los datos obtenidos en formato compatible con Excel/MATLAB.
7. Instrucciones de Compilación y Carga (PlatformIO)
Para reproducir el entorno de desarrollo, siga estos pasos en la terminal:
Compilar el código fuente:
code
Bash
pio run
Subir el firmware al ESP32:
code
Bash
pio run --target upload
Subir la interfaz web (Sistema de archivos LittleFS):
code
Bash
pio run --target uploadfs
Abrir el monitor serie para validar inicialización:
code
Bash
pio device monitor --baud 115200
Una vez cargado, el ESP32 anunciará su presencia en la red local mediante el protocolo mDNS, permitiendo el acceso a través de: http://reactor-batch.local o la dirección IP mostrada por el puerto serie.
8. Flujo de Calibración y Pruebas Manuales
Antes de iniciar la caracterización automática, se deben validar los límites operativos del hardware para garantizar la seguridad del recipiente de polímero:
8.1. Validación Mecánica del Agitador
Prueba de Giro: Ingresar un PWM de prueba (ej. 100) y verificar el sentido de giro. El fluido debe desplazarse hacia abajo para optimizar la mezcla.
Determinación de RPM Máximas: Llevar el motor al PWM 255 y verificar con el encoder que la velocidad sea estable y no genere salpicaduras excesivas fuera del reactor.
Identificación de Zona Muerta: Incrementar el PWM lentamente hasta que el agitador venza la fricción estática del agua. Este valor será registrado como pwm_min_arranque.
8.2. Validación de Seguridad Térmica
Prueba de Sensor: Verificar que la lectura del DS18B20 sea coherente con la temperatura ambiente.
Prueba de SSR: Realizar una activación manual breve (2 segundos) y observar el encendido del LED indicador del SSR y el incremento leve en la temperatura para validar el aislamiento galvánico.
9. Ejecución de la Caracterización Automática
El proceso de identificación experimental se divide en dos protocolos principales ejecutados por la máquina de estados del firmware:
9.1. Caracterización Mecánica (PWM vs RPM)
El sistema ejecutará cuatro rampas secuenciales para identificar el comportamiento dinámico del motorreductor bajo la carga del fluido:
Rampa Ascendente Adelante: Identifica el PWM de arranque.
Rampa Descendente Adelante: Identifica el PWM de sostenimiento y la histéresis mecánica.
Rampa Ascendente Atrás: Detecta asimetrías mecánicas en el motor.
Rampa Descendente Atrás: Finalización del ensayo mecánico.
9.2. Caracterización Térmica (Curva de Reacción)
Se realizarán pruebas de escalón (Step Response) para obtener los parámetros del modelo de primer orden con tiempo muerto (FOPDT). El experimento se repetirá bajo tres condiciones de mezcla:
Prueba A (Estática): Agitador al 0%. Se inyecta potencia a la resistencia y se registra la curva de temperatura.
Prueba B (Mezcla Media): Agitador al 50% de velocidad. Se analiza la reducción en la constante de tiempo (tau).
Prueba C (Mezcla Máxima): Agitador al 100% de velocidad. Se busca el retardo de transporte (theta) mínimo.
Criterio de Parada: Por seguridad del recipiente, toda prueba se detendrá automáticamente al alcanzar los 55 grados Celsius o tras un tiempo máximo de 15 minutos (timeout).
10. Gestión y Exportación de Resultados
Al finalizar los ensayos, el ESP32 procesará el archivo results.json alojado en LittleFS. El usuario podrá:
Visualizar la gráfica en tiempo real mediante la interfaz web (Chart.js).
Descargar el archivo XLSX para realizar el cálculo de parámetros dinámicos en Excel o MATLAB.
Validar la metadata del ensayo para asegurar que las condiciones de carga (volumen de agua) fueron constantes en todas las pruebas.
11. INTERPRETACIÓN DE RESULTADOS EXPERIMENTALES
Tras la ejecución de los protocolos de caracterización, el sistema permite identificar los parámetros clave para el diseño de los lazos de control:
11.1. Análisis del Agitador (Mecánico)
PWM Mínimo de Arranque: Representa el valor del ciclo de trabajo necesario para vencer el torque de fricción estática del motorreductor bajo la carga del fluido. Identificar este punto es vital para evitar el zumbido del motor sin rotación efectiva.
Histéresis Mecánica: Se determina comparando las rampas ascendentes y descendentes. Una diferencia significativa indica holguras en la caja reductora del motor TT o efectos de inercia del fluido que deben ser compensados por software.
Linealidad RPM vs PWM: Permite validar si la velocidad de agitación responde de forma lineal a la señal de mando, facilitando un control de velocidad posterior.
11.2. Análisis Térmico (Modelo FOPDT)
Mediante el método de la curva de reacción, se estiman los parámetros del modelo de Primer Orden con Tiempo Muerto para cada régimen de agitación:
Ganancia del Proceso (K): Relación entre el incremento de temperatura y el porcentaje de potencia inyectada.
Constante de Tiempo (tau): Tiempo requerido para que el fluido alcance el 63.2 por ciento de su variación total. Se espera que tau disminuya al aumentar la velocidad de agitación.
Tiempo Muerto (theta): El retraso entre la activación de la resistencia y la detección del cambio por el sensor DS18B20. Este valor se reduce al homogeneizar el fluido mediante agitación.
12. ANÁLISIS DE NO LINEALIDADES Y LIMITACIONES
El reactor batch presenta comportamientos no ideales que han sido cuantificados durante la caracterización:
Zona Muerta: Presente en el agitador (PWM menor a 40 aproximadamente) y en el sistema térmico debido a la inercia inicial de la resistencia.
Saturación: El sistema térmico encuentra un límite superior definido por el equilibrio entre la potencia de la resistencia y las pérdidas térmicas del recipiente hacia el ambiente.
Retardo de Transporte: Influenciado directamente por la posición física del sensor DS18B20 respecto a la resistencia de inmersión.
13. RELACIÓN CON EL MODELO EN ASPEN HYSYS V14
La caracterización física permite retroalimentar el modelo desarrollado en HYSYS bajo las siguientes premisas:
Ajuste del Coeficiente de Transferencia (U): Los datos experimentales de calentamiento bajo agitación permiten ajustar el valor del coeficiente global de transferencia de calor en el bloque Vessel de HYSYS para que la simulación dinámica sea fiel a la realidad.
Validación de Pérdidas de Calor (Heat Loss): La diferencia entre la curva ideal de HYSYS y la curva real medida identifica el flujo de calor perdido hacia el entorno, parámetro que se ingresa en el simulador para mejorar su capacidad de predicción.
Sintonía Pre-experimental: Las constantes dinámicas halladas (tau y theta) se cargan en el bloque TIC-100 de HYSYS para obtener sintonías preliminares de Kp, Ki y Kd, reduciendo el riesgo de errores térmicos en el prototipo físico.
14. REPRODUCIBILIDAD DEL PROYECTO DESDE CERO
Para replicar el entorno de caracterización del reactor batch, siga estos pasos:
Clonar el repositorio: Realice una copia local del proyecto desde GitHub.
Configuración de Credenciales: Cree un archivo include/config.h (basado en la plantilla proporcionada) e ingrese las credenciales de su red WiFi local.
Entorno de Desarrollo: Abra el proyecto en Visual Studio Code con la extensión PlatformIO instalada.
Preparación de Librerías: El archivo platformio.ini descargará automáticamente las dependencias (OneWire, DallasTemperature, ArduinoJson, etc.).
Compilación y Carga:
Ejecute el comando 'pio run' para compilar el firmware.
Use 'pio run --target upload' para subir el código al ESP32.
Use 'pio run --target uploadfs' para cargar la interfaz web y las librerías de gráficas al sistema de archivos LittleFS.
Validación: Abra el monitor serie a 115200 baudios para verificar la dirección IP asignada y el estado de los sensores.
15. MANTENIBILIDAD DEL CÓDIGO
El firmware se ha organizado siguiendo una arquitectura modular por bloques funcionales para facilitar futuras mejoras:
Bloque de Comunicación: Gestión de WiFi y protocolo mDNS para acceso por nombre (reactor-batch.local).
Servidor Web Asíncrono: Manejo de la interfaz de usuario y peticiones de datos en tiempo real.
Control de Actuadores: Implementación de señales PWM mediante el periférico LEDC del ESP32 para el motor TT y la resistencia.
Bus de Datos Digital: Lógica de lectura para el sensor DS18B20 y conteo de pulsos del encoder por interrupciones.
Máquina de Estados: Lógica central que gobierna las rampas de caracterización y las pruebas térmicas.
Persistencia de Datos: Gestión de archivos JSON en LittleFS para asegurar que los resultados no se pierdan ante reinicios del controlador.
16. CONCLUSIONES TÉCNICAS
El proceso de identificación experimental ha permitido obtener una base de datos sólida para modelar la dinámica multivariable del reactor farmacéutico.
Se ha validado cuantitativamente que la agitación mecánica es un factor determinante en la reducción del tiempo muerto y la constante de tiempo del sistema térmico, optimizando la homogeneidad de la mezcla.
La integración del ESP32 como estación de telemetría facilita la captura de datos de alta resolución, superando las limitaciones de los métodos de recolección manual.
El contraste entre los datos reales obtenidos y el modelo dinámico en Aspen HYSYS garantiza que el diseño final del controlador PID sea robusto y se adapte a las no linealidades físicas del prototipo construido.
Universidad Nacional Experimental del Táchira (UNET) - 2024
Departamento de Ingeniería Electrónica
Sistemas de Control II
