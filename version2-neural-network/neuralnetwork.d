module neuralnetwork;
import std;
import std.math : exp;
import std.math.exponential: log;
import std.algorithm : map, clamp;
import std.array : array;
import std.range : iota, chunks;
import std.stdio;

float learningRate = 0.9;

float leaky_relu(float x) {
    return x > 0 ? x : 0.05 * x; // leaky Relu: Este da bien
    //return 1.0 / (1.0 + exp(-x)); // sigmoid

}

float leaky_relu_gradient(float x) {
    return x > 0 ? 1 : 0.05; // leay relu: relu
    //return x * (1.0 - x); // Usualmente se calcula como f(x) * (1 - f(x))
}

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
    }

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
}

class Network {
    Neuron[][] layers;

    this(ref Neuron[][] layers) {
        this.layers = layers;
    }

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

    void learn(float[] expected) {
        foreach (i, ref neuron; this.layers[$ - 1])
            neuron.error = expected[i] - neuron.output;

        foreach_reverse (ref layer; this.layers[1 .. $])
            foreach (ref neuron; layer)
                neuron.backpropagateAndAdjust();
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
