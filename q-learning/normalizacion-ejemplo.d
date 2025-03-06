import DBrain.herramientas.calculaciones.estadistica;
import DBrain.herramientas.obtener_datos;
import std.algorithm : map, reduce, sum;
import std.array : array;
import std.math : sqrt;
import std.stdio : writeln;
import std.conv;

void main() {
    // Datos de ejemplo
    float[] columna = [1.0, 2.0, 3.0, 4.0, 5.0];

    // Normalizar la columna
    float[] columnaNormalizada = zScoreNormalize(columna);

    float media = calcularMedia(columna);
    float desviacion = calcularDesviacionEstandar(columna, media);


    // Mostrar resultados
    writeln("Columna original: ", columna);
    writeln("Columna normalizada: ", columnaNormalizada);

    float valor_desnormalizado = desnormalizarZScore(-1.41421, media, desviacion);

    // Desnormalizar
    writeln("Desnormalizar dato: ", redondearDosDecimales(to!string(valor_desnormalizado)));

}	
