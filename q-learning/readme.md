# Q-Learning 
El algoritmo que compartiste es **Deep Q-learning con Experience Replay**, una extensión del Q-Learning clásico que utiliza redes neuronales profundas para aproximar las funciones de valor de acción \( Q(s, a) \) en problemas de aprendizaje por refuerzo. A continuación, te describo cada paso del algoritmo:

### Descripción de Deep Q-Learning con Experience Replay:

1. **Inicialización del replay memory \( D \)**:
   - Se crea un buffer o memoria de experiencias \( D \) que almacena transiciones \((s, a, r, s')\), donde:
     - \( s \) es el estado actual.
     - \( a \) es la acción tomada.
     - \( r \) es la recompensa recibida.
     - \( s' \) es el siguiente estado.
   - Capacidad \( N \): El tamaño máximo del buffer.

2. **Inicialización de la función de valor de acción \( Q \)**:
   - La función de valor de acción \( Q \) se aproxima utilizando una red neuronal con pesos inicializados aleatoriamente. Esta red predice los valores \( Q(s, a) \) para cada estado \( s \) y acción \( a \).

3. **Bucle principal sobre los episodios**:
   - El algoritmo repite el proceso para un número de episodios \( M \) donde se busca entrenar al agente. Cada episodio representa una secuencia de pasos en el entorno.

4. **Inicialización de la secuencia \( s_1 \)**:
   - Al inicio de cada episodio, se obtiene una secuencia inicial \( s_1 \), que es una representación del estado inicial. Este estado es preprocesado para que la red neuronal lo interprete correctamente (por ejemplo, normalización de la entrada).

5. **Bucle de interacción con el entorno**:
   - Para cada paso en el episodio \( t \), se selecciona una acción \( a_t \) basada en una política exploratoria ε-greedy:
     - Con probabilidad \( ε \), se selecciona una acción aleatoria para explorar nuevas estrategias.
     - Con probabilidad \( 1 - ε \), se selecciona la acción que maximiza la función \( Q \) aprendida hasta el momento.
   - Se ejecuta la acción en el entorno, lo que produce una recompensa \( r_t \) y una transición al siguiente estado \( s_{t+1} \).

6. **Actualización del estado y almacenamiento en \( D \)**:
   - Se actualiza el estado a \( s_{t+1} \) y se preprocesa para convertirlo en la secuencia adecuada \( \phi_{t+1} \).
   - La transición completa \( (\phi_t, a_t, r_t, \phi_{t+1}) \) se almacena en el buffer de experiencias \( D \).

7. **Ajuste del modelo utilizando minibatches aleatorios**:
   - Se selecciona un minibatch aleatorio de transiciones desde \( D \) para entrenar la red neuronal.
   - Para cada transición en el minibatch, se calcula la actualización del valor de \( y_j \):
     - Si el estado siguiente es terminal, \( y_j = r_j \).
     - Si no es terminal, se usa la siguiente fórmula de Q-Learning: \( y_j = r_j + \gamma \cdot \max_{a'} Q(\phi_{j+1}, a'; \theta) \), donde \( \gamma \) es el factor de descuento.

8. **Actualización de los pesos de la red**:
   - Se realiza un paso de descenso de gradiente para minimizar el error entre \( y_j \) (valor objetivo) y la predicción actual de la red \( Q(\phi_j, a_j; \theta) \). El error a minimizar es \( (y_j - Q(\phi_j, a_j; \theta))^2 \).

9. **Repetición del proceso**:
   - El proceso se repite para cada paso \( t \) del episodio y para cada episodio \( M \), hasta que el agente haya aprendido a maximizar la recompensa acumulada en el entorno.

### Resumen:
El **Deep Q-Learning con Experience Replay** mejora la estabilidad del entrenamiento al almacenar transiciones en una memoria de experiencia y entrenar a la red neuronal con minibatches aleatorios, evitando correlaciones entre transiciones consecutivas. Además, la red neuronal permite al agente aprender en entornos con un gran espacio de estados donde el Q-Learning clásico sería ineficiente.

Este algoritmo es ampliamente utilizado en entornos complejos, como juegos (por ejemplo, el agente de **Atari** desarrollado por DeepMind).

![image](https://github.com/user-attachments/assets/611676f9-6938-433f-b873-72e287ab6263)

