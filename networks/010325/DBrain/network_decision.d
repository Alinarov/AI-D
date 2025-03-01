#!/usr/bin/env dmd 
module DBrain.network_decision;

import std;
import std.math : exp;
import std.math.exponential: log;
import std.algorithm : map, clamp, reduce, max;
import std.array : array;
import std.range : iota, chunks;
import std.stdio;

/* ------------------ */
import DBrain.funciones;

/* ------------------ */

alias print = writeln;

/* DATOS GLOBALES DE CONFIGURACION */

float learningRate = 0.09;
float discountFactor = 0.95;


// Esto va a jalar de la biblioteca de funciones 
// funciones.d
float function (float x) funcion_activacion;
float function (float x) funcion_gradiente;

/* ------------------------------------------------------- */


class Synapse {
    float weight;
    Neuron backwardNeuron, forwardNeuron;

    this(float weight, ref Neuron backwardNeuron, ref Neuron forwardNeuron) {
        this.weight = weight;
        this.forwardNeuron = forwardNeuron;
        this.backwardNeuron = backwardNeuron;
    }
}

class Neuron {
    float momentum = 0.9;
    float [] prevWeightUpdates;

    string name;
    float delta, error = 0.0, input = 0.0, output;
    Synapse[] backwardSynapses, forwardSynapses;

	this(string name) {
	    this.name = name;
	    this.output = 0.0;
	    this.input = 0.0;
	    this.error = 0.0;
	    this.delta = 0.0;
	    this.prevWeightUpdates = [];
	}

    void backpropagateAndAdjust() {
        if (this.forwardSynapses.length > 0)
            this.error /= this.forwardSynapses.length;

        this.delta = this.error * funcion_gradiente(this.output);

        this.error = 0.0;

        foreach (ref synapse; this.backwardSynapses) {
            synapse.backwardNeuron.error += this.delta * synapse.weight;
            synapse.weight += synapse.backwardNeuron.output * this.delta * learningRate;

            synapse.weight = clamp(synapse.weight, -20.0, 20.0);
        }
    }
}

class Network {
    Neuron[][] layers;


    this(ref Neuron[][] layers) {
        this.layers = layers;
    }

    // Modifica la función think
    float[] think(float[] input) {

		assert(input.length == this.layers[0].length, "Input length must match the number of input neurons. Expected: " ~ this.layers[0].length.to!string ~ ", Got: " ~ input.length.to!string);
        // Propagación hacia adelante
        foreach (i, ref neuron; this.layers[0]) {
            neuron.output = input[i];

            foreach (ref synapse; neuron.forwardSynapses) 
                synapse.forwardNeuron.input += neuron.output * synapse.weight;
        }

        // Capa oculta
        foreach (ref layer; this.layers[1 .. $]) {
            foreach (ref neuron; layer) {
                neuron.output = funcion_activacion(neuron.input);
                neuron.input = 0.0;

                foreach (ref synapse; neuron.forwardSynapses)
                    synapse.forwardNeuron.input += neuron.output * synapse.weight;
            }
        }

        // Obtener las salidas
        float[] outputs = this.layers[$ - 1].map!(n => n.output).array;

        return outputs;
    }

    // Función de aprendizaje (backpropagation)
    void learn(float[] expected) {
        // Calcula el error y ajusta los pesos
		foreach (i, ref neuron; this.layers[$ - 1]) {
		    neuron.error = expected[i] - neuron.output;
		}

        // Retropropagación del error
        foreach_reverse (ref layer; this.layers[1 .. $])
            foreach (ref neuron; layer)
                neuron.backpropagateAndAdjust();
    }

    // Función para actualizar los valores Q usando la fórmula de Q-Learning
    void updateQValues(float[] currentState, int action, float reward, float[] nextState) {
        // Obtén el valor Q actual (antes de tomar la acción)
        float[] qValues = this.think(currentState);  // Q(s, a) para todas las acciones
        float currentQ = qValues[action];  // Q(s, a) para la acción específica

        // Obtén los valores Q para el siguiente estado
        float[] nextQValues = this.think(nextState);
        //float maxNextQ = nextQValues.maxElement;  // max_a' Q(s', a')
        float maxNextQ = nextQValues.reduce!max;  // max_a' Q(s', a')

        // Fórmula de Q-Learning
        float updatedQ = currentQ + learningRate * (reward + discountFactor * maxNextQ - currentQ);
        
        // Actualiza el valor Q para la acción seleccionada
        qValues[action] = updatedQ;

        // Usa la red neuronal para ajustar los pesos basados en el valor Q actualizado
        this.learn(qValues);
    }

    // Función para imprimir los pesos
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

