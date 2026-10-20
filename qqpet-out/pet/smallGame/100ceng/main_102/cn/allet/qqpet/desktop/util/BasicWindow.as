package cn.allet.qqpet.desktop.util
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.WindowNameOption;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BasicWindow extends EventDispatcher
   {
       
      
      protected var material:BasicMain;
      
      public function BasicWindow(param1:BasicMain)
      {
         super();
         this.material = param1;
         var _loc2_:Timer = new Timer(10);
         _loc2_.addEventListener(TimerEvent.TIMER,this.readyTimerHandler);
         _loc2_.start();
      }
      
      public function set scale(param1:Number) : void
      {
         API.setScalable(param1);
      }
      
      public function get scale() : Number
      {
         return API.getScalable();
      }
      
      public function destroy() : void
      {
         API.destroyWindow(API.getWindowName(WindowNameOption.SELF));
      }
      
      public function moveTo(param1:int, param2:int) : void
      {
         API.moveTo(param1,param2);
      }
      
      public function moveBy(param1:int, param2:int) : void
      {
         API.moveBy(param1,param2);
      }
      
      protected function init() : void
      {
      }
      
      protected function readyTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:Timer = null;
         if(API.isReady())
         {
            this.init();
            this.material.init();
            _loc2_ = param1.target as Timer;
            _loc2_.stop();
            _loc2_.removeEventListener(TimerEvent.TIMER,this.readyTimerHandler);
         }
      }
   }
}
