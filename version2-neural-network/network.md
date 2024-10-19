
### Importación de módulos

```d
import std;
import std.math : exp;
import std.math.exponential: log;
import std.algorithm : map, clamp;
import std.array : array;
import std.range : iota, chunks;
import std.stdio;
```

- `std`: Importa las funcionalidades estándar de D.
- `std.math : exp`: Importa la función `exp` para el cálculo de exponenciales, útil en funciones de activación como Sigmoid.
- `std.math.exponential: log`: Importa la función `log` para cálculos logarítmicos.
- `std.algorithm : map, clamp`: `map` aplica una función a cada elemento de una estructura (útil para transformar arrays), y `clamp` limita los valores entre un mínimo y un máximo.
- `std.array : array`: Convierte rangos en arrays.
- `std.range : iota, chunks`: `iota` genera secuencias de números, `chunks` permite dividir secuencias en partes. 
- `std.stdio`: Para la entrada/salida estándar, como `writeln` para imprimir.

### Constantes globales

```d
float learningRate = 0.9;
```

- `learningRate`: Tasa de aprendizaje, un factor que regula cuánto se ajustan los pesos en cada paso de entrenamiento.

### Funciones de activación

```d
float leaky_relu(float x) {
    return x > 0 ? x : 0.05 * x; // leaky Relu: Este da bien
    //return 1.0 / (1.0 + exp(-x)); // sigmoid
}
```

- **`leaky_relu`**: Es una función de activación **Leaky ReLU**, que devuelve `x` si es positivo o `0.05 * x` si es negativo. Esto previene el "problema de muerte de ReLU" (cuando los gradientes se vuelven cero).
  
  *Nota*: Hay una versión comentada de la función **sigmoid**, otra función de activación que puedes usar si prefieres. La **sigmoid** es una función en forma de "S" que aplana los valores entre 0 y 1.

```d
float leaky_relu_gradient(float x) {
    return x > 0 ? 1 : 0.05; // leaky relu: relu
    //return x * (1.0 - x); // Usualmente se calcula como f(x) * (1 - f(x))
}
```

- **`leaky_relu_gradient`**: Devuelve el gradiente de Leaky ReLU, es decir, 1 si `x > 0` y `0.05` si `x < 0`. Esto se usa en el proceso de retropropagación para ajustar los pesos.
  
  *Nota*: También hay una versión comentada del gradiente de **sigmoid**, que se calcula como `f(x) * (1 - f(x))`.

### Clase `Synapse` (Sinapsis)

```d
class Synapse {
    float weight;
    Neuron backwardNeuron, forwardNeuron;

    this(float weight, ref Neuron backwardNeuron, ref Neuron forwardNeuron) {
        this.weight = weight;
        this.forwardNeuron = forwardNeuron;
        this.backwardNeuron = backwardNeuron;
    }
}
```

- **`Synapse`**: Representa una conexión entre dos neuronas. Cada sinapsis tiene:
  - Un `weight` (peso), que determina la fuerza de la conexión.
  - Referencias a la `backwardNeuron` (neurona de entrada) y `forwardNeuron` (neurona de salida).

La sinapsis permite transmitir la salida de una neurona a la entrada de otra.

### Clase `Neuron` (Neurona)

```d
class Neuron {
    float momentum = 0.9;
    float [] prevWeightUpdates;
    string name;
    float delta, error = 0.0, input = 0.0, output;
    Synapse[] backwardSynapses, forwardSynapses;
```

- **`Neuron`**: Cada neurona tiene los siguientes atributos:
  - `momentum`: Factor de momento para actualizar los pesos.
  - `prevWeightUpdates`: Guarda los valores previos de las actualizaciones de pesos.
  - `name`: Nombre de la neurona, útil para depuración.
  - `delta`, `error`, `input`, `output`: Variables que almacenan información de entrada, salida, error y el gradiente (`delta`).
  - `backwardSynapses`, `forwardSynapses`: Listas de sinapsis hacia atrás (neurona de entrada) y hacia adelante (neurona de salida).

