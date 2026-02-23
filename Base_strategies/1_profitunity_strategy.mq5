//+------------------------------------------------------------------+
//|                                         profitunity_strategy.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
//#property description "q. PROFITUNITY (TRADING CHAOUS BY BILL WILLIANS)"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Include libreries                                                |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh> // Necesario para crear un objeto trade.
CTrade obj_Trade; // Se usa para abrir operaciones.

//+------------------------------------------------------------------+
//| Inicialización de variables                                      |
//+------------------------------------------------------------------+
// Ahora definirmos los handles de los indicadores.
// El handle es solo el IDENTIFICADOR que conecta con el indicador propio de MT5,
// esa es la razon por la que es un valor entero.
int handle_Fractals = INVALID_HANDLE; // Inicializa el indicador de fractales con un valor inválido
int handle_Alligator = INVALID_HANDLE;
int handle_AO = INVALID_HANDLE;
int handle_AC = INVALID_HANDLE;
// Esto no es obligatorio, pero ayuda a crear una verificación de que no haya fallado la carga de un indicador.

// Vamos a inicializar variables que almacenaran constantes de los indicadores.
double fractals_up[]; //array y double significa punto flotante
double fractals_down[];

double alligator_jaws[];
double alligator_teeth[];
double alligator_lips[];

double ao_values[];

double ac_color[];
#define AC_COLOR_UP 0 //definimos una constante, aunque realmente no es una constante como si usamos const, estamos poniendo que sustituya por 0 lo que haya en ese valor.
#define AC_COLOR_DOWN 1

// Como el ALLIGATOR es un indicador condicional, es decir que no da un valor para la vela actual.
// tenemos que hacer una búsqueda del último valor disponible y guardarlo. Por eso definimos antes:
double lastFractal_value = 0.0;
enum fractal_direction {FRACTAL_UP, FRACTAL_DOWN, FRACTAL_NEUTRAL};
// Inicializo lastFracta_direction como dato tipo fractal_direction:
fractal_direction lastFractal_direction = FRACTAL_NEUTRAL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
   // Inicializamos el indicador alligator
   handle_Alligator = iAlligator(_Symbol,_Period,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN);
   
   if (handle_Alligator == INVALID_HANDLE) {
      Print("ERROR: Incapaz de inicializar el indicador alligator");
      return(INIT_FAILED); // Se termina la inicialización con un fallo.
   }
   
   // Inicializamos el indicador Fractals
   handle_Fractals = iFractals(_Symbol,_Period);
   
   if (handle_Fractals == INVALID_HANDLE){
      Print("ERROR: Incapaz de inicializar el indicador fractal. reverting now!");
      return(INIT_FAILED); // se termina la incialización con un fallo.
   }
   
   // Inicializamos el indicador AO y AC
   handle_AO = iAO(_Symbol,_Period);
   if (handle_AO == INVALID_HANDLE){
      Print("ERROR: Incapaz de inicializar el indicador AO. reverting now!");
      return(INIT_FAILED);
   }
   
   handle_AC = iAC(_Symbol,_Period);
   if (handle_AC == INVALID_HANDLE){
      Print("ERROR: Incapaz de inicializar el indicador AC. reverting now!");
      return(INIT_FAILED);
   }
   
   // Ya hemos inicializado todos los indicadores, pero ¿cómo hacemos que aparezcan en la gráfica?
   if (!ChartIndicatorAdd(0,0,handle_Fractals)) { // (chartid, windowid, indicador) el chartid es la gráfica y el windowid es si quieres que aparezca en la gráfica o en ventanas abajo
      Print("ERROR No se ha podido carga el indicador fractal en el gráfico");
      return(INIT_FAILED);
   }
   
   if (!ChartIndicatorAdd(0,1,handle_AO)){
      Print("ERROR No se ha podido carga el indicador AO en el gráfico");
      return(INIT_FAILED);
   }
   
   if (!ChartIndicatorAdd(0,2,handle_AC)){
      Print("ERROR No se ha podido carga el indicador AC en el gráfico");
      return(INIT_FAILED);
   }
   
   //Y ahora para debug:
   Print("HANDLE ID FRACTALS = ", handle_Fractals);
   Print("HANDLE ID ALLIGATOR = ", handle_Alligator);
   Print("HANDLE ID AO = ", handle_AO);
   Print("HANDLE ID AC = ", handle_AC);
   
   // Ahora establecemos los data holders como time series:
   // Esto significa que los datos se organizan automáticamente del 
   // más antiguo al más nuevo. Lo que hacia como window rolling en python.
   // el datapoint más reciente está siemrpe indexado en 0.
   ArraySetAsSeries(fractals_up,true);
   ArraySetAsSeries(fractals_down,true);
   
   ArraySetAsSeries(alligator_jaws,true);
   ArraySetAsSeries(alligator_teeth,true);
   ArraySetAsSeries(alligator_lips,true);
   
   ArraySetAsSeries(ao_values,true);
   ArraySetAsSeries(ac_color, true);
   
