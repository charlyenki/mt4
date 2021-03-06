//+------------------------------------------------------------------+
//|                                                TrendUnitTest.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

enum STATE 
  {
   BULL,
   BEAR,
   SWING
  };
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
      runAllTests();
   
  }
//+------------------------------------------------------------------+


void runAllTests() {
   
   //openOrderTest();
   // closeOrderTest();
   
   //getOrderCountTest();
   
   STATE state = getTrend(1);
   Print("State --> ", state);
   
}


void openOrderTest() {
   
   int no = iOpenOrders("Buy", 0.1, 20, 20, Symbol());
   
   if(no == -1) {
      Print("下单失败");
   } else if(no == 0) {
      Print("重复下单");
   } else {
      Print("下单成功: ", no);
   }
   

}

void closeOrderTest() {
   iCloseOrder(Symbol());
}

void getOrderCountTest() {
   int cnt = getOrderCount(Symbol());
   Print("Order count:", cnt);
}

int iOpenOrders(string myType,double myLots,int myLossStop,int myTakeProfit,string comment)
  {

   // 检查相同货币对是否已经下单
   bool isOrderOpen=false;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderComment()==comment))
           {
               isOrderOpen = true;
               return 0;
           }
        }
     }
   
   
   
   int ticketNo=-1;
   int mySpread = MarketInfo(Symbol(),MODE_SPREAD);//点差 手续费 市场滑点
   double sl_buy=(myLossStop<=0)?0:(Ask-myLossStop*Point);
   double tp_buy=(myTakeProfit<=0)?0:(Ask+myTakeProfit*Point);
   double sl_sell=(myLossStop<=0)?0:(Bid+myLossStop*Point);
   double tp_sell=(myTakeProfit<=0)?0:(Bid-myTakeProfit*Point);

   if(myType=="Buy")
      ticketNo=OrderSend(Symbol(),OP_BUY,myLots,Ask,mySpread,sl_buy,tp_buy, comment);
   if(myType=="Sell")
      ticketNo=OrderSend(Symbol(),OP_SELL,myLots,Bid,mySpread,sl_sell,tp_sell, comment);

   return ticketNo;
  }
  
  
 
void iCloseOrder(string symbol) {
   
   int cnt=OrdersTotal();
   
   if(OrderSelect(cnt-1,SELECT_BY_POS)==false)
      return;
   
   for(int i = cnt - 1; i >= 0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderComment() == symbol) {
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
         }
      }
   }
   
}

int getOrderCount(string symbol) {
   int total = 0;
   
   int cnt=OrdersTotal();
   
   if(OrderSelect(cnt-1,SELECT_BY_POS)==false)
      return total;
   
   for(int i = cnt - 1; i >= 0; i--) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) {
         if(OrderSymbol() == symbol) {
            total ++;
         }
      }
   }
   
   return total;
   
}

STATE getTrend(int index) {
   STATE state = SWING;
   
   
   double MA10=iMA(Symbol(),0,10,0,MODE_EMA,PRICE_CLOSE,index);
   double MA20=iMA(Symbol(),0,20,0,MODE_EMA,PRICE_CLOSE,index);


   // 计算基准线Kijun-sen
   double kijunsen=iIchimoku(Symbol(),0,7,22,44,MODE_KIJUNSEN,index);
   double tenkansen=iIchimoku(Symbol(),0,7,22,44,MODE_TENKANSEN,index);
   
   double close=iClose(Symbol(),0,index);
   
   if(close>=kijunsen && tenkansen>=kijunsen) 
     {
      if(close>MA10 && close>MA20) 
        {
         state=BULL;
        }
        } else if(close<kijunsen && tenkansen<kijunsen) {
      if(close<MA10 && close<MA20) 
        {
         state=BEAR;
        }
        } else {
      state=SWING;
     }
     
     
   return state;
}