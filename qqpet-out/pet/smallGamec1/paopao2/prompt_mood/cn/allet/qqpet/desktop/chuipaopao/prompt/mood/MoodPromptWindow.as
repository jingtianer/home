package cn.allet.qqpet.desktop.chuipaopao.prompt.mood
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.WindowNameOption;
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import cn.allet.qqpet.desktop.util.BasicWindow;
   
   public class MoodPromptWindow extends BasicWindow
   {
       
      
      private var pWndName:String;
      
      private var cWndName:String;
      
      public function MoodPromptWindow(param1:BasicMain)
      {
         super(param1);
      }
      
      private function onMoodPrompt(param1:Boolean, param2:int) : void
      {
         var _loc3_:Object = null;
         _loc3_ = new Object();
         _loc3_.valid = param1;
         _loc3_.value = param2;
         dispatchEvent(new GameEvent(GameEvent.MOOD_PROMPT,false,_loc3_));
      }
      
      override protected function init() : void
      {
         API.registerFunction("moodPromptonPetYUpdate",onPetYUpdate);
         API.registerFunction("moodPromptonMoodPrompt",onMoodPrompt);
         cWndName = API.getWindowName(WindowNameOption.SELF);
         pWndName = API.getWindowName(WindowNameOption.PARENT);
         API.remoteCall(pWndName,"mainonWindowCreate",cWndName);
      }
      
      private function onPetYUpdate(param1:Number) : void
      {
         var _loc2_:Object = null;
         _loc2_ = new Object();
         _loc2_.delta = param1;
         dispatchEvent(new GameEvent(GameEvent.PET_Y_UPDATE,false,_loc2_));
      }
   }
}