//---
   return(INIT_SUCCEEDED);
  }
  
  // CONSEGUIDA LA INICIALIZACIÓN DE ESTA ESTRATEGIA.
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   // Primero vamos a "recuperar" los datos de los indicadores:
   // CopyBuffer lo que hace es volcar los valores que ha calculado su indicador
   // a la variable que tu le pidas y exactamente el número de valores que le pidas.
   // CopyBuffer(handle, buffer_num, start_pos, count, buffer_array[])
   // Un indicador puede tener varios buffers, el de fractal por ejemplo tiene el de
   // fractals up y down, osea dos buffers. 0 ,1.
   // Esta función devuelve un int con el número de datos que consiguio copiar.
   
   if (CopyBuffer(handle_Fractals,0,2,3,fractals_up) < 3) {
      Print("ERROR: No se pudieros copiar los datos fractal up");
      return;
   }
   // estamos cipiando desde el tercer dato más reciente (index 0 en C++)
   if (CopyBuffer(handle_Fractals,1,2,3,fractals_down) < 3){
      Print("ERROR: No se pudieros copiar los datos fractal down");
      return;
   }
   
   // Con la misma lógica mapeamos el alligator
   if (CopyBuffer(handle_Alligator,0,0,3,alligator_jaws) < 3){
      Print("ERROR: No se pudieros copiar los datos alligator jaws");
      return;
   }
   
   if (CopyBuffer(handle_Alligator,1,0,3,alligator_teeth) < 3) {
      Print("ERROR: No se pudieros copiar los datos alligator teeth");
      return;
   }
   
   if (CopyBuffer(handle_Alligator,2,0,3,alligator_lips) < 3){
      Print("ERROR: No se pudieros copiar los datos alligator lips");
      return;
   }
   
   // ahora para AO y AC
   if (CopyBuffer(handle_AO,0,0,3,ao_values) < 3){
      Print("ERROR: No se pudieros copiar los datos AO");
      return;
   }
   
   // En AC no estamos interesados en su valor (index 0) pero nosotros queremos el color (index 1) es lo que sigue en la ventana parámetros
   
   if (CopyBuffer(handle_AC,1,0,3,ac_color) < 3){
      Print("ERROR: No se pudieros copiar los datos AC");
      return;
   }
   
   //+--------CON ESTO YA HEMOS RECUPERADO LOS DATOS, AHORA VAMOS CON LA LÓGICA DE LA ESTRATEGIA-----+
   
   // ¿Cuándo se ejecuta la lógica?
   // PUes cuando se recibe un nuevo dato/vela.
   if (isNewBar()){ // No entiendo muy bien la necesidad de esto, se supone que OnTick hace esta función...
      // Actualizamos last_fractal
      const int index_fractal = 0;
      
      if (fractals_up[index_fractal] != EMPTY_VALUE) {
         lastFractal_value = fractals_up[index_fractal];
         lastFractal_direction = FRACTAL_UP;
      }
      
      if (fractals_down[index_fractal] != EMPTY_VALUE) {
         lastFractal_value = fractals_down[index_fractal];
         lastFractal_direction = FRACTAL_DOWN;
      }
      
      if (lastFractal_value != 0.0 && lastFractal_direction != FRACTAL_NEUTRAL) {
         Print("FRACTAL VALUE = ",lastFractal_value);
         Print("FRACTAL DIRECTION = ",getLastFractalDirection());
      }
         
      
      // Vamos a loogear la info del resto de parámetros:
      // Se usa 1 y no 0 ya que el el 0 es la vela aun NO cerrada, y no es estable.
      // NormalizeDouble redonde el volor de punto flotante a, en este caso, _Digits que es el de la terminal actual.
      Print("ALLIGATOR JAWS = ",NormalizeDouble(alligator_jaws[1],_Digits));
      Print("ALLIGATOR TEETH = ",NormalizeDouble(alligator_teeth[1],_Digits));
      Print("ALLIGATOR LIPS = ",NormalizeDouble(alligator_lips[1],_Digits));
      
      Print("AO VALUE = ", NormalizeDouble(ao_values[1],_Digits));
      
      if (ac_color[1] == AC_COLOR_UP) {
         Print("AC COLOR UP GREEN = ", AC_COLOR_UP);
      }
      else if (ac_color[1] == AC_COLOR_DOWN) {
         Print("AC COLOR DONW RED = ", AC_COLOR_DOWN);
      }
      
      // Definimos variables booleanas para comprobar posibles señales de trading
      // basadas en la línea Alligator's Jaw'.
      bool isBreakdown_jaws_buy = alligator_jaws[1] < getClosePrice(1) && alligator_jaws[2] > getClosePrice(2);
      // Esto comprueba si hay una ruptura para comprar
      
      bool isBreakdown_jaws_sell = alligator_jaws[1] > getClosePrice(1) && alligator_jaws[2] < getClosePrice(2);
      
      // Ahora definimos el resto de condiciones:
      
      if (lastFractal_direction == FRACTAL_DOWN 
      && isBreakdown_jaws_buy
      && ac_color[1] == AC_COLOR_UP
      && (ao_values[1] > 0 && ao_values[2] <0)) {
      
      Print("SEÑAL DE COMPRA GENERADA");
      obj_Trade.Buy(0.01, _Symbol, getAsk());
      //Este objeto es el que genera la operación de compra.
      }
      else if (lastFractal_direction == FRACTAL_UP
      && isBreakdown_jaws_sell
      && ac_color[1] == AC_COLOR_DOWN
      && (ao_values[1] < 0 && ao_values[2] > 0)) {
      
      Print("SEÑAL DE VENTA GENERADA");
      obj_Trade.Sell(0.01, _Symbol,getBid());
      }
      
      // Ahora necesitamos lógica para cerrar las posiciones. Usamos las reversiones
      // basandones en el AO indicator.
      
      if (ao_values[1] < 0 && ao_values[2] > 0) {
         if (PositionsTotal() > 0) {
            Print("CERRAMOS TODAS LAS POSICIONES DE COMPRA");
            for (int i = 0; i<PositionsTotal(); i++) {
               ulong pos_ticket = PositionGetTicket(i);
               if (pos_ticket > 0 && PositionSelectByTicket(pos_ticket)) {
                  ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                  if (pos_type == POSITION_TYPE_BUY) {
                     obj_Trade.PositionClose(pos_ticket);
                  }
               }
            
            }
         }
      }
      else if (ao_values[1] > 0 && ao_values[2] < 0) {
         if (PositionsTotal() >0) {
            Print("CERRAMOS TODAS LAS POSICIONES DE VENTA");
            for (int i=0; i<PositionsTotal(); i++) {
               ulong pos_ticket = PositionGetTicket(i);
               if (pos_ticket > 0 && PositionSelectByTicket(pos_ticket)) {
                  ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                  if (pos_type == POSITION_TYPE_SELL) {
                     obj_Trade.PositionClose(pos_ticket);
                  }
               }
            }
         }
      }
      
  
  /*
  PositionsTotal() -> Comprueba si hay alguna posición abierta en la cuenta
   devuelve el número de operaciones abiertas.
   
  PositionGetTicket(i) -> obtiene el identificador único (ticket) de la posición en el índice i.
  
  PositionSelectByTicket -> Selecciona la posición en la memoria para poder leer sus propiedades (como si es compra o venta)
  
   
  
  */
   }
   
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CONTAINS                                                         |
//+------------------------------------------------------------------+

