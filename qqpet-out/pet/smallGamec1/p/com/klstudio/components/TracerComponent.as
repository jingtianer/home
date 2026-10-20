package com.klstudio.components
{
   import com.klstudio.util.Tracer;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class TracerComponent extends Sprite
   {
       
      
      klstudio_internal var _tracer:Tracer;
      
      public function TracerComponent()
      {
         var _loc1_:DisplayObject = null;
         super();
         _loc1_ = getChildAt(0);
         removeChild(_loc1_);
      }
   }
}
