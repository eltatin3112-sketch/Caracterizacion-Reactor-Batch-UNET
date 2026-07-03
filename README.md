# CARACTERIZADOR DINAMICO: REACTOR BATCH G5
## Identificacion Experimental de Mezcla y Transferencia Termica

---

### 1. OBJETIVO DEL PROYECTO
Este proyecto utiliza un microcontrolador ESP32 DevKit V1 con PlatformIO para la caracterizacion experimental de un reactor batch farmaceutico a escala. El objetivo principal es identificar la relacion dinamica entre el subsistema de agitacion mecanica y la respuesta termica del fluido.

A traves de ensayos de escalon, se busca cuantificar como la velocidad de mezcla (RPM) influye en la homogeneidad del fluido y altera los parametros del modelo FOPDT (Ganancia, Constante de Tiempo y Retardo). Esta fase es crucial para obtener datos reales que permitan sintonizar un controlador PID robusto, capaz de compensar las ineficiencias termicas y las perdidas de calor ambientales identificadas durante las pruebas.

---

### COMPONENTES USADOS
* **Microcontrolador:** ESP32 DevKit V1 (Nucleo de procesamiento y telemetria).
* **Subsistema de Agitacion:** Motorreductor TT de 12V con helice de alambre personalizada.
* **Etapa de Calentamiento:** Resistencia de inmersion de 110V AC gestionada por Rele de Estado Solido (SSR-50 DA).
* **Driver de Motores:** Puente H L298N (Gestion de PWM para el agitador).
* **Sensor de Temperatura:** Digital DS18B20 con encapsulado sumergible de acero inoxidable.
* **Sensor de Velocidad:** Encoder infrarrojo FC-03 con disco de 20 ranuras.
* **Suministro Electrico:** Fuente de poder ATX reciclada (Rieles de 5V y 12V DC).
* **Recipiente de Proceso:** Jarra de polimero de 3.5 Litros (Carga operativa de 1 a 3 litros).

---

###  2. ADVERTENCIAS ELECTRICAS Y DE SEGURIDAD

* **PELIGRO DE ALTO VOLTAJE:** El sistema maneja 110V AC para la resistencia. No manipular el cableado del SSR ni de la resistencia mientras el equipo este conectado a la red electrica.
* **PROTECCION DE LA PLACA:** Alimentar el ESP32 estrictamente con 5V por el pin VIN desde la fuente ATX. No utilizar el pin de 3.3V como entrada de energia.
* **SENSORES Y LOGICA:** Los sensores DS18B20 y FC-03 operan a 3.3V. No conectarlos al riel de 5V o a los 12V de los motores para evitar daños en los pines GPIO.
* **TIERRA COMUN:** Es obligatorio unir el cable negro (GND) de la fuente ATX con el pin GND del ESP32 y el borne GND del L298N. La falta de una referencia comun provocara lecturas erroneas en el encoder.
* **RESISTENCIA PULL-UP:** El sensor de temperatura requiere una resistencia de 4.7k o 10k Ohmios entre el cable de datos y los 3.3V para un funcionamiento correcto del bus One-Wire.
* **SEGURIDAD TERMICA:** No activar la resistencia de inmersion fuera del agua. El componente puede alcanzar temperaturas de fusion en segundos y causar daños estructurales al reactor o quemaduras al operador.
* **RUIDO INDUCTIVO:** Se recomienda instalar un capacitor de 100nF en los terminales del motor TT para evitar interferencias que bloqueen la comunicacion digital de los sensores.
---

### 3. TABLA DE CONEXIONES Y PINOUT
Pines asignados en el firmware para el controlador **ESP32 DevKit V1**:

* `GPIO 25` -> `L298N_ENA` (PWM Agitador)
* `GPIO 26` -> `L298N_IN1` (Dirección Agitador)
* `GPIO 27` -> `L298N_IN2` (Dirección Agitador)
* `GPIO 33` -> `ENCODER_D0` (Interrupción RPM)
* `GPIO 04` -> `DS18B20_DATA` (Bus One-Wire Temperatura)
* `GPIO 18` -> `SSR_CONTROL` (Disparo del Calefactor)
* `GPIO 21` -> `LCD_SDA` (Interfaz I2C)
* `GPIO 22` -> `LCD_SCL` (Interfaz I2C)

#### Matriz Mínima de Cableado

