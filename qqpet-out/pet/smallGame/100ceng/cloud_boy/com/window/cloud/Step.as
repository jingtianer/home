package com.window.cloud
{
   import flash.display.MovieClip;
   
   public class Step extends MovieClip
   {
       
      
      public var _state:String = "normal";
      
      public var _speed:Number = 0;
      
      public var _cloud:MovieClip;
      
      public var _move:Boolean = false;
      
      public var _frame:int = 1;
      
      public var _upSpeed:Number = 3;
      
      public function Step()
      {
         super();
      }
      
      public function createCloud1() : void
      {
         this._frame = 1;
         this._cloud = new Cloud1();
         addChild(this._cloud);
      }
      
      public function randomCloud() : void
      {
         this._upSpeed += Math.floor(CloudControl._sCount / 3) * 0.1;
         if(Math.random() < 0.3 + StepControl._removeTotal / 1000 && StepControl._stepArr.length > 2 && StepControl._two < 2)
         {
            ++StepControl._two;
            this._frame = 2;
            this._cloud = new Cloud2();
         }
         else
         {
            StepControl._two = 0;
            this._frame = 1;
            this._cloud = new Cloud1();
         }
         addChild(this._cloud);
         if(Math.random() < 0.3 + StepControl._removeTotal / 1000 && this._frame == 1 && StepControl._stepArr.length >= 2)
         {
            this._state = "leftright";
            this._speed = 5 + Math.floor(CloudControl._sCount / 3) * 0.1667;
            if(Math.random() < 0.5)
            {
               this._speed = -this._speed;
            }
         }
         else
         {
            this._state = "normal";
         }
      }
      
      public function stepMove() : void
      {
         if(this._move == false)
         {
            return;
         }
         this.y -= this._upSpeed;
         if(this._state == "leftright")
         {
            this.x += this._speed;
            if(this.x < this.width / 2 + 5)
            {
               this.x = this.width / 2 + 5;
               this._speed = -this._speed;
            }
            if(this.x > 350 - this.width / 2 - 5)
            {
               this.x = 350 - this.width / 2 - 5;
               this._speed = -this._speed;
            }
         }
      }
      
      private function removeCloud() : void
      {
         removeChild(this._cloud);
         this._cloud = null;
      }
   }
}