double getClosePrice(int bar_idex) {
// Función para obtener el precio de cierre.
return (iClose(_Symbol,_Period,bar_idex)); // Recupera el precio de cierre de la vela "bar_index"
}

double getAsk(){
// Función para obtener el aks de los precios
return(NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits));
/*
SymbolInfoDouble recupera propiedades de tipo double del simbolo especificado:
_Symbol: es el símbolo del que vamos a recuperar info.
SYMBOL_ASK: es una de las propiedades que podemos recuperar. En este caso,
solicita el precio de oferta más bajo disponible en el mercado en ese instante.
*/
}

double getBid(){
// Función para obtener el bid de los precios.
return(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID), _Digits));

}

bool isNewBar() {
// Comprueba si una nueva barra se ha formado
   
   static int prevBars = 0; //static define prevBars como una variable global (y no local de la func), en futuras iteraciones el = 0 se ignora.
   int currBars = iBars(_Symbol,_Period); // obtiene el número de barras para e simbolo y periodo
   if (prevBars == currBars) return (false);
   prevBars = currBars;
   return(true); // si una nueva vela es detectada devuelve true.
   

}

string getLastFractalDirection() {
   /*
   Esta función obtiene las dirección del fractal.
   */
   
   string direction_fractal = "NEUTRAL";
   
   if (lastFractal_direction == FRACTAL_UP) return ("UP");
   else if (lastFractal_direction == FRACTAL_DOWN) return ("DOWN");
   
   return (direction_fractal);
}