package com.klstudio.util
{
   import com.klstudio.events.TracerEvent;
   import flash.events.EventDispatcher;
   import flash.events.StatusEvent;
   import flash.net.LocalConnection;
   import flash.utils.getQualifiedClassName;
   
   public class Tracer extends EventDispatcher
   {
      
      private static var _tracer:Tracer;
       
      
      private var _conn:LocalConnection;
      
      private var _console:Boolean;
      
      private var _name:String = "debugConnection";
      
      public function Tracer(param1:Boolean = true)
      {
         var console:Boolean = param1;
         _name = "debugConnection";
         super();
         _conn = new LocalConnection();
         _conn.allowDomain("*");
         _console = console;
         if(isConsole())
         {
            _conn.client = this;
            try
            {
               _conn.connect(_name);
            }
            catch(error:ArgumentError)
            {
               output("连接错误:调试连接已经被打开!");
            }
         }
         else
         {
            _conn.addEventListener(StatusEvent.STATUS,statusHandler);
         }
      }
      
      public static function debug(param1:*) : void
      {
         if(_tracer == null)
         {
            _tracer = new Tracer(false);
         }
         _tracer.send(param1);
      }
      
      private function output(param1:String) : void
      {
         dispatchEvent(new TracerEvent(TracerEvent.DATA,param1 + "\n"));
      }
      
      private function send(param1:*) : void
      {
         var _loc2_:* = null;
         var _loc3_:uint = 0;
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         if(isConsole())
         {
            return;
         }
         _loc2_ = "";
         if(param1 == null)
         {
            _loc2_ = "null";
         }
         else if(param1 == undefined)
         {
            _loc2_ = "undefined";
         }
         else if(param1 is String || param1 is Number || param1 is int || param1 is uint || param1 is Boolean)
         {
            _loc2_ = param1.toString();
         }
         else if(param1 is Array || param1 is Date)
         {
            _loc2_ = "[" + getQualifiedClassName(param1) + "] " + param1.toString();
         }
         else if(getQualifiedClassName(param1) == "Object")
         {
            _loc2_ = "[Object] {";
            _loc3_ = 0;
            for(_loc4_ in param1)
            {
               _loc5_ = param1[_loc4_];
               if(_loc3_++ > 0)
               {
                  _loc2_ += ",";
               }
               _loc2_ += _loc4_ + ":";
               if(_loc5_ == null)
               {
                  _loc2_ += "null";
               }
               else if(_loc5_ == undefined)
               {
                  _loc2_ += "undefined";
               }
               else if(_loc5_ is String)
               {
                  _loc2_ += "\"" + _loc5_ + "\"";
               }
               else
               {
                  _loc2_ += _loc5_.toString();
               }
            }
            _loc2_ += "}";
         }
         else if(typeof param1 == "function")
         {
            _loc2_ = "[Function]";
         }
         else
         {
            _loc2_ = "[" + getQualifiedClassName(param1) + "]";
         }
         _conn.send(_name,"receive",_loc2_);
      }
      
      public function isConsole() : Boolean
      {
         return _console;
      }
      
      public function receive(param1:String) : void
      {
         if(isConsole())
         {
            output(param1);
         }
      }
      
      private function statusHandler(param1:StatusEvent) : void
      {
         if(param1.level == "error")
         {
            trace("发送失败:可能调试控制台没有打开!");
         }
      }
   }
}
