package cn.allet.qqpet.desktop.chuipaopao.status.count
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.WindowNameOption;
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import cn.allet.qqpet.desktop.util.BasicWindow;
   
   public class CountStatusWindow extends BasicWindow
   {
       
      
      private var pWndName:String;
      
      private var cWndName:String;
      
      public function CountStatusWindow(param1:BasicMain)
      {
         super(param1);
      }
      
      override protected function init() : void
      {
         API.registerFunction("countStatusonCountUpdate",onCountUpdate);
         cWndName = API.getWindowName(WindowNameOption.SELF);
         pWndName = API.getWindowName(WindowNameOption.PARENT);
         API.remoteCall(pWndName,"mainonWindowCreate",cWndName);
      }
      
      private function onCountUpdate(param1:int) : void
      {
         var _loc2_:Object = null;
         _loc2_ = new Object();
         _loc2_.value = param1;
         dispatchEvent(new GameEvent(GameEvent.COUNT_UPDATE,false,_loc2_));
      }
   }
}