#### Método `backpropagateAndAdjust`

```d
    void backpropagateAndAdjust() {
        if (this.forwardSynapses.length > 0)
            this.error /= this.forwardSynapses.length;

        this.delta = this.error * leaky_relu_gradient(this.output);

        this.error = 0.0;

        foreach (ref synapse; this.backwardSynapses) {
            synapse.backwardNeuron.error += this.delta * synapse.weight;
            synapse.weight += synapse.backwardNeuron.output * this.delta * learningRate;

            synapse.weight = clamp(synapse.weight, -20.0, 20.0);
        }
    }
```

- Este método realiza la **retropropagación**. Se ajustan los pesos según el error calculado:
  - Se divide el error por el número de sinapsis para normalizarlo.
  - Se calcula el `delta` usando el gradiente de Leaky ReLU.
  - El error se propaga hacia las neuronas anteriores (las que están conectadas por las sinapsis hacia atrás).
  - Los pesos de las sinapsis se ajustan con base en la salida de la neurona anterior, el delta y la tasa de aprendizaje.
  - Los pesos se limitan entre -20 y 20 usando `clamp`.

### Clase `Network` (Red Neuronal)

```d
class Network {
    Neuron[][] layers;
```

- **`Network`**: Representa la red neuronal, que contiene capas de neuronas (`layers`).

#### Método `think`

```d
    float[] think(float[] input) {
        foreach (i, ref neuron; this.layers[0]) {
            neuron.output = input[i];

            foreach (ref synapse; neuron.forwardSynapses) 
                synapse.forwardNeuron.input += neuron.output * synapse.weight;
        }

        foreach (ref layer; this.layers[1 .. $])
            foreach (ref neuron; layer) {
                neuron.output = leaky_relu(neuron.input);
                neuron.input = 0.0;

                foreach (ref synapse; neuron.forwardSynapses)
                    synapse.forwardNeuron.input += neuron.output * synapse.weight;
            }

        return this.layers[$ - 1].map!(n => n.output).array;
    }
```

- **`think`**: Este método se utiliza para el **feedforward**.
  - Toma un array de entradas y lo propaga hacia adelante a través de las capas de la red.
  - Para la primera capa, asigna las entradas directamente como salidas.
  - En las capas posteriores, aplica la función de activación Leaky ReLU.
  - Al final, devuelve las salidas de la última capa.

#### Método `learn`

```d
    void learn(float[] expected) {
        foreach (i, ref neuron; this.layers[$ - 1])
            neuron.error = expected[i] - neuron.output;

        foreach_reverse (ref layer; this.layers[1 .. $])
            foreach (ref neuron; layer)
                neuron.backpropagateAndAdjust();
    }
```

- **`learn`**: Realiza el aprendizaje mediante **retropropagación**. Compara las salidas actuales con las esperadas para calcular los errores y luego ajusta los pesos propagando el error hacia atrás.

#### Método `printWeights`

```d
    void printWeights() {
        foreach (layerIndex, ref layer; this.layers) {
            writeln("Capa ", layerIndex);
            foreach (neuronIndex, ref neuron; layer) {
                writeln("  Neurona ", neuronIndex, " (", neuron.name, "):");
                foreach (synapseIndex, ref synapse; neuron.backwardSynapses) {
                    writeln("    Sinapsis ", synapseIndex, ": Peso = ", synapse.weight);
                }
            }
        }
    }
```

- **`printWeights`**: Este método imprime los pesos de las sinapsis para cada neurona, útil para depurar y verificar cómo se están ajustando los pesos en la red.

---

### Resumen
Este código implementa una red neuronal sencilla con:
- Neuronas conectadas por sinapsis.
- **Leaky ReLU** como función de activación.
- Retropropagación del error para el aprendizaje.
- Feedforward para procesar entradas y obtener salidas.

Este diseño puede ampliarse para resolver problemas más complejos como clasificación o regresión.
