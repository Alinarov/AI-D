import json

def indent_json_file(input_file, output_file, indent=4):
    """
    Lee el archivo JSON, lo parsea y escribe una versión indentada en otro archivo.
    
    Args:
    - input_file (str): Ruta al archivo JSON de entrada.
    - output_file (str): Ruta al archivo JSON de salida con indentación.
    - indent (int): Número de espacios para la indentación (por defecto es 4).
    """
    try:
        # Leer el contenido del archivo JSON
        with open(input_file, 'r') as f:
            data = json.load(f)

        # Escribir el contenido indentado en el archivo de salida
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=indent)

        print(f"Indentación exitosa. Archivo guardado como '{output_file}'.")

    except FileNotFoundError:
        print(f"Error: El archivo '{input_file}' no fue encontrado.")
    except json.JSONDecodeError:
        print(f"Error: No se pudo decodificar el archivo '{input_file}' como JSON.")

# Uso del método
input_path = "configIA.json"
output_path = "configIA.json"
indent_json_file(input_path, output_path)
