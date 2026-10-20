package com.window.cloud
{
   import cn.allet.qqpet.desktop.util.BasicMain;
   import flash.display.Stage;
   import flash.events.Event;
   
   public class CloudMain extends BasicMain
   {
      
      public static var _stage:Stage;
       
      
      public function CloudMain()
      {
         super();
         addChild(CloudControl.getInstance());
         window = new CloudWindow(this);
         this.addEventListener(Event.ADDED_TO_STAGE,this.addStage);
      }
      
      private function addStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addStage);
         _stage = stage;
      }
      
      override public function init() : void
      {
      }
   }
}
