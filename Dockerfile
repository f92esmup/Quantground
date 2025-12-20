# Imagen base oficial de Python 3.13
FROM python:3.13-bookworm

# Evitar diálogos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar dependencias del sistema, Node.js y herramientas para Neovim
RUN apt-get update && apt-get install -y \
    curl \
    git \
    make \
    unzip \
    gcc \
    ripgrep \
    fd-find \
    fontconfig \
    # Dependencias para GUI (Matplotlib)
    libgl1-mesa-glx \
    libx11-6 \
    python3-tk \
    # Instalación de Node.js y NPM
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# 1.1 Instalar JetBrainsMono Nerd Font
RUN mkdir -p /usr/local/share/fonts/jetbrains-mono \
    && curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip \
    && unzip JetBrainsMono.zip -d /usr/local/share/fonts/jetbrains-mono \
    && rm JetBrainsMono.zip \
    && fc-cache -fv

# 2. Instalar gemini-cli globalmente vía npm
RUN npm install -g @google/gemini-cli

# 3. Instalar Neovim (v0.10+)
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    && tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
    && rm nvim-linux-x86_64.tar.gz \
    && ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# 4. Instalar librerías de Python directamente en el sistema (sin venv)
RUN pip install --no-cache-dir \
    matplotlib \
    numpy \
    pandas \
    pynvim \
    PyQt6

# 5. Configurar LazyVim
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim \
    && rm -rf /root/.config/nvim/.git

# Configuración de entorno
WORKDIR /app
ENV QT_X11_NO_MITSHM=1

CMD ["/bin/bash"]
