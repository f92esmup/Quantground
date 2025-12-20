# Estrategia SimpleTree

## Filosofía

La filosofía de esta estrategia consiste en implementar un **árbol de decisión sencillo** que actúe como un filtro inteligente sobre una estrategia de trading tradicional basada en reglas.

### Concepto Clave

1. **Estrategia Base:** Una estrategia tradicional (por ejemplo, cruce de medias, ruptura de rangos, etc.) genera las señales de entrada y salida iniciales.
2. **Filtro de Árbol de Decisión:** Antes de ejecutar una señal, esta pasa por un modelo de árbol de decisión simple (Machine Learning).
    * El árbol evalúa condiciones de mercado adicionales o características (features) específicas.
    * Su objetivo es filtrar los "falsos positivos" o señales de baja probabilidad.
    * Solo si el árbol valida la señal, la orden se envía al mercado (o en este caso, al motor de NautilusTrader).

Este enfoque busca mejorar el ratio de aciertos (win rate) y reducir el drawdown, combinando la robustez de la lógica mecánica con la capacidad de adaptación de un modelo predictivo simple.
