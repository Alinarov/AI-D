#!/usr/bin/env dmd
import std;
import std.random: uniform;
import core.thread;
/* ------------------------- */
// importaciones locales 
import DBrain.network_decision;
import DBrain.funciones_activacion;
import DBrain.herramientas.herramientas_network;
import preparacion_datos;
/* -------------------------- */
alias print = writeln;

/**
 * Para entrenar el modelo debes de comentar las lineas asi: 
	//herramientas.cargarPesos(network, "experiencias/xor.memoria");

	//// Entrenar la red
	//foreach (epoch; 0 .. 20000) {
	//    foreach (i, input; inputs) {
	//        network.think(input);
	//        network.learn(targets[i]);
	//    }
	//}
 * 
 * y esta linea que esta al final: 
 * //herramientas.guardarPesos(network, "experiencias/xor.memoria");
 * */

// Renombramos para que no sea tan largo
alias funcion_activacion = DBrain.network_decision.funcion_activacion;
alias funcion_gradiente = DBrain.network_decision.funcion_gradiente;
alias herramientas = DBrain.herramientas.herramientas_network;

void main (string [] args) {
	print("
 +*****************************+
+* Predicción Q AI LEARNING :D *+
 +*****************************+        ");

	// entrada, n neuronas capas, salidas  
	// 15, 32, 16, 1 - 3
	Neuron[][] layers = createNeuralNetwork(4, [8,10], 1);

	Network network = new Network(layers);

	funcion_activacion = &DBrain.funciones_activacion.sigmoid;
	funcion_gradiente = &DBrain.funciones_activacion.sigmoid_gradient;


	float[][][]entrenamiento_prueba = division_entrenamiento("ventas_1000.csv");

	float[][][]datos_separados = separador_x_y(entrenamiento_prueba);

	 float[][] x_entrenamiento = datos_separados[0];
	 float[][] y_entrenamiento = datos_separados[1]; 
	 float[][] x_prueba = datos_separados[2];
	 float[][] y_prueba = datos_separados[3];
	
	print();
	print("X_entrenamiento ", x_entrenamiento);
	print();
	print("y_entrenamiento", y_entrenamiento);

	print();
	print("X_prueba", x_prueba);
	print();
	print("y_prueba", y_prueba);

	// Datos de entrenamiento (ejemplo simple)
	float[][] inputs = x_entrenamiento;
	float[][] targets = y_entrenamiento;

	herramientas.cargarPesos(network, "experiencias/xor.memoria");

	// Entrenar la red
	foreach (epoch; 0 .. 20000) {
	    foreach (i, input; inputs) {
	        network.think(input);
	        network.learn(targets[i]);
	    }
	}

	//// PROCESO DE PREDICCION
	//float[] lastQvalues;
	//int episode = 40;
	//float[] newInput = x_prueba;
	//float[] prediction;
	///* ------------------ */
	//int epocas_necesarias; // esto lo obtendremos una vez este entrenado y evaluado el modelo
	//foreach (i, ref input; episode) {
	//	prediction = network.think(newInput);

	//	lastQvalues = prediction.dup; // Guardamos los últimos Q-values

	//	// Aqui si responde incorrectamente
	//	if (prediction[0] != y_prueba[i][0]) {
	//		lastQvalues = prediction.dup; // Guardamos los últimos Q-values
	//		// Aplicamos corrección a los Q-values: penalizamos la acción "chocar con un bloque"
	//		float error = -1.0; // Penalización negativa
	//		prediction[0] += error; // Ajuste de Q-value para la acción "chocar con un bloque"	

	//		// Aqui si el sistema responde correctamente
	//	} else if (prediction[0] == y_prueba[i][0]) {
	//		writeln("La red eligió una acción correcta.");
	//		// Aplicamos corrección a los Q-values: penalizamos la acción "chocar con un bloque"
	//		float error = 0.55; // si es que obtubo un 10
	//		prediction[0] += error; // Ajuste de Q-value para la acción "chocar con un bloque"
	//		// Actualizamos los pesos de la red neuronal con el error
	//		network.updateQValues(newInput, 0, prediction[0], newInput);
	//		break;          
	//	}


	//}

	//foreach (i; 0 .. episode) {
	//	prediction = network.think(newInput);

	//	lastQvalues = prediction.dup; // Guardamos los últimos Q-values

	//	if (prediction[0] == 0.0) {
	//		lastQvalues = prediction.dup; // Guardamos los últimos Q-values
	//		// Aplicamos corrección a los Q-values: penalizamos la acción "chocar con un bloque"
	//		float error = -1.0; // Penalización negativa
	//		prediction[0] += error; // Ajuste de Q-value para la acción "chocar con un bloque"

	//		// Actualizamos los pesos de la red neuronal con el error
	//		network.updateQValues(newInput, 0, prediction[0], newInput);

	//	} else if (prediction[0] == 1.0) {
	//		writeln("La red eligió una acción correcta.");
	//		// Aplicamos corrección a los Q-values: penalizamos la acción "chocar con un bloque"
	//		float error = 0.55; // si es que obtubo un 10
	//		prediction[0] += error; // Ajuste de Q-value para la acción "chocar con un bloque"
	//		// Actualizamos los pesos de la red neuronal con el error
	//		network.updateQValues(newInput, 0, prediction[0], newInput);
	//		break;          
	//	}

	//}
	//writeln("Predicción: ", prediction[0]); 

	//herramientas.guardarPesos(network, "experiencias/xor.memoria");
}
