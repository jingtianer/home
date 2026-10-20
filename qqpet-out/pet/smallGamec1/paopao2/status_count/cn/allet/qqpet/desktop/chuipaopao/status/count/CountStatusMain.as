package cn.allet.qqpet.desktop.chuipaopao.status.count
{
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import flash.filters.DropShadowFilter;
   
   public class CountStatusMain extends BasicMain
   {
       
      
      public var count_status_mc:CountStatus;
      
      public function CountStatusMain()
      {
         super();
         filters = [new DropShadowFilter(0,0,0,0,0,0,0,0,false,false)];
         window = new CountStatusWindow(this);
         window.addEventListener(GameEvent.COUNT_UPDATE,countUpdateHandler);
      }
      
      override public function init() : void
      {
      }
      
      private function countUpdateHandler(param1:GameEvent) : void
      {
         var _loc2_:int = 0;
         _loc2_ = param1.param.value;
         count_status_mc.update(_loc2_);
      }
   }
}
