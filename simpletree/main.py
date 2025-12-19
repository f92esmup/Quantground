# region imports
from AlgorithmImports import (
    QCAlgorithm,
    BrokerageName,
    AccountType,
    Resolution,
    Market,
    MovingAverageType,
)


class Simpletree(QCAlgorithm):
    def initialize(self):
        # También podemos escribir un nombre descriptivo al AlgorithmImports
        # y identificarlo con parámetros adiconales:
        ema_period = self.get_parameter("ema_period", 200)
        adx_period = self.get_parameter("adx_period", 14)
        macd_fast = self.get_parameter("macd_fast", 12)
        macd_slow = self.get_parameter("macd_slow", 26)
        macd_signal = self.get_parameter("macd_signal", 9)
        self.set_name(
            f"Simpletree_E{ema_period}_A{adx_period}_M{macd_fast}{macd_slow}{macd_signal}"
        )
        # También puedo añadir etiquetas con add_tags, pero no quiero.
        # Establecemos la zona horaria a Madrid
        self.set_time_zone("Europe/Madrid")
        # Establecemos la fecha de inicio de datos:
        self.set_start_date(2025, 1, 1)
        # Moneda y balance inicial de la cuenta:
        self.set_cash("USDT", 10000)
        # Modelo de brokerrage
        self.set_brokerage_model(BrokerageName.BINANCE, AccountType.MARGIN)
        # Agregamos el par sobre el que queremos operar:
        self.btc = self.add_crypto_future(
            "BTCUSDT", Resolution.HOUR, Market.BINANCE, fill_forward=False, leverage=5
        )  # fill forward es para que no rellene datos faltantes
        # FIXME: Tengo que comrprobar donde descargar los datos.

        ## Ahora empezamos con la declaración de los indicadores:
        # Ema de 200 periodos
        self.btc.ema = self.ema(self.btc.symbol, 200, Resolution.HOUR)
        # ADX de 14 periodos
        self.btc.adx = self.adx(self.btc.symbol, 14, Resolution.HOUR)

        # MACD (12, 26, 9)
        self.btc.macd = self.macd(
            self.btc.symbol,
            12,
            26,
            9,
            MovingAverageType.EXPONENTIAL,
            Resolution.HOUR,
        )
        # Establecemos el periodo de calenteamiento de los indicadores
        self.set_warm_up(200, Resolution.HOUR)

    # Para que me avise (o hacer una acción) cuando el algoritmo esté listo:
    # Esto es el post-initialize method.
    def on_warmup_finished(self) -> None:
        self.log("El algoritmo está listo para operar.")

    # Comenzamos con el método principal:
    def on_data(self, slice) -> None:
        pass
        # TODO: Añadir la lógica de trading aquí
