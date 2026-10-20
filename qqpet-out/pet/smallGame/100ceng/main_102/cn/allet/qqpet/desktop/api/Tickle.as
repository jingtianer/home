package cn.allet.qqpet.desktop.api
{
   import flash.external.ExternalInterface;
   
   public class Tickle
   {
       
      
      public function Tickle()
      {
         super();
      }
      
      public static function sendAction(param1:int, param2:int) : void
      {
         ExternalInterface.call("TICKLE_SendAction",param1,param2);
      }
      
      public static function getFeeling() : Object
      {
         return ExternalInterface.call("TICKLE_GetFeeling");
      }
   }
}
