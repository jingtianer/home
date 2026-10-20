package cn.allet.qqpet.desktop.chuipaopao.prompt.mood
{
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   
   public class MoodPromptMain extends BasicMain
   {
       
      
      public var value_prompt_mc:MoodValuePrompt;
      
      public var prompt_mc:MoodPrompt;
      
      public function MoodPromptMain()
      {
         super();
         window = new MoodPromptWindow(this);
         window.addEventListener(GameEvent.MOOD_PROMPT,moodPromptHandler);
         window.addEventListener(GameEvent.PET_Y_UPDATE,petYUpdateHandler);
      }
      
      private function petYUpdateHandler(param1:GameEvent) : void
      {
         var _loc2_:int = 0;
         _loc2_ = int(param1.param.delta);
         window.moveBy(0,_loc2_);
      }
      
      private function moodPromptHandler(param1:GameEvent) : void
      {
         var _loc2_:Boolean = false;
         _loc2_ = param1.param.valid;
         if(_loc2_)
         {
            prompt_mc.showValid();
            value_prompt_mc.show(param1.param.value);
         }
         else
         {
            prompt_mc.showInvalid();
         }
      }
   }
}
