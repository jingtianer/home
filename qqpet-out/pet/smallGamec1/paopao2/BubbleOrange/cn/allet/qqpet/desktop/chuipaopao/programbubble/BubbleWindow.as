package cn.allet.qqpet.desktop.chuipaopao.programbubble
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.WindowNameOption;
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import cn.allet.qqpet.desktop.util.BasicWindow;
   import flash.system.Capabilities;
   import flash.external.ExternalInterface;
   
   public class BubbleWindow extends BasicWindow
   {
       
      
      private var screenHeight:Number;
      
      private var screenWidth:Number;
      
      public function BubbleWindow(param1:BasicMain)
      {
         super(param1);
      }
      
      override protected function init() : void
      {
         screenWidth = Capabilities.screenResolutionX;
         screenHeight = Capabilities.screenResolutionY;
         API.registerFunction("bubblesetScaleAndMove",setScaleAndMove);
         BubbleMain.rank = String(API.getWindowName(WindowNameOption.SELF)).split(",")[0];
          ExternalInterface.call("SMALLGAMEAPIPP.Capabilities",Capabilities.screenResolutionX,Capabilities.screenResolutionY);
      }
      
      public function updateCount() : void
      {
         API.remoteCall(API.getWindowName(WindowNameOption.PARENT),"mainonMouseDownBubble");
      }
      
      private function setScaleAndMove(param1:Number, param2:String) : void
      {
         dispatchEvent(new GameEvent(GameEvent.SET_BUBBLE_SCALE,false,[param1,param2]));
      }
      
      public function move(param1:Number, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Boolean = false;
         API.moveBy(param1,param2);
         _loc3_ = Number(API.getWindowRect().split(",")[0]);
         _loc4_ = Number(API.getWindowRect().split(",")[1]);
         _loc5_ = false;
         if(_loc3_ <= 0)
         {
            material.visible = false;
            _loc3_ = 0;
            _loc5_ = true;
         }
         else if(_loc3_ >= screenWidth - 70)
         {
            material.visible = false;
            _loc3_ = screenWidth - 70;
            _loc5_ = true;
         }
         if(_loc4_ <= 0)
         {
            material.visible = false;
            _loc4_ = 0;
            _loc5_ = true;
         }
         else if(_loc4_ >= screenHeight - 70)
         {
            material.visible = false;
            _loc4_ = screenHeight - 70;
            _loc5_ = true;
         }
         if(_loc5_)
         {
            bubbleExplode();
            API.setScalable(2);
            return;
         }
      }
      
      private function bubbleExplode() : void
      {
         dispatchEvent(new GameEvent(GameEvent.BUBBLE_HIT_SCREEN));
      }
      
      public function deleteChance() : void
      {
         API.remoteCall(API.getWindowName(WindowNameOption.PARENT),"maindeleteChance",String(API.getWindowName(WindowNameOption.SELF)));
      }
   }
}
