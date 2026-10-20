package cn.allet.qqpet.desktop.chuipaopao.prompt.money
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.WindowNameOption;
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import cn.allet.qqpet.desktop.util.BasicWindow;
   
   public class MoneyPromptWindow extends BasicWindow
   {
       
      
      private var pWndName:String;
      
      private var cWndName:String;
      
      public function MoneyPromptWindow(param1:BasicMain)
      {
         super(param1);
      }
      
      override protected function init() : void
      {
         API.registerFunction("moneyPromptonMoneyPrompt",onMoneyPrompt);
         cWndName = API.getWindowName(WindowNameOption.SELF);
         pWndName = API.getWindowName(WindowNameOption.PARENT);
         API.remoteCall(pWndName,"mainonWindowCreate",cWndName);
      }
      
      private function onMoneyPrompt() : void
      {
         dispatchEvent(new GameEvent(GameEvent.MONEY_PROMPT));
      }
   }
}
