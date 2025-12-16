import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np
import mplcursors # La magia para la interactividad


# 1. Generar datos estilo Quant
np.random.seed(42)
dias = 200
fechas = pd.date_range("2023-01-01", periods=dias)
precio = 100 + np.cumsum(np.random.randn(dias))
volumen = np.random.randint(100, 1000, dias)

df = pd.DataFrame({'Fecha': fechas, 'Precio': precio, 'Volumen': volumen})

# 2. Configurar el estilo Seaborn
sns.set_theme(style="darkgrid") # Estilo oscuro profesional
plt.figure(figsize=(12, 6))

# 3. Crear la gráfica (Lineplot simple)
ax = sns.lineplot(data=df, x='Fecha', y='Precio', 
                  linewidth=2.5, color='#00d9ff', label='Estrategia Alpha')

# Añadimos una media móvil para tener dos líneas
df['SMA'] = df['Precio'].rolling(20).mean()
sns.lineplot(data=df, x='Fecha', y='SMA', 
             color='orange', linestyle='--', label='SMA 20')

plt.title("Backtest con Seaborn (Haz clic en la línea)", fontsize=16)
plt.legend()

# 4. AÑADIR LA INTERACTIVIDAD (HOVER)
# Esto activa un cursor que muestra los valores al pasar/clicar el mouse
cursor = mplcursors.cursor(ax, hover=True)

# Personalizar lo que dice la etiqueta (opcional, para que se vea Pro)
@cursor.connect("add")
def on_add(sel):
    # sel.target es la coordenada (x, y)
    # sel.index es el índice del punto en el dataframe
    x, y = sel.target
    # Formatear la etiqueta
    sel.annotation.set_text(f"Precio: {y:.2f}\nFecha: {matplotlib.dates.num2date(x).strftime('%Y-%m-%d')}")
    sel.annotation.get_bbox_patch().set(fc="white", alpha=0.9)

print("Abriendo ventana nativa...")
plt.show()
