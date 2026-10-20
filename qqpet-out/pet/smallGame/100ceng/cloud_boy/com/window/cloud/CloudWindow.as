package com.window.cloud
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.WindowNameOption;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import cn.allet.qqpet.desktop.util.BasicWindow;
   
   public class CloudWindow extends BasicWindow
   {
      
      public static var Root:CloudWindow;
       
      
      private var pWndName:String;
      
      private var cWndName:String;
      
      public function CloudWindow(param1:BasicMain)
      {
         super(param1);
      }
      
      override protected function init() : void
      {
         trace("云初始化");
         Root = this;
         API.registerFunction("allCreate",this.allCreate);
         this.cWndName = API.getWindowName(WindowNameOption.SELF);
         this.pWndName = API.getWindowName(WindowNameOption.PARENT);
         API.remoteCall(this.pWndName,"WindowCreateComplete",this.cWndName);
      }
      
      public function allCreate() : void
      {
         CloudControl.getInstance().startAnimation();
      }
      
      public function showPlayer() : void
      {
         API.remoteCall(this.pWndName,"playerShow",this.cWndName);
      }
      
      public function gameOver() : void
      {
         API.remoteCall(this.pWndName,"gameOver",this.cWndName);
      }
      
      public function clickStart() : void
      {
         API.remoteCall(this.pWndName,"clickStart",this.cWndName);
      }
   }
}
