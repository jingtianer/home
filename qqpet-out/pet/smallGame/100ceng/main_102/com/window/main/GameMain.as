package com.window.main
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import flash.system.fscommand;
   
   public class GameMain extends BasicMain
   {
      
      public static var Root:GameMain;
       
      
      public function GameMain()
      {
         super();
         window = new MainWindow(this);
         Root = this;
      }
      
      override public function init() : void
      {
         trace("xxxxxxxxxx");
      }
      
      public function exitGame() : void
      {
         var _loc1_:Array = API.getWindowRect("w_name_player").split(",");
         var _loc2_:Number = _loc1_[0];
         var _loc3_:Number = _loc1_[1];
         API.moveTo(_loc2_ + (1 - MainWindow._wScale) * 140,_loc3_ + (1 - MainWindow._wScale) * 140);
         fscommand("quit");
      }
   }
}
