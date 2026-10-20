package cn.allet.qqpet.desktop.chuipaopao.status.count
{
   import com.klstudio.util.Tracer;
   import flash.display.MovieClip;
   
   public class CountStatus extends MovieClip
   {
       
      
      public var twinklingHundred8:Number8;
      
      public var twinklingHundred1:Number1;
      
      public var n10:MovieClip;
      
      private var rightTwinklingArray:Array;
      
      public var twinklingHundred9:Number9;
      
      public var twinklingTen4:Number4;
      
      public var twinklingTen8:Number8;
      
      public var twinklingTen2:Number2;
      
      public var twinklingTen5:Number5;
      
      public var twinklingTen6:Number6;
      
      public var twinklingTen7:Number7;
      
      public var twinklingTen9:Number9;
      
      public var twinklingTen3:Number3;
      
      public var n1:MovieClip;
      
      public var twinklingTen1:Number1;
      
      public var n100:MovieClip;
      
      private var leftTwinklingArray:Array;
      
      public var twinklingHundred2:Number2;
      
      public var twinklingHundred3:Number3;
      
      public var twinklingHundred5:Number5;
      
      public var twinklingHundred6:Number6;
      
      public var twinklingHundred4:Number4;
      
      public var twinklingHundred7:Number7;
      
      public function CountStatus()
      {
         super();
         n1.gotoAndStop(1);
         n1.visible = false;
         n10.gotoAndStop(1);
         n100.gotoAndStop(1);
         rightTwinklingArray = [twinklingTen1,twinklingTen2,twinklingTen3,twinklingTen4,twinklingTen5,twinklingTen6,twinklingTen7,twinklingTen8,twinklingTen9];
         leftTwinklingArray = [twinklingHundred1,twinklingHundred2,twinklingHundred3,twinklingHundred4,twinklingHundred5,twinklingHundred6,twinklingHundred7,twinklingHundred8,twinklingHundred9];
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:TwinklingNumber = null;
         var _loc3_:TwinklingNumber = null;
         if(param1 < 0 || param1 > 999)
         {
            return;
         }
         if(param1 < 100)
         {
            n1.visible = false;
            n10.visible = true;
            n100.visible = true;
            n10.gotoAndStop(param1 % 10 + 1);
            n100.gotoAndStop(int(param1 / 10) % 10 + 1);
            if(param1 != 0 && n10.currentFrame == 1)
            {
               _loc2_ = leftTwinklingArray[n100.currentFrame - 2];
               _loc2_.show();
            }
         }
         else
         {
            n1.visible = true;
            n10.visible = true;
            n100.visible = true;
            n1.gotoAndStop(param1 % 10 + 1);
            n10.gotoAndStop(int(param1 / 10) % 10 + 1);
            n100.gotoAndStop(int(param1 / 100) % 10 + 1);
            if(n1.currentFrame == 1)
            {
               Tracer.debug(param1);
               if(n10.currentFrame != 1)
               {
                  _loc3_ = rightTwinklingArray[n10.currentFrame - 2];
                  _loc3_.show();
               }
               else
               {
                  _loc3_ = leftTwinklingArray[n100.currentFrame - 2];
                  _loc3_.show();
               }
            }
         }
      }
   }
}
