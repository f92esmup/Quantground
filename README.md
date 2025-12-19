# Quantground

Este proyecto sirve como playground para distintas aproximaciones de quanttrading
que me han parecido interesantes.

## Metodología

Ya que es difícil encontrar un lenguaje que te dé una solución para todo con una buena relación tiempo invertido-resultados, la forma en la que planteo mis proyectos consiste en realizar todo el proceso de análisis de datos y Machine Learning en Python, por sus obvias ventajas. El foco es obtener un modelo estandarizado en **ONNX**.

Luego, la implementación de la estrategia o automatización se realiza en **MQL5** (programando en C++), ya que presenta ventajas significativas en la obtención de datos y métodos especiales para símbolos y precios. Cargaremos el modelo en MQL5 para realizar las operaciones; de esta forma, aunque debemos programar la lógica operativa, las simulaciones y el backtesting se simplifican enormemente.

## Contenido

### [SimpleTreeStrategy.ipynb](./SimpleTreeStrategy.ipynb)

En este notebook se utiliza un árbol de decisión simple actuando como un
clasificador binario para filtrar las señales de una estrategia de trading
tradicional.

El proceso consiste en:

1. **Generación de señales:** Se utiliza una estrategia de cruce de medias
   móviles exponenciales (EMAs) sobre datos del S&P 500 para generar señales
   de compra/venta.
2. **Filtrado con Machine Learning:** Se entrena un árbol de decisión
   (`DecisionTreeClassifier`) usando indicadores técnicos (Momentum, ROC,
   Volumen, etc.) para predecir si la señal generada por las EMAs resultará en
   una operación exitosa o fallida.
3. **Optimización:** Se ajustan los hiperparámetros del árbol y se explora el
   uso de umbrales de probabilidad para mejorar la precisión (Win Rate) del
   sistema, comparando los resultados con la estrategia base.

