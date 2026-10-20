package cn.allet.qqpet.desktop.chuipaopao.prompt.money
{
   import flash.display.MovieClip;
   
   public class MoneyPrompt extends MovieClip
   {
       
      
      public function MoneyPrompt()
      {
         super();
         hide();
      }
      
      private function hide() : void
      {
         gotoAndStop(1);
         visible = false;
      }
      
      private function onPromptEnd() : void
      {
         hide();
      }
      
      public function show() : void
      {
         gotoAndPlay(1);
         visible = true;
      }
   }
}
