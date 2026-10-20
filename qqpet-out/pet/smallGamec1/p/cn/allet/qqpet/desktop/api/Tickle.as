package cn.allet.qqpet.desktop.api
{
   import flash.external.ExternalInterface;
   
   public class Tickle
   {
       
      
      public function Tickle()
      {
         super();
      }
      
      public static function getFeeling() : Object
      {
         return ExternalInterface.call("SMALLGAMEAPI.TICKLE_GetFeeling");
      }
      
      public static function sendAction(param1:int, param2:int) : void
      {
         ExternalInterface.call("SMALLGAMEAPI.TICKLE_SendAction",param1,param2);
      }
   }
}