| Conexión Origen | Señal / Pin | Destino Hardware | Notas Técnicas |
| :--- | :--- | :--- | :--- |
| **Fuente ATX** | `+5V` (Rojo) | ESP32 `VIN` | Alimentación de lógica de control |
| **Fuente ATX** | `+12V` (Amarillo) | L298N `VCC` | Potencia para el motor TT |
| **Fuente ATX** | `GND` (Negro) | **GND COMÚN** | Unión de todas las tierras del sistema |
| **ESP32** | `3V3` | `VCC` Sensores | Alimentación para FC-03 y DS18B20 |
| **ESP32** | `GPIO 25` | L298N `ENA` | Requiere remoción de jumper en driver |
| **ESP32** | `GPIO 18` | SSR `Pin 3 (+)` | Mando DC para etapa de 110V AC |
| **L298N** | `OUT1 / OUT2`| Motor TT | Conexión directa a bornes del motor |
| **Enchufe 110V**| `Fase` | SSR `Pin 1` | Interrupción de potencia AC |

---

### 4. CONEXIONES PROHIBIDAS O NO RECOMENDADAS

> [!CAUTION]
> **SEGURIDAD ELÉCTRICA Y ELECTRÓNICA**
> * **NO** alimentar el encoder FC-03 con 5V si se conecta al ESP32 (usar estrictamente 3.3V).
> * **NO** conectar la resistencia de 110V AC directamente al ESP32 o a la protoboard.
> * **NO** omitir el nodo de tierra común (GND) entre la fuente ATX y el ESP32.
> * **NO** encender la resistencia de inmersión si el sensor ultrasónico indica bajo nivel de fluido.
> * **NO** utilizar los pines GPIO 6 al 11, ya que están integrados a la memoria flash del ESP32.

---

### 5. CONFIGURACIÓN WIFI Y TELEMETRÍA

El sistema utiliza un servidor web asíncrono para la captura de datos. Las credenciales se gestionan en un archivo independiente para seguridad.

**Archivo:** `include/config.h` (Excluido por `.gitignore`)

*   **AP_SSID:** "Reactor_Batch_G5"
*   **AP_PASSWORD:** "control_industrial"
*   **IP Estática:** `192.168.4.1`

---

### 6. ESTRUCTURA DEL PROYECTO

Organización de archivos bajo el estándar de **PlatformIO**:

*   **platformio.ini**: Configuración de dependencias y entorno.
*   **src/main.cpp**: Lógica central, algoritmo PID y servidor web.
*   **include/config.h**: Definición de pines y credenciales de red.
*   **data/index.html**: Interfaz gráfica del usuario (HMI).
*   **data/app.js**: Lógica de gráficas y telemetría en JavaScript.
*   **data/style.css**: Diseño visual del panel de control.
*   **data/xlsx.full.min.js**: Librería local para exportación a Excel.
*   **data/chart.umd.min.js**: Librería local para gráficas offline.

---

### 7. INSTRUCCIONES DE DESARROLLO

Siga esta secuencia de comandos en la terminal de VS Code para cargar el sistema:

1. **Compilar el código fuente:** `pio run`
2. **Subir el Firmware al ESP32:** `pio run --target upload`
3. **Subir Interfaz Web (LittleFS):** `pio run --target uploadfs`
4. **Abrir Monitor Serial:** `pio device monitor --baud 115200`

---

### 8. VALIDACIÓN DE LIBRERÍAS LOCALES

Para asegurar el funcionamiento en entornos industriales sin internet, las librerías se alojan en la memoria flash. Al abrir el HMI, verifique el estado en la sección de diagnóstico:

*   **Chart.js local:** cargado
*   **SheetJS local:** cargado
*   **Modo offline:** OK

> [!TIP]
> Si las librerías aparecen como "no cargado", asegúrese de haber ejecutado el comando `uploadfs` correctamente.

---

### 9. INTERPRETACIÓN DE RESULTADOS

A través del HMI y los datos exportados en XLSX, el grupo identificará:

*   **PWM Mínimo de Arranque:** Identificación de la zona muerta del agitador bajo carga.
*   **Histéresis Mecánica:** Comparación de rampas ascendentes y descendentes del motor TT.
*   **Constante de Tiempo (Tau):** Inercia térmica del reactor identificada al 63.2% del ascenso.
*   **Tiempo Muerto (Theta):** Retardo de transporte entre la resistencia y el sensor DS18B20.

---
### 10. Flujo de calibración manual de voltaje

Para **voltaje_pwm255_v**:

1. Abrir la interfaz web del ESP32 en el navegador.
2. Deslizar el control de **AGITADOR (RPM)** hasta el valor máximo (**255**).
3. Medir con un multímetro el voltaje real en los bornes del motor (salida del L298N).
4. Ingresar ese valor en el formulario de metadata del HMI (ej. 9.25V).
5. Regresar el slider a **0** para detener el motor.

Estos voltajes son metadata del ensayo para compensar la caída de tensión interna del driver y no se usan como columnas repetidas por fila en el archivo de datos.

---


### 11. Prueba manual de motor y resistencia

La interfaz web permite validar el cableado básico del sistema antes de realizar la caracterización automática:

