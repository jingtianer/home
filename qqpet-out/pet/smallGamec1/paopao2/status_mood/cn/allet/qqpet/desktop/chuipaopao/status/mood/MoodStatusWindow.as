package cn.allet.qqpet.desktop.chuipaopao.status.mood
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.WindowNameOption;
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import cn.allet.qqpet.desktop.util.BasicWindow;
   
   public class MoodStatusWindow extends BasicWindow
   {
       
      
      private var pWndName:String;
      
      private var cWndName:String;
      
      public function MoodStatusWindow(param1:BasicMain)
      {
         super(param1);
      }
      
      private function onPlay(param1:String) : void
      {
         var _loc2_:Object = null;
         _loc2_ = new Object();
         _loc2_.title = param1;
         dispatchEvent(new GameEvent(GameEvent.TITLE_UPDATE,false,_loc2_));
      }
      
      override protected function init() : void
      {
         API.registerFunction("moodstatusonMoodUpdate",onMoodUpdate);
         API.registerFunction("moodStatusonPlay",onPlay);
         cWndName = API.getWindowName(WindowNameOption.SELF);
         pWndName = API.getWindowName(WindowNameOption.PARENT);
         API.remoteCall(pWndName,"mainonWindowCreate",cWndName);
      }
      
      private function onMoodUpdate(param1:int, param2:int) : void
      {
         var _loc3_:Object = null;
         _loc3_ = new Object();
         _loc3_.current = param1;
         _loc3_.max = param2;
         dispatchEvent(new GameEvent(GameEvent.MOOD_UPDATE,false,_loc3_));
      }
   }
}
