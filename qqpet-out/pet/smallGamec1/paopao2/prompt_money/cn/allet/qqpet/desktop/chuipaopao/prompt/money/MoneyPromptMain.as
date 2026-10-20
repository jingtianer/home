package cn.allet.qqpet.desktop.chuipaopao.prompt.money
{
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   
   public class MoneyPromptMain extends BasicMain
   {
       
      
      public var prompt_mc:MoneyPrompt;
      
      public function MoneyPromptMain()
      {
         super();
         window = new MoneyPromptWindow(this);
         window.addEventListener(GameEvent.MONEY_PROMPT,moneyPromptHandler);
      }
      
      private function moneyPromptHandler(param1:GameEvent) : void
      {
         prompt_mc.show();
      }
   }
}