1. Deslizar el control de **AGITADOR (RPM)** entre **0 y 255**.
2. Verificar el giro físico del motor y la formación de turbulencia en el fluido.
3. Deslizar el control de **Potencia Térmica** (Ciclo de trabajo del SSR).
4. Verificar visualmente SSR se active y comience el calentamiento.
5. Regresar ambos sliders a la posición **0** para confirmar el apagado inmediato.

Si el flujo del fluido no es ascendente/descendente según el diseño de la hélice, intercambiar los cables del motor en las salidas del driver L298N.

---


### 12. Timeout de seguridad en modo manual y calibración

Esta protección evita que el motor o la resistencia queden encendidos indefinidamente si el usuario pierde la conexión con el punto de acceso WiFi o cierra el navegador sin detener los sliders.

Valores por defecto en el firmware:

**bool HABILITAR_TIMEOUT_SEGURIDAD = true;**
**unsigned long TIMEOUT_SISTEMA_MS = 30000;** (30 segundos)

**Comportamiento:**

*   Aplica para cualquier nivel de agitación o potencia térmica activada por slider.
*   Si el ESP32 no recibe una actualización de datos desde la web en el tiempo configurado, ejecuta una parada real:
    *   **PWM = 0** (Pin 25)
    *   **Pines IN1/IN2 = LOW** (Pines 26 y 27)
    *   **SSR_CONTROL = LOW** (Pin 18)
*   Se registra el evento **"Parada de emergencia por pérdida de señal"** en la metadata.
*   El usuario debe reconectar y refrescar la web para retomar el control.

**Importante:** Esta protección es una capa lógica de seguridad y no sustituye al botón físico de desconexión de la red eléctrica de 110V.

---


### 13. Prueba de encoder (Retroalimentación)

La sección de monitoreo de RPM permite validar la señal del sensor FC-03 mediante interrupciones en tiempo real:

1. Hacer girar el motor desplazando el slider de agitación.
2. Verificar el panel numérico **AGITADOR (RPM)** en el HMI.
3. Revisar que la gráfica de velocidad (curva azul) muestre el comportamiento dinámico.

**Valores esperados:**

*   **Con movimiento:** el valor de **pulsos** debe aumentar y las **RPM** deben ser mayores a 0.
*   **Detenido:** el valor de **RPM** debe ser exactamente 0.
*   Si hay movimiento pero las RPM marcan 0, verificar la alineación del disco de ranuras y que la alimentación del sensor sea de **3.3V**.

---

### 14. Ejecución de caracterización

La caracterización completa del reactor sigue una secuencia lógica de pasos para validar ambos subsistemas:

1. **Rampa de agitación ascendente:** (0, 20, 40, 60, 80, 100% PWM).
2. **Estabilización mecánica:** Pausa de 5 segundos en cada escalón para lectura estacionaria.
3. **Rampa de agitación descendente:** (100 a 0% PWM) para identificar histéresis.
4. **Pausa de equilibrio:** Regreso a temperatura ambiente y volumen estandarizado (2L o 3L).
5. **Escalón térmico:** Activación de la resistencia al 100% de potencia con agitación constante.
6. **Stop final:** Detención automática al alcanzar el límite de seguridad (40°C).

---

**Procedimiento:**

1. Completar el formulario de carga (Volumen de agua y tipo de aspa).
2. Deslizar el slider de agitación para iniciar la rampa mecánica.
3. Registrar los valores de voltaje y corriente en cada punto de operación.
4. Iniciar la prueba térmica y observar la curva de respuesta en tiempo real.
5. Al terminar, descargar el archivo EXEL con las lecturas para el procesamiento en MATLAB.

La cancelación manual en cualquier punto debe poner a cero los pines `PWM` y `SSR_CONTROL` de forma inmediata.

---

### 15. Interpretación de resultados

#### PWM mínimo de arranque (Zona Muerta)
El valor de `pwm_muerto` representa el primer nivel de PWM donde el agitador vence la fricción estática de la caja reductora y la resistencia viscosa del agua. Sirve para definir el umbral inferior de control en el código.

#### Histéresis mecánica
Aparece cuando las RPM de la rampa ascendente no coinciden con las de la rampa descendente para un mismo PWM. En nuestro motor TT, esto permite cuantificar el juego mecánico y el esfuerzo del aspa bajo carga.

#### Ganancia del proceso (K)
Calculada como `(Temp_final - Temp_inicial) / Potencia_SSR`. Indica cuántos grados centígrados aumenta el reactor por cada 1% de incremento en la potencia térmica. En este proyecto se identificó un valor nominal de **0.18 C/%**.

#### Constante de tiempo (Tau)
Representa la inercia térmica del fluido. Es el tiempo necesario para alcanzar el **63.2%** del incremento total de temperatura. Este valor cambia significativamente entre la carga de 2L (**92s**) y la de 3L (**135s**).

