package cn.allet.qqpet.desktop.chuipaopao.status.count
{
   import flash.display.MovieClip;
   
   public class TwinklingNumber extends MovieClip
   {
       
      
      public var mc1:MovieClip;
      
      public var mc2:MovieClip;
      
      public function TwinklingNumber()
      {
         super();
         mc1.visible = false;
         mc2.visible = false;
         mc1.gotoAndStop(1);
         mc2.gotoAndStop(1);
      }
      
      private function onMC1LastFrame() : *
      {
         mc1.gotoAndStop(1);
         mc1.visible = false;
      }
      
      private function onMC2LastFrame() : *
      {
         mc2.gotoAndStop(1);
         mc2.visible = false;
      }
      
      public function show() : *
      {
         mc1.visible = true;
         mc2.visible = true;
         mc1.play();
         mc2.play();
      }
   }
}
