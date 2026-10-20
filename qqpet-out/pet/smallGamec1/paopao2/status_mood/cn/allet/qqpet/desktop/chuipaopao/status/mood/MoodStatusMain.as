package cn.allet.qqpet.desktop.chuipaopao.status.mood
{
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import flash.filters.DropShadowFilter;
   import flash.text.TextField;
   
   public class MoodStatusMain extends BasicMain
   {
       
      
      public var title_txt:TextField;
      
      public var mood_status_mc:MoodStatus;
      
      public function MoodStatusMain()
      {
         super();
         window = new MoodStatusWindow(this);
         window.addEventListener(GameEvent.MOOD_UPDATE,moodUpdateHandler);
         window.addEventListener(GameEvent.TITLE_UPDATE,titleUpdateHandler);
         filters = [new DropShadowFilter(0,0,0,0,0,0,0,0,false,false)];
      }
      
      override public function init() : void
      {
         mood_status_mc.init();
      }
      
      private function moodUpdateHandler(param1:GameEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc2_ = param1.param.current;
         _loc3_ = param1.param.max;
         mood_status_mc.update(_loc2_,_loc3_);
      }
      
      private function titleUpdateHandler(param1:GameEvent) : void
      {
         var _loc2_:String = null;
         _loc2_ = param1.param.title;
         title_txt.text = _loc2_;
      }
   }
}
