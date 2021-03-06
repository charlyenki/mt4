//+------------------------------------------------------------------+
//|                                                        Trend.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
//--- plot MA10
#property indicator_label1  "MA10"
#property indicator_type1   DRAW_NONE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MA20
#property indicator_label2  "MA20"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot Label1
#property indicator_label3  "Label1"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Label2
#property indicator_label4  "Label2"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLimeGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

#property indicator_label5  "MA202"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

#property indicator_label6  "MA203"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrYellow
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2

input int InpFastEMA=10;   // Fast EMA Period
input int InpSlowEMA=20;   // Slow EMA Period
//--- indicator buffers
double         MA10Buffer[];
double         MA20Buffer[];
double         MA20Buffer2[];
double         MA20Buffer3[];

double         Label1Buffer[];
double         Label2Buffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ZigPrices
  {

   double            low1,low2;
   double            high1,high2;

  };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MA10Buffer);
   SetIndexBuffer(1,MA20Buffer);

   SetIndexBuffer(2,Label1Buffer);
   SetIndexBuffer(3,Label2Buffer);

   SetIndexBuffer(4,MA20Buffer2);
   SetIndexBuffer(5,MA20Buffer3);

   SetIndexArrow(2,SYMBOL_ARROWUP);
   SetIndexArrow(3,SYMBOL_ARROWDOWN);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(2,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW,159);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| 获取ZigZag最近的四个高低点                                |
//+------------------------------------------------------------------+
ZigPrices getZigPrices(int index)
  {
   ZigPrices zig={0,0,0,0};
   int ZigzagBarNumber1=0;
   double ZigzagPrice1=0;
   int ZigzagBarNumber2=0;
   double ZigzagPrice2=0;
   int ZigzagBarNumber3=0;
   double ZigzagPrice3=0;
   int ZigzagBarNumber4=0;
   double ZigzagPrice4=0;
   int counter=1;
   for(int i= index;i<index + 256;i++)
     {
      if(iCustom(Symbol(),0,"Zigzag",0,i)>0)
        {
         if(counter==1)
           {
            ZigzagBarNumber1=i;
            ZigzagPrice1=iCustom(Symbol(),0,"Zigzag",0,i);
            counter++;
            continue;
           }
         if(counter==2)
           {
            ZigzagBarNumber2=i;
            ZigzagPrice2=iCustom(Symbol(),0,"Zigzag",0,i);
            counter++;
            continue;
           }
         if(counter==3)
           {
            ZigzagBarNumber3=i;
            ZigzagPrice3=iCustom(Symbol(),0,"Zigzag",0,i);
            counter++;
            continue;
           }
         if(counter==4)
           {
            ZigzagBarNumber4=i;
            ZigzagPrice4=iCustom(Symbol(),0,"Zigzag",0,i);
            counter++;
            continue;
           }
         if(counter>4)
           {
            break;
           }
        }
     }
/*
   Print(ZigzagBarNumber1);
   Print(ZigzagPrice1);
   Print(ZigzagBarNumber2);
   Print(ZigzagPrice2);
   Print(ZigzagBarNumber3);
   Print(ZigzagPrice3);
   Print(ZigzagBarNumber4);
   Print(ZigzagPrice4); */

//如果获得点的值 >= K线的最高价，那说明获得的第一个点是高点
   if(ZigzagPrice1>=High[ZigzagBarNumber1])
     {
      //第一个点是高点
      zig.high1=ZigzagPrice1; zig.high2=ZigzagPrice3;
      zig.low1=ZigzagPrice2; zig.low2=ZigzagPrice4;
     }
   else if(ZigzagPrice1<=Low[ZigzagBarNumber1]) //如果获得点的值<= K线的最低价，那说明获得的第一个点是低点
     {

      //第一个点是低点
      zig.high1=ZigzagPrice2; zig.high2=ZigzagPrice4;
      zig.low1=ZigzagPrice1; zig.low2=ZigzagPrice3;
     }
   return zig;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int i, limit;
//---
   if(rates_total<=72)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++; 

   
//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++) 
     {
      // 计算EMA10 20
      MA10Buffer[i]=iMA(NULL,0,InpFastEMA,0,MODE_EMA,PRICE_CLOSE,i);
      // MA20Buffer3[i] = MA20Buffer2[i] = MA20Buffer[i] = iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
      MA20Buffer3[i]=MA20Buffer2[i]=MA20Buffer[i]=iMA(NULL,0,InpSlowEMA,0,MODE_EMA,PRICE_CLOSE,i);

     }

   for(i=0; i<rates_total- InpFastEMA; i++)
     {
      ZigPrices zig = getZigPrices(i);
      // 上升趋势的判断
      if(close[i]>MA10Buffer[i] && close[i]>MA20Buffer[i] && 
         close[i+1]>MA10Buffer[i+1] && close[i+1]>MA20Buffer[i+1] && 
         zig.low1>zig.low2)
        {
         
         MA20Buffer2[i]= EMPTY_VALUE;
         MA20Buffer3[i]= EMPTY_VALUE;
         //Label1Buffer[i]=low[i]-100 *Point;
         continue;

        }

      //下降趋势判断
      if(close[i]<MA10Buffer[i] && close[i]<MA20Buffer[i] && 
         close[i+1]<MA10Buffer[i+1] && close[i+1]<MA20Buffer[i+1] && 
         zig.low1<zig.low2)
        {
         
         MA20Buffer3[i]=MA20Buffer[i]=EMPTY_VALUE;
         continue;
           } else { // 震荡

         //MA20Buffer2[i]=MA20Buffer[i]=EMPTY_VALUE;
        }

     }

//--- done
   return(0);
  }
//+------------------------------------------------------------------+
