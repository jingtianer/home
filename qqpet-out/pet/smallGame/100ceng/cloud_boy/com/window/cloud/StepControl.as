package com.window.cloud
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.Timer;
   
   public class StepControl extends MovieClip
   {
      
      public static var Root:StepControl;
      
      public static var _disY:Number = 110;
      
      public static var _upSpeed:Number = 3;
      
      public static var _stepArr:Array = [];
      
      public static var _removeTotal:int = 0;
      
      public static var _two:int = 0;
      
      public static var _instance:StepControl;
       
      
      private var _stepNum:int = 4;
      
      private var _step:Step;
      
      public var _timer:Timer;
      
      private var _minTime:int = 1500;
      
      private var _time:int = 0;
      
      private var _broken:MovieClip;
      
      public function StepControl()
      {
         super();
         Root = this;
         _stepArr = [];
         _removeTotal = 0;
         this.addEventListener("pushStep",this.pushStep);
         this.addEventListener("removeStep",this.removeStep);
      }
      
      public static function getInstance() : StepControl
      {
         if(!_instance)
         {
            _instance = new StepControl();
         }
         return _instance;
      }
      
      private function removeStep(param1:Event) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < _stepArr.length)
         {
            if(param1.target == _stepArr[_loc2_])
            {
               this._broken = new Broken1();
               this._broken.x = _stepArr[_loc2_].x;
               this._broken.y = _stepArr[_loc2_].y;
               addChild(this._broken);
               removeChild(_stepArr[_loc2_]);
               _stepArr[_loc2_] = null;
               _stepArr.splice(_loc2_,1);
               ++_removeTotal;
               break;
            }
            _loc2_++;
         }
      }
      
      private function pushStep(param1:Event) : void
      {
         param1.target.parent._move = true;
      }
      
      public function startCloud() : void
      {
         this._step = new Step();
         this._step.createCloud1();
         this._step.x = 175;
         this._step.y = 460;
         addChild(this._step);
         _stepArr.push(this._step);
      }
      
      public function createCloud() : void
      {
         this._step = new Step();
         this._step.randomCloud();
         this._step.x = Math.floor(65 + 220 * Math.random());
         this._step.y = 460;
         addChild(this._step);
         _stepArr.push(this._step);
      }
      
      public function removeAllCloud() : void
      {
         var _loc1_:int = _stepArr.length - 1;
         while(_loc1_ >= 0)
         {
            _stepArr[_loc1_].dispatchEvent(new Event("removeStep",true));
            _loc1_--;
         }
      }
   }
}
