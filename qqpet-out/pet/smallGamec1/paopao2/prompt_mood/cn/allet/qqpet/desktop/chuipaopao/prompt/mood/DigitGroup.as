package cn.allet.qqpet.desktop.chuipaopao.prompt.mood
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class DigitGroup extends Sprite
   {
       
      
      public var n10_mc:MovieClip;
      
      public var n100_mc:MovieClip;
      
      public var n1_mc:MovieClip;
      
      public function DigitGroup()
      {
         super();
         n1_mc.gotoAndStop(1);
         n1_mc.visible = false;
         n10_mc.gotoAndStop(1);
         n10_mc.visible = false;
         n100_mc.gotoAndStop(1);
         n100_mc.visible = false;
      }
      
      public function update(param1:int) : void
      {
         param1 = Math.max(0,Math.min(param1,999));
         if(param1 < 10)
         {
            n1_mc.visible = false;
            n10_mc.visible = false;
            n100_mc.visible = true;
            n100_mc.gotoAndStop(param1 % 10 + 1);
         }
         else if(param1 < 100)
         {
            n1_mc.visible = false;
            n10_mc.visible = true;
            n100_mc.visible = true;
            n10_mc.gotoAndStop(param1 % 10 + 1);
            n100_mc.gotoAndStop(int(param1 / 10) % 10 + 1);
         }
         else
         {
            n1_mc.visible = true;
            n10_mc.visible = true;
            n100_mc.visible = true;
            n1_mc.gotoAndStop(param1 % 10 + 1);
            n10_mc.gotoAndStop(int(param1 / 10) % 10 + 1);
            n100_mc.gotoAndStop(int(param1 / 100) % 10 + 1);
         }
      }
   }
}
