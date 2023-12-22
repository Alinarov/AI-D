#!/usr/bin/env dmd
import std;
import std.random;
import std.json;
import libreria2;

alias print = writeln;

void main() {
    // configuracion de modos de operacion
    bool guardarPesos = 0;
    bool usarPesos = 1;

    float[] x0 = [1, 1, 1, 1]; // bias
    float[] x1 = [1, 1, -1, -1];
    float[] x2 = [1, -1, 1, -1];
    float[] yD = [1, -1, -1, -1]; // Salidas esperadas para la operación AND

    float[] pesos = mainGenPesos(3); // Generar pesos iniciales
    	
    float w0;
	float w1;
	float w2;

    if (usarPesos != 1) {
    	print ("Estoy generando los pesos");
	    w0 = pesos[0].to!float;
	    w1 = pesos[1].to!float;
	    w2 = pesos[2].to!float;
    } else {
    	print("Estoy usando los pesos guardados");
    	string cadena = cast(string) read("configIA.json");
        JSONValue config = parseJSON(cadena);
        auto pesosG = config["pesos AND"].object;

        // Convertir valores JSON a flotantes antes de asignar
        w0 = to!float(pesosG["w0"].toString());
        w1 = to!float(pesosG["w1"].toString());
        w2 = to!float(pesosG["w2"].toString());
    }


    float facApren = 0.3;


    foreach(int n; 0 .. 4) { // Iterar sobre cada entrada
        float z = (w0 * x0[n]) + (w1 * x1[n]) + (w2 * x2[n]);

        if (z >= 0) {
            z = 1;
        } else {
            z = -1;
        }

        float error = yD[n] - z; // Calcular el error
        print("Error para entrada " ~ n.to!string ~ ": " ~ error.to!string);

        if (error != 0) { // Si hay error, ajustar los pesos
            w0 = w0 + (facApren * error * x0[n]);
            w1 = w1 + (facApren * error * x1[n]);
            w2 = w2 + (facApren * error * x2[n]);
        }
    }

    // Al finalizar, los pesos deberían estar ajustados para representar la operación AND.
    print("Pesos ajustados: [" ~ w0.to!string ~ ", " ~ w1.to!string ~ ", " ~ w2.to!string ~ "]");

    if (guardarPesos != 0) {
    	actualizacionPesos(w0, w1, w2);
    }

}
