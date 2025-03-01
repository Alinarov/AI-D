#!/usr/bin/env dmd
import std;
import std.random: uniform;
import core.thread;
/* ------------------------- */
// importaciones locales 
import DBrain.network_decision;
import DBrain.funciones;

alias print = writeln;

// Renombramos para que no sea tan largo
alias funcion_activacion = DBrain.network_decision.funcion_activacion;
alias funcion_gradiente = DBrain.network_decision.funcion_gradiente;

void main (string [] args) {
	print("
+*****************************+
+* Predicción Q AI LEARNING :D *+
+*****************************+		");

	Neuron[][] layers = createNeuralNetwork(2, [5], 1);

    Network network = new Network(layers);

    funcion_activacion = &DBrain.funciones.sigmoid;
    funcion_gradiente = &DBrain.funciones.sigmoid_gradient;


    // Datos de entrenamiento (ejemplo simple)
    float[][] inputs = [
        [0, 0],
        [0, 1],
        [1, 0],
        [1, 1]
    ];
    float[][] targets = [
        [0],
        [1],
        [1],
        [0]
    ];

    // Entrenar la red
    foreach (epoch; 0 .. 20000) {
        foreach (i, input; inputs) {
            network.think(input);
            network.learn(targets[i]);
        }
    }


    // PROCESO DE PREDICCION
    float[] lastQvalues;
    int episode = 40;
    float[] newInput = [0, 1];
	float[] prediction;
    foreach (i; 0 .. episode) {
    	prediction = network.think(newInput);

    	lastQvalues = prediction.dup; // Guardamos los últimos Q-values
    	


	    if (prediction[0] == 0.0) {
			lastQvalues = prediction.dup; // Guardamos los últimos Q-values
            // Aplicamos corrección a los Q-values: penalizamos la acción "chocar con un bloque"
            float error = -1.0; // Penalización negativa
            prediction[0] += error; // Ajuste de Q-value para la acción "chocar con un bloque"

            // Actualizamos los pesos de la red neuronal con el error
            network.updateQValues(newInput, 0, prediction[0], newInput);

	    } else if (prediction[0] == 1.0) {
            writeln("La red eligió una acción correcta.");
            // Aplicamos corrección a los Q-values: penalizamos la acción "chocar con un bloque"
            float error = 0.55; // si es que obtubo un 10
            prediction[0] += error; // Ajuste de Q-value para la acción "chocar con un bloque"
            // Actualizamos los pesos de la red neuronal con el error
            network.updateQValues(newInput, 0, prediction[0], newInput);
			break;	    	
	    }

    }
    writeln("Predicción: ", prediction[0]);	





}