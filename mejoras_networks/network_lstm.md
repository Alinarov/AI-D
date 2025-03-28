### 📌 **Explicación de los parámetros en una red LSTM**  

Cuando trabajamos con una **red LSTM**, hay cuatro parámetros clave que definen su estructura y cómo maneja los datos. Vamos a desglosarlos con ejemplos claros.  

---

## 🔹 **1. `inputFeatures`** (Número de características de entrada)  
Este parámetro define cuántas **características** tiene cada entrada en un instante de tiempo.  

### **Ejemplo:**  
Si estamos procesando una serie temporal de clima donde cada instante tiene:  
- **Temperatura** 🌡️  
- **Humedad** 💧  
- **Presión** 🌪️  

Entonces, **`inputFeatures = 3`**, porque cada punto en la secuencia tiene 3 valores.  

📌 **Formato de los datos** (si usamos `sequenceLength = 5`):  
```d
float[][] inputSequence = [
    [23.5, 65.0, 1012.3],  // t=1
    [24.0, 63.5, 1011.8],  // t=2
    [24.2, 62.0, 1011.5],  // t=3
    [24.8, 60.0, 1010.9],  // t=4
    [25.0, 58.5, 1010.3]   // t=5
];
```
Cada fila tiene **`inputFeatures = 3`** valores.

---

## 🔹 **2. `hiddenSize`** (Número de células LSTM en la capa oculta)  
Este parámetro define **cuántas células LSTM** forman la capa oculta.  

📌 **¿Qué significa esto?**  
- Si `hiddenSize = 10`, la capa LSTM tiene **10 células**.  
- Cada célula tiene su propio **estado oculto** y **estado de celda**, lo que permite que la red capture información de la secuencia.  
- A mayor `hiddenSize`, **más capacidad de memoria** tiene la red para aprender patrones complejos.  

---

## 🔹 **3. `outputSize`** (Número de neuronas en la capa de salida)  
Este parámetro define **cuántas neuronas hay en la capa final**, que produce la predicción.  

📌 **Ejemplo:**  
- Si estamos prediciendo **una temperatura futura**, `outputSize = 1` (solo una salida).  
- Si queremos predecir **temperatura y humedad**, `outputSize = 2`.  

✏️ **Formato de salida:**  
```d
float[] output = predict(inputSequence);
// output.length == outputSize
```
Si `outputSize = 1`, la salida podría ser:  
```d
[26.1]  // Predicción de temperatura para el próximo instante
```
Si `outputSize = 2`, la salida podría ser:  
```d
[26.1, 55.3]  // Predicción de temperatura y humedad
```

---

## 🔹 **4. `sequenceLength`** (Longitud de la secuencia de entrada)  
Este parámetro define cuántos **instantes de tiempo** toma en cuenta la LSTM antes de hacer una predicción.  

📌 **Ejemplo:**  
- Si `sequenceLength = 5`, la red analizará **los últimos 5 datos** antes de predecir.  
- Si `sequenceLength = 10`, analizará **los últimos 10 datos**, permitiendo aprender patrones más largos.  

✏️ **Ejemplo en código:**  
```d
// Secuencia de entrada con 5 pasos de tiempo y 3 características
float[][] inputSequence = [
    [23.5, 65.0, 1012.3],  // t=1
    [24.0, 63.5, 1011.8],  // t=2
    [24.2, 62.0, 1011.5],  // t=3
    [24.8, 60.0, 1010.9],  // t=4
    [25.0, 58.5, 1010.3]   // t=5
];

float[] output = predict(inputSequence);
```
Si `sequenceLength = 5`, la LSTM **solo ve estos 5 pasos** para hacer la predicción.  

Si `sequenceLength = 10`, necesitamos **10 filas** en `inputSequence`.  

---

## 🎯 **Resumen rápido**
| Parámetro         | Significado | Ejemplo |
|-------------------|------------|---------|
| `inputFeatures`   | Cantidad de valores en cada instante de tiempo. | `3` (temperatura, humedad, presión) |
| `hiddenSize`      | Número de células LSTM en la capa oculta. | `10` (10 células LSTM) |
| `outputSize`      | Número de valores que predice la red. | `1` (temperatura futura) |
| `sequenceLength`  | Cuántos pasos en el tiempo analiza la red antes de predecir. | `5` (usa 5 datos pasados) |

📌 **💡 Consejo:**  
Si los datos son **muy ruidosos**, puedes aumentar `hiddenSize` o `sequenceLength` para capturar más información. 🚀  

---

¿Qué valor planeas usar para cada parámetro en tu red? 🤔