#### Tiempo muerto (Theta)
Es el retardo de transporte detectado entre el encendido de la resistencia y el inicio del ascenso sostenido en el sensor DS18B20. En nuestro sistema oscila entre **6 y 7 segundos** debido a la ubicación del sensor.

#### Eficiencia por Agitación (Coeficiente U)
Comparar la prueba al 50% vs 100% de agitación permite observar la reducción del gradiente térmico espacial. Una mayor velocidad de mezcla reduce el tiempo muerto y mejora la homogeneidad del lote farmacéutico.

---

### 16. Parámetros principales del formulario

* **id_ensayo**: Identificador único del lote o prueba (ej. Ensayo_2L_AspaLigera).
* **voltaje_vcc**: Voltaje real medido manualmente en bornes a PWM 255.
* **volumen_l**: Carga de fluido utilizada (estandarizado en 2.0 o 3.0 litros).
* **pulsos_por_vuelta**: Configurado en 20 para el disco del encoder FC-03.
* **paso_pwm**: Incremento entre escalones de la rampa (ej. 20 unidades).
* **tiempo_estabilizacion_ms**: Tiempo de espera para alcanzar estado estacionario mecánico.
* **temp_seguridad**: Límite de corte automático (40°C para proteger el polímero).
* **muestras_promedio**: Cantidad de lecturas de temperatura para filtrar ruido.

---

### 17. Pruebas por etapas

Usa esta secuencia para validar el sistema antes de confiar en los datos de caracterización:

**Etapa 1: Compilar proyecto limpio**
Ejecutar `pio run`. Esperado: Compilación exitosa de las librerías OneWire y AsyncWebServer.

**Etapa 2: Subir sistema de archivos LittleFS**
Ejecutar `pio run --target uploadfs`. Esperado: Los archivos `index.html` y las librerías de gráficas quedan disponibles en la flash del ESP32.

**Etapa 3: Validar WiFi y Punto de Acceso**
Subir firmware y buscar la red "Reactor_Batch_G5". Esperado: Conexión exitosa e IP `192.168.4.1` accesible.

**Etapa 4: Probar agitador (Slider)**
Mover el slider de 0 a 100. Esperado: El motor inicia giro al vencer la zona muerta (~25 PWM).

**Etapa 5: Probar sensor de temperatura DS18B20**
Sumergir el sensor y verificar lectura ambiental. Esperado: Gráfica roja con valores coherentes (aprox. 22-25°C).

**Etapa 6: Probar disparo del SSR**
Activar el slider de potencia térmica brevemente. Esperado: LED del SSR encendido y leve incremento de temperatura en la zona del fondo.

**Etapa 7: Ejecutar caracterización mecánica corta**
Usar un `paso_pwm = 50`. Esperado: Validación rápida de la captura de RPM y generación de gráfica de escalones.

**Etapa 8: Ejecutar caracterización térmica nominal**
Iniciar prueba con 2L de agua. Esperado: Curva de respuesta tipo primer orden (FOPDT) y exportación de datos exitosa.

---

### 18. Reproducibilidad desde cero

Para reproducir este proyecto:

1. Clonar el repositorio.
2. Configurar pines y credenciales en `include/config.h`.
3. Colocar las librerías `chart.umd.min.js` y `xlsx.full.min.js` en la carpeta `/data`.
4. Ejecutar `pio run` (Compilar).
5. Ejecutar `pio run --target upload` (Subir código).
6. Ejecutar `pio run --target uploadfs` (Subir interfaz web).
7. Abrir el navegador en `192.168.4.1`.
8. Realizar calibración manual de voltaje máximo.
9. Ejecutar pruebas por etapas.
10. Descargar archivo CSV/XLSX para análisis dinámico.

---

### 19. Mantenibilidad del código

El firmware está organizado por bloques funcionales para facilitar futuras mejoras:

* **WiFi SoftAP**: Gestión del punto de acceso independiente de internet.
* **Servidor Web Asíncrono**: Manejo de peticiones HTTP sin bloquear el lazo de control.
* **Control de Agitación**: Lógica de PWM mediante el driver L298N.
* **Control Térmico (SSR)**: Gestión de potencia mediante ventana de tiempo.
* **Bus One-Wire**: Lectura digital multivariable de temperatura.
* **Interrupciones Externas**: Conteo de pulsos de alta precisión para el cálculo de RPM.
* **Telemetría JSON**: Formateo de datos en tiempo real para el HMI.

La intención es mantener el código modular, permitiendo que otros grupos puedan integrar sensores adicionales (como pH o turbidez) o implementar un control PID de lazo cerrado sobre esta misma base de identificación.
