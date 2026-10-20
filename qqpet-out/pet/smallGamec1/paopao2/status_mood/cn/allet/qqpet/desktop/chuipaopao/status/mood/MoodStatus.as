package cn.allet.qqpet.desktop.chuipaopao.status.mood
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class MoodStatus extends MovieClip
   {
       
      
      public var progress_mc:MovieClip;
      
      public var digit_mc:MovieClip;
      
      public function MoodStatus()
      {
         super();
         progress_mc.gotoAndStop(1);
         digit_mc.visible = false;
         digit_mc.num_n1.gotoAndStop(1);
         digit_mc.num_n1.visible = false;
         digit_mc.num_n10.gotoAndStop(1);
         digit_mc.num_n10.visible = false;
         digit_mc.num_n100.gotoAndStop(1);
         digit_mc.num_n100.visible = false;
         digit_mc.num_n1000.gotoAndStop(1);
         digit_mc.num_n1000.visible = false;
         digit_mc.den_n1.gotoAndStop(1);
         digit_mc.den_n1.visible = false;
         digit_mc.den_n10.gotoAndStop(1);
         digit_mc.den_n10.visible = false;
         digit_mc.den_n100.gotoAndStop(1);
         digit_mc.den_n100.visible = false;
         digit_mc.den_n1000.gotoAndStop(1);
         digit_mc.den_n1000.visible = false;
      }
      
      private function updateDigit(param1:int, param2:int) : void
      {
         if(param1 < 0 || param1 > 9999)
         {
            return;
         }
         if(param2 < 0 || param2 > 9999)
         {
            return;
         }
         format(param1,1,digit_mc.num_n1);
         format(param1,10,digit_mc.num_n10);
         format(param1,100,digit_mc.num_n100);
         format(param1,1000,digit_mc.num_n1000);
         format(param2,1,digit_mc.den_n1);
         format(param2,10,digit_mc.den_n10);
         format(param2,100,digit_mc.den_n100);
         format(param2,1000,digit_mc.den_n1000);
      }
      
      public function init() : void
      {
      }
      
      private function updateProgress(param1:Number) : void
      {
         if(isNaN(param1) || param1 < 0 || param1 > 1)
         {
            return;
         }
         progress_mc.gotoAndStop(int(progress_mc.totalFrames * param1));
      }
      
      private function format(param1:int, param2:int, param3:MovieClip) : void
      {
         param3.gotoAndStop(int(param1 / param2) % 10 + 1);
         if(param1 < param2)
         {
            param3.visible = false;
         }
         else
         {
            param3.visible = true;
         }
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         digit_mc.visible = false;
      }
      
      public function update(param1:int, param2:int) : void
      {
         updateProgress(param1 / param2);
         updateDigit(param1,param2);
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         digit_mc.visible = true;
      }
   }
}
