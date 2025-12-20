# Quantground

Este repositorio está dedicado al desarrollo e investigación de estrategias de trading algorítmico de alta frecuencia y sistemáticas, utilizando **NautilusTrader** como motor principal.

## Descripción

El objetivo del proyecto es implementar estrategias robustas y extensibles. Actualmente, estamos en proceso de migración y estructuración del entorno para soportar flujos de trabajo con NautilusTrader, alejándonos de plataformas propietarias anteriores.

## Estructura del Proyecto

* **`notebooks/`**: Espacio dedicado a la investigación, análisis de datos y prototipado de estrategias en Jupyter Notebooks. Aquí encontrarás el desarrollo inicial de ideas como `SimpleTreeStrategy`.
* **`simpletree/`**: Directorio contenedor para la lógica de la estrategia "SimpleTree". Esta estrategia implementa un enfoque híbrido donde un árbol de decisión actúa como filtro de calidad para señales generadas por reglas tradicionales.
* **`storage/`**: Directorio reservado para persistencia de datos, logs o resultados de backtests.

## Tecnologías

* **NautilusTrader**: Plataforma de trading algorítmico basada en eventos, escrita en Rust y Python.
* **Python**: Lenguaje principal para la definición de estrategias y análisis.
