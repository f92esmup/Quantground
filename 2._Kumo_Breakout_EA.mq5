//+------------------------------------------------------------------+
//|                                          2._Kumo_Breakout_EA.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// Incluimos la librería de include que vamos a utilizar.
#include <Trade/Trade.mqh>
CTrade obj_trade;

// Ahora definimos los handles para asegurar la correcta inicialización posterior:
int handle_kumo = INVALID_HANDLE;
int handle_AO = INVALID_HANDLE;

// Estas variables se utilizan para almcenar los identificadores para cada indicador.
// La constante INVALID_HANDLE es una constante predefinida de MQL5 que representa un 
// identificador no válido. Los handles NO son obligatorios, pero nos ayudarán a prevenir
// errores de incialización.

// Más adelante, con el handle "recuperaremos" la información del indicador deseado, y 
// necesitaremso las variables siguientes para almacenar los valores. Son matrices.

double senkouSpan_A[];
double senkouSpan_B[];

double awesome_oscillator[];

// Estos arrays son de tipo double, de punto flotante, pero más precisos que los floats.

// Las variables definidas hasta ahora son variables definidas en el ámbito global. Es decir,
// accesibles desde cualquier punto del siguiente código.

// Yo ademas voy a incluir unos inputs para poder realizar optimizaciones:

input group "----Indicador Kumo----";
input int tenkam_sen = 8;
input int kijun_sen = 29;
input int senkou_span_b = 34;

input group "----Operaciones----";
input double mysize = 0.01;
input bool activate_trailling = true;
input int factor_trailling = 3000;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // En esta función vamos a controlar la inicialización. Solo actúa cada vez que se inicializa el indicador, 
   // independientemente del motivo. 
   
   // Empecemos con el controlador de KUMO:
   handle_kumo = iIchimoku(_Symbol, _Period,tenkam_sen, kijun_sen, senkou_span_b);
   
   // Ahora comprobamos que efectivamente hemos guardado en identificador.
   if (handle_kumo == INVALID_HANDLE) {
      Print("ERROR: INCAPAZ DE INICIALIZAR KUMO");
      return(INIT_FAILED);
   }
   
   
   // Ahora intentamos obtener el identificador del AO:
   
   handle_AO = iAO(_Symbol,_Period);
   
   if (handle_AO == INVALID_HANDLE) {
      Print("ERROR: Incapaz de inicializar AO");
      return(INIT_FAILED);
   }

   // En la incialización es el lugar donde definimos los arrays que almacenan los indicadores anteriores
   // como series temporales (que se actualizan manteniendo el valor más reciente en el índice 0).
   
   ArraySetAsSeries(senkouSpan_A, true); // Devuelve true en caso de éxito y el true es para invertir la indexación.
   ArraySetAsSeries(senkouSpan_B, true);
   ArraySetAsSeries(awesome_oscillator, true);
   
   // Ya lo tenemos todo listo en la incialización
   Print("SUCCESS. ", __FILE__,"Has been initialized.");
   // La variable predefinida __FILE__ representa el nombre del archivo actual.
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
/*
 Esta función nos interasa por lo siguiente:
 Hemos inicializado los arrays y los handles, no queremos conservarlos una vez que 
 desinicialicemos el programa, ya que habremos ocupado recursos innecesarios. Nos ocupamos
 de esto en el controlador de eventor OnDeinit, que se invoca cada vez que se desinicializa el 
 programa, sea cual sea el motivo.

*/
   
   // Free memory allocated for senkou spanA and B arrays.
   ArrayFree(senkouSpan_A);
   ArrayFree(senkouSpan_B);
   
   // Free memory allocate for AO array
   ArrayFree(awesome_oscillator);   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
/*
En este controlador de eventos es donde vamos a definir la lógica de trading.
Esta se activa para cada nuevo tick.

*/

