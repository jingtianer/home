package cn.allet.qqpet.desktop.chuipaopao.bubble
{
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import flash.display.MovieClip;
   
   public class QMove extends MovieClip
   {
      
      public static var run:String = "";
       
      
      public function QMove()
      {
         super();
         stop();
         visible = false;
      }
      
      private function stopRun() : void
      {
         run = "";
      }
      
      public function showBlowBubbleMovie() : void
      {
         visible = true;
         play();
      }
      
      private function _toStop() : void
      {
         stop();
         visible = false;
         dispatchEvent(new GameEvent(GameEvent.QMOVE_OVER));
      }
      
      private function startRun() : void
      {
         if(this.name == "upMove")
         {
            run = "up";
         }
         else
         {
            run = "down";
         }
      }
   }
}
