package cn.allet.qqpet.desktop.chuipaopao.prompt.mood
{
   import flash.display.MovieClip;
   
   public class MoodPrompt extends MovieClip
   {
       
      
      private var current:MovieClip;
      
      public var valid_mc:MovieClip;
      
      public var invalid_mc:MovieClip;
      
      public function MoodPrompt()
      {
         super();
         valid_mc.gotoAndStop(1);
         valid_mc.visible = false;
         invalid_mc.gotoAndStop(1);
         invalid_mc.visible = false;
      }
      
      private function stopPrompt(param1:MovieClip) : void
      {
         if(param1 == null)
         {
            return;
         }
         param1.gotoAndStop(1);
         param1.visible = false;
      }
      
      private function onValidEnd() : void
      {
         stopPrompt(valid_mc);
      }
      
      public function showInvalid() : void
      {
         playPrompt(invalid_mc);
      }
      
      private function onInvalidEnd() : void
      {
         stopPrompt(invalid_mc);
      }
      
      private function playPrompt(param1:MovieClip) : void
      {
         if(param1 == null)
         {
            return;
         }
         stopPrompt(current);
         current = param1;
         current.gotoAndPlay(1);
         current.visible = true;
      }
      
      public function showValid() : void
      {
         playPrompt(valid_mc);
      }
   }
}