// Lo primero que debemos hacer es recuperar los datos de los indicadores y almacenarlos para su posterior análisis.
/*
CopyBuffer recibe en el array búferr los datos del bufer especificado.
*/
   if (CopyBuffer(handle_kumo,SENKOUSPANA_LINE,0,2,senkouSpan_A) < 2) {
     Print("ERROR: NO SE HAN PODIDO RECUPERAR LOS DATOS");
     return;
   }

   if (CopyBuffer(handle_kumo, SENKOUSPANB_LINE,0,2,senkouSpan_B) < 2) { //Estamos copiando los 2 valores más recientes
     Print("ERROR: NO SE HAN PODIDO RECUPERAR LOS DATOS");
     return;
   }
   
   if (CopyBuffer(handle_AO, 0, 0,3, awesome_oscillator) < 3) { //Estamos copiando los 3 valores más recientes
      Print("ERROR: NO SE HAN PODIDO RECUPERAR LOS DATOS");
      return;
   }

   
   // YA tenemos los datos recuperados. La siguiente lógica queremos que se ejecute cada vez que se genere una nueva vela.
   // pero nuestro controlador de eventos se activa para cada tick, por lo que vamos a definir una función que de paso
   
   if (isNewBar()) {
      
      // Determinal is AO ha cruzado por debajo o por encima de cero:
      bool isAO_above = awesome_oscillator[1] > 0 && awesome_oscillator[2] < 0;
      bool iSAO_below = awesome_oscillator[1] < 0 && awesome_oscillator[2] > 0;
      
      // Determinar si hay configuración alcista o bajista de kumo:
      bool iskumo_above = senkouSpan_A[1] > senkouSpan_B[1];
      bool iskumo_below = senkouSpan_A[1] < senkouSpan_B[1];
      
      // determinamos señal alcista o bajista:
      bool isBuy_Signal = isAO_above && iskumo_below && getClosePrice(1) > senkouSpan_A[1] && getClosePrice(1) > senkouSpan_B[1];
      bool isSell_Signal = iSAO_below && iskumo_above && getClosePrice(1) < senkouSpan_A[1] && getClosePrice(1) < senkouSpan_B[1];
      
      // GESTIONAMOS LAS SEÑALES:
      
      if (isBuy_Signal) {
         Print("BUY SIGNAL GENERATED @ ", iTime(_Symbol, _Period, 1),", PRICE: ", getAsk());
         obj_trade.Buy(mysize, _Symbol, getAsk());
      }
      else if (isSell_Signal) {
         Print("SELL SIGNAL GENERATED @ ", iTime(_Symbol, _Period,1),"PRICE: ", getBid());
         obj_trade.Sell(mysize,_Symbol,getBid());
      }
      
      
      
      // AHORA SOLO TENEMOS QUE GESTIONAR LAS POSICIONES (QUE NO OPERACIONES).
      /*
      Lo que se haces es:
         - Vemos  cuantas posiciones hay
         - Si hay alguna, iteramos sobre ellas.
            - Se obtiene el ticket
            - Se seleciona la posición gracias al ticket obtenido
            - obtenemos el tipo de posicion.
            
            
            el ()PositionGetInteger() hace que el valor que devuelve la función se ajuste a uno de los valores enumeración 
       */
       
      if (isAO_above || iSAO_below) {
         if (PositionsTotal() > 0) {
            for (int i = PositionsTotal() - 1; i>=0; i--) { //se recorre hacia atras (...2,1,0) pq si no, al cerrar la 0, la 1->0, pero tu ya estas en la 1.
               ulong posTicket = PositionGetTicket(i);
               if (posTicket > 0) {
                  if (PositionSelectByTicket(posTicket)) {
                     ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                     if (posType == POSITION_TYPE_BUY) {
                        if (iSAO_below) {
                           Print("CLOSING THE BUY POSICION WITH #", posTicket);
                           obj_trade.PositionClose(posTicket);
                        }
                     }
                     else if (posType == POSITION_TYPE_SELL) {
                        if (isAO_above) {
                           Print("CLOSINT THE SELL POSITION WITH # ", posTicket);
                           obj_trade.PositionClose(posTicket);
                        }
                        
                     }
                  }
               }
               
         
            }
         }
      }
      
   }
   
   // Yo lo pondría fuera para que se actualice cada vez... 
   
   if (PositionsTotal() > 0 && activate_trailling) {
      applyTraillingSTOP(factor_trailling * _Point, obj_trade, 0);
   }

  
  }
  
//+------------------------------------------------------------------+
//| CONTAINS                                                         |
//+------------------------------------------------------------------+

bool isNewBar () {
   static int prevBars = 0; //static guarda el valor aún cuando salimos del scope de la función.
   int currBars = iBars(_Symbol, _Period); //devuelve el número actual de barras en el gráfico.
   if (prevBars == currBars) return(false);
   prevBars = currBars;
   return(true);
} 

double getClosePrice(int bar_index) {
 // Recupera el precio de cierre de la vela con el índice bar_index
   return(iClose(_Symbol,_Period,bar_index));
}

double getAsk() {
   return(NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits));
}

double getBid() {
   return(NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits)); 
}
//Estamos usando Normalize para segurar que el datos se ajuste al número de digitos del gráfico.


void applyTraillingSTOP(double slPoints, CTrade &trade_object, int magicNo=0) {
/*
mplementamos una función para aplicar un trailing stop a las posiciones abiertas. 
La función se llama «applyTrailingSTOP» y toma tres parámetros: «slPoints», que 
representa el número de puntos que se deben establecer para el stop loss; «trade_object»,
 que es una referencia al objeto comercial utilizado para modificar posiciones; y un 
 «magicNo» opcional, que se utiliza para identificar posiciones específicas por su
  número mágico.

*/

   double buySL = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID) - slPoints, _Digits);
   double sellSL = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK) - slPoints, _Digits);
   
   for (int i = PositionsTotal() - 1; i>=0; i--) {
      ulong ticket = PositionGetTicket(i);
      if (ticket > 0) {
         if (PositionGetString(POSITION_SYMBOL) == _Symbol &&
         (magicNo == 0 || PositionGetInteger(POSITION_MAGIC) == magicNo)) {
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY &&
            buySL > PositionGetDouble(POSITION_PRICE_OPEN) &&
            (buySL > PositionGetDouble(POSITION_SL) ||
            PositionGetDouble(POSITION_SL) == 0))  {
               
               trade_object.PositionModify(ticket, buySL, PositionGetDouble(POSITION_TP));
               
            }
         else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL &&
            sellSL > PositionGetDouble(POSITION_PRICE_OPEN) &&
            (sellSL > PositionGetDouble(POSITION_SL) ||
            PositionGetDouble(POSITION_SL) == 0))  {
               
               trade_object.PositionModify(ticket, sellSL, PositionGetDouble(POSITION_TP));
         
         }
      }
   } 
 }
}