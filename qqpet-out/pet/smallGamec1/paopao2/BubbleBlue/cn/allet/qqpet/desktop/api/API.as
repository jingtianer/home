package cn.allet.qqpet.desktop.api
{
   import flash.external.ExternalInterface;
   
   public class API
   {
       
      
      public function API()
      {
         super();
      }
      
      public static function isVisible(param1:String = null) : int
      {
         if(param1 == null || param1 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.IsVisiblePaopao");
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.IsVisiblePaopao",param1);
      }
      
      public static function isEnableDrag(param1:String = null) : int
      {
         if(param1 == null || param1 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.IsEnableDrag");
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.IsEnableDrag",param1);
      }
      
      public static function destroyWindow(param1:String = null) : int
      {
         if(param1 == null || param1 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.DestroyWindow");
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.DestroyWindow",param1);
      }
      
      public static function resizeWindow(param1:int, param2:int, param3:String = null) : int
      {
         if(param3 == null || param3 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.ResizeWindow",param1,param2);
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.ResizeWindow",param1,param2,param3);
      }
      
      public static function moveBy(param1:int, param2:int, param3:String = null) : int
      {
         if(param3 == null || param3 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.MoveBy",param1,param2);
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.MoveBy",param1,param2,param3);
      }
      
      public static function getWindowRect(param1:String = null) : String
      {
         if(param1 == null || param1 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.GetWindowRect");
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.GetWindowRect",param1);
      }
      
      public static function getScalable(param1:String = null) : Number
      {
         if(param1 == null || param1 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.GetScalable");
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.GetScalable",param1);
      }
      
      public static function createWindow(param1:String, param2:int = 0, param3:int = 0, param4:int = 0, param5:int = 0, param6:int = 0, param7:String = null, param8:int = 0, param9:String = null) : int
      {
         return ExternalInterface.call("SMALLGAMEAPIPP.CreateWindow",param1,param2,param3,param4,param5,param6,param7,param8,param9);
      }
      
      public static function getSwfSize(param1:String) : String
      {
         return ExternalInterface.call("SMALLGAMEAPIPP.GetFlashFileSize",param1);
      }
      
      public static function getWindowPosition(param1:Boolean = false) : String
      {
         if(param1)
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.GetWindowPosition",1);
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.GetWindowPosition",0);
      }
      
      public static function getWindowName(param1:int) : *
      {
         return ExternalInterface.call("SMALLGAMEAPIPP.GetWindowName",param1);
      }
      
      public static function setWindow(param1:String, param2:String = null, param3:String = null) : void
      {
         if(param2 == null || param2 == "")
         {
            ExternalInterface.call("SMALLGAMEAPIPP.SetWindow",param1,"",param3);
         }
         else
         {
            ExternalInterface.call("SMALLGAMEAPIPP.SetWindow",param1,param2,param3);
         }
      }
      
      public static function moveTo(param1:int, param2:int, param3:String = null) : int
      {
         if(param3 == null || param3 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.MoveTo",param1,param2);
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.MoveTo",param1,param2,param3);
      }
      
      public static function showWindow(param1:int, param2:String = null) : int
      {
         if(param2 == null || param2 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.Show",param1);
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.Show",param1,param2);
      }
      
      public static function getCursorPosition(param1:Boolean = false) : String
      {
         if(param1)
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.GetCursorPosition",1);
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.GetCursorPosition",0);
      }
      
      public static function setScalable(param1:Number, param2:String = null) : int
      {
         if(param2 == null || param2 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.SetScalable",param1);
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.SetScalable",param1,param2);
      }
      
      public static function isReady() : Boolean
      {
         return ExternalInterface.available;
      }
      
      public static function registerFunction(param1:String, param2:Function) : void
      {
         ExternalInterface.addCallback(param1,param2);
      }
      
      public static function remoteCall(param1:String, param2:String, ... rest) : *
      {
         var _loc4_:* = undefined;
         switch(rest.length)
         {
            case 0:
               _loc4_ = ExternalInterface.call("SMALLGAMEAPIPP.RemoteCall",param1,param2);
               break;
            case 1:
               _loc4_ = ExternalInterface.call("SMALLGAMEAPIPP.RemoteCall",param1,param2,rest[0]);
               break;
            case 2:
               _loc4_ = ExternalInterface.call("SMALLGAMEAPIPP.RemoteCall",param1,param2,rest[0],rest[1]);
               break;
            case 3:
               _loc4_ = ExternalInterface.call("SMALLGAMEAPIPP.RemoteCall",param1,param2,rest[0],rest[1],rest[2]);
               break;
            case 4:
               _loc4_ = ExternalInterface.call("SMALLGAMEAPIPP.RemoteCall",param1,param2,rest[0],rest[1],rest[2],rest[3]);
               break;
            case 5:
               _loc4_ = ExternalInterface.call("SMALLGAMEAPIPP.RemoteCall",param1,param2,rest[0],rest[1],rest[2],rest[3],rest[4]);
         }
         return _loc4_;
      }
      
      public static function enableDrag(param1:Boolean, param2:String = null) : int
      {
         var _loc3_:int = 0;
         if(param1)
         {
            _loc3_ = 1;
         }
         else
         {
            _loc3_ = 0;
         }
         if(param2 == null || param2 == "")
         {
            return ExternalInterface.call("SMALLGAMEAPIPP.EnableDrag",_loc3_);
         }
         return ExternalInterface.call("SMALLGAMEAPIPP.EnableDrag",_loc3_,param2);
      }
   }
}
