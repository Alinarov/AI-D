#!/usr/bin/env dmd 
import std.conv;
import std.stdio;
import std.array : array;
import std.range : iota, chunks;
import neuralnetwork: Neuron, Network, Synapse;
import std.random : uniform;
import std;

alias print = writeln;

void main() {
	

	//// Definir las capas en la red
	//Neuron[][] layers = [
	//    [input1, input2],                      // Capa de entrada
	//    [hidden1, hidden2, hidden3, hidden4],  // Primera capa oculta
	//    [hidden5, hidden6],                    // Segunda capa oculta
	//    [output]                               // Capa de salida
	//];

    // Definir la cantidad de neuronas para cada parte de la red
    int numInputNeurons = 2;              // Número de neuronas de entrada
    int[] hiddenLayers = [30, 30];          // Dos capas ocultas: 4 neuronas en la primera, 2 en la segunda
    int numOutputNeurons = 1;             // Una neurona de salida

    // Crear la red neuronal usando la función
    Neuron[][] layers = createNeuralNetwork(numInputNeurons, hiddenLayers, numOutputNeurons);

	// Crear la red neuronal
	Network network = new Network(layers);
	float[][] trainingData = [
		[0, 0], [0, 1], [1, 0], [1, 1]
	];

	float[][] expectedResults = [
		[0], [1], [1], [1]
	];

	// Definir un umbral de error para detener el entrenamiento
	float errorThreshold = 0.01;
	bool continueTraining = true;
	int maxEpochs = 1000000; // Establece el máximo de épocas

	foreach (epoch; 0 .. maxEpochs) 
	{
		float totalError = 0.0; // Inicializa el error acumulado de cada época
		
		foreach (i; 0 .. trainingData.length)
		{
			float[] input = trainingData[i];
			float[] expected = expectedResults[i];
			network.think(input);
			network.learn(expected);

			// Calcular el error total en cada ejemplo
			float[] result = network.think(input);
			foreach (j; 0 .. result.length)
			{
				float error = abs(expected[j] - result[j]);
				totalError += error;
			}
		}
		
		// Imprimir el resultado cada 100,000 épocas
		if (epoch % 100000 == 0)
		{
			writeln("Epoch: ", epoch, " Total Error: ", totalError);
		}

		// Verificar si el error es suficientemente bajo
		if (totalError < errorThreshold)
		{
			writeln("Entrenamiento completado en la época: ", epoch, " con un error total de: ", totalError);
			continueTraining = false;
			break;
		}
	}

	//network.printWeights(); // esto imprime todos los pesos de las 

	if (continueTraining)
	{
		writeln("Se alcanzó el máximo de épocas sin lograr el umbral de error deseado.");
	}

	// Probar con datos de entrada
	float[][] testInputs = [[0, 0], [0, 1], [1, 0], [1, 1]];
	foreach (input; testInputs)
	{
		float[] result = network.think(input);
		writeln("Input: ", input, " Output: ", result);
	}


}

Neuron[][] createNeuralNetwork(int inputNeurons, int[] hiddenLayers, int outputNeurons) {
    Neuron[][] layers;

    // Crear capa de entrada
    Neuron[] inputLayer;
    for (int i = 0; i < inputNeurons; i++) {
        inputLayer ~= new Neuron("Input " ~ i.to!string);
    }
    layers ~= inputLayer;

    // Crear capas ocultas
    Neuron[] prevLayer = inputLayer;
    foreach (layerSize; hiddenLayers) {
        Neuron[] hiddenLayer;
        for (int i = 0; i < layerSize; i++) {
            Neuron neuron = new Neuron("Hidden " ~ i.to!string);
            hiddenLayer ~= neuron;

            // Crear sinapsis entre la capa previa y la actual
            foreach (prevNeuron; prevLayer) {
                Synapse synapse = new Synapse(uniform(-1, 1), prevNeuron, neuron);
                prevNeuron.forwardSynapses ~= synapse;
                neuron.backwardSynapses ~= synapse;
            }
        }
        layers ~= hiddenLayer;
        prevLayer = hiddenLayer;
    }

    // Crear capa de salida
    Neuron[] outputLayer;
    for (int i = 0; i < outputNeurons; i++) {
        Neuron neuron = new Neuron("Output " ~ i.to!string);
        outputLayer ~= neuron;

        // Crear sinapsis entre la última capa oculta y la capa de salida
        foreach (prevNeuron; prevLayer) {
            Synapse synapse = new Synapse(uniform(-1, 1), prevNeuron, neuron);
            prevNeuron.forwardSynapses ~= synapse;
            neuron.backwardSynapses ~= synapse;
        }
    }
    layers ~= outputLayer;

    return layers;
}


