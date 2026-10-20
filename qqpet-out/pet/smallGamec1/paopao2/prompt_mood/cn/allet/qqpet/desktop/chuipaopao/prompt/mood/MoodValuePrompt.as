package cn.allet.qqpet.desktop.chuipaopao.prompt.mood
{
   import flash.display.MovieClip;
   
   public class MoodValuePrompt extends MovieClip
   {
       
      
      public var dg_mc:DigitGroup;
      
      public function MoodValuePrompt()
      {
         super();
         hide();
      }
      
      public function hide() : void
      {
         gotoAndStop(1);
         visible = false;
      }
      
      private function onPromptEnd() : void
      {
         hide();
      }
      
      public function show(param1:int) : void
      {
         gotoAndPlay(1);
         visible = true;
         dg_mc.update(param1);
      }
   }
}
