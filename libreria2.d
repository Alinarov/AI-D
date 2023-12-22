#!/usr/bin/env dmd
module libreria2;
import std.file:write;
import std.json;
import std.random;
import std;
alias print = writeln;

// [+] FUNCION DE LÄDT LAS CONFIGURACIONES 
JSONValue comunicacionJson() {
	string nameDatei = "configIA.json";
	string cadena = cast(string) read("configIA.json");
	JSONValue configs = parseJSON	(cadena);
    // Convertir el objeto JSON a una cadena y mostrarlo
    //writeln(configs.toString());
    return configs;
} // [-] FUNCION DE LÄDT LAS CONFIGURACIONES 

// [+] FUNCION DE ESCRITURA DE LAS LOS PESOS
void actualizacionPesos(float w0, float w1, float w2) {
	string cadena = cast(string) read("configIA.json");
	// Convertir el contenido del archivo a una estructura de datos en D
    JSONValue config = parseJSON(cadena);
    auto pesos = config["pesos AND"].object;

    // Actualizar los pesos
    pesos["w0"] = w0;
    pesos["w1"] = w1;
    pesos["w2"] = w2;

    // Convertir la estructura de datos a una cadena JSON
    string nuevaCadena = config.toString();


    // Escribir los pesos actualizados de vuelta al archivo JSON
    write("configIA.json", nuevaCadena);
    spawnShell("python indentacion.py");
}// [-] FUNCION DE ESCRITURA DE LAS LOS PESOS

// [+] FUNCIONES DE GENERACION DE PESOS
float[] generarPesos(size_t numPesos) {
    float[] pesos;
    foreach (_; 0 .. numPesos) {
        pesos ~= uniform(-1.0, 1.0);
    }
    return pesos;
}

float[] mainGenPesos(int maxPesos) {
    size_t numPesos = maxPesos;
    float[] pesos = generarPesos(numPesos);
    writeln("Pesos generados:", pesos);
    return pesos;
}// [-] FUNCIONES DE GENERACION DE PESOS

float[] sumatoriaY(float[6] args, float yD, float facApren) {
    
    float w0 = args[0];
    float w1 = args[1];
    float w2 = args[2];

    float x0 = args[3];
    float x1 = args[4];
    float x2 = args[5];

    // (+) Operaciones con los pesos 
    float y = (w0 * x0) + (w1 * x1) + (w2 * x2);
   
   	print("y calculado: "~ y.to!string );
    
    if (y >= 0) { 
        y = 1; 
    } else { 
        y = -1; 
    }
    print("y convertido: " ~ y.to!string);
    
    // (+) calculacion de error
   	float error = yD - y;
    print("error: " ~ error.to!string);
    
	if (error != 0) {
    // (+) Recalculacion de los pesos wi 
		w0 = w0 + (facApren * error * x0);
		w1 = w1 + (facApren * error * x1);
		w2 = w2 + (facApren * error * x2);
		print("Pesos actualizados: ", [w0,w1,w2].to!string);
		sumatoriaY([w0,w1,w2,x0,x1,x2],yD,facApren);
	}
    return [w0, w1, w2];
}



