package com.window.cloud
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.WindowOperation;
   import com.tool.HitTest;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.system.Capabilities;
   
   public class CloudControl extends MovieClip
   {
      
      public static var _instance:CloudControl;
      
      public static var _sCount:int = 0;
       
      
      public var _startAnimation:StartAnimation;
      
      private var _darkCloud:DarkCloud;
      
      private var pWndName:String;
      
      private var cWndName:String;
      
      private var _player:Boolean = false;
      
      private var _positonCX:Number = 0;
      
      private var _positonCY:Number = 0;
      
      private var _positonC:Array;
      
      private var _positonPX:Number = 0;
      
      private var _positonPY:Number = 0;
      
      private var _positonP:Array;
      
      private var _fristDown:Boolean = true;
      
      private var _targetY:Number = 0;
      
      private var _add:Number = 0;
      
      private var _hit:Boolean = false;
      
      private var _time:int = 0;
      
      private var _countTime:int = 0;
      
      private var _left:Boolean = false;
      
      private var _right:Boolean = false;
      
      private var _touchStep:Array;
      
      private var _drakCloudBroken:DarkCloudBroken;
      
      private var _outScence:Boolean = false;
      
      private var _count:int = 0;
      
      public function CloudControl()
      {
         this._positonC = [];
         this._positonP = [];
         this._touchStep = [];
         super();
      }
      
      public static function getInstance() : CloudControl
      {
         if(!_instance)
         {
            _instance = new CloudControl();
         }
         return _instance;
      }
      
      public function startAnimation() : void
      {
         this.addEventListener("createDarkCloud",this.createDarkCloud);
         this.addEventListener("playerShow",this.playerShow);
         this.addEventListener("startCreateCloud",this.startCreateCloud);
         this.addEventListener("addEvent",this.addEvent);
         this._startAnimation = new StartAnimation();
         addChild(this._startAnimation);
      }
      
      private function createDarkCloud(param1:Event) : void
      {
         this.removeEventListener("createDarkCloud",this.createDarkCloud);
         this._darkCloud = new DarkCloud();
         addChildAt(this._darkCloud,0);
      }
      
      private function playerShow(param1:Event) : void
      {
         this.removeEventListener("playerShow",this.playerShow);
         CloudWindow.Root.showPlayer();
         this._targetY = Capabilities.screenResolutionY - 127;
         this._player = true;
      }
      
      private function startCreateCloud(param1:Event) : void
      {
         this.removeEventListener("startCreateCloud",this.startCreateCloud);
         addChild(StepControl.getInstance());
         StepControl.getInstance().startCloud();
         this.addEventListener(Event.ENTER_FRAME,this.frameIng);
         this._countTime = 0;
         this._time = 36;
      }
      
      private function addEvent(param1:Event) : void
      {
         API.setWindow(WindowOperation.TOP_MOST,"w_name_cloud");
         this.removeEventListener("addEvent",this.addEvent);
         this.removeEventListener(Event.ENTER_FRAME,this.frameIng);
         this.mouseChildren = false;
         this.buttonMode = true;
         this.addEventListener(MouseEvent.CLICK,this.startGame);
      }
      
      private function startGame(param1:MouseEvent = null) : void
      {
         CloudWindow.Root.clickStart();
         this.buttonMode = false;
         removeChild(this._startAnimation);
         this.removeEventListener(MouseEvent.CLICK,this.startGame);
         this.addEventListener(Event.ENTER_FRAME,this.frameIng);
         CloudMain._stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownFun);
         CloudMain._stage.addEventListener(KeyboardEvent.KEY_UP,this.keyUpFun);
      }
      
      private function keyUpFun(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 37 && this._left)
         {
            this._left = false;
         }
         if(param1.keyCode == 39 && this._right)
         {
            this._right = false;
         }
         if(this._left == false && this._right == false && this._outScence == false)
         {
            API.remoteCall("w_name_player","PlayerStatus","stand");
         }
         if(this._left == false && this._right == false && this._outScence)
         {
            API.remoteCall("w_name_player","PlayerStatus","middleDown");
         }
         if(this._left)
         {
            if(this._outScence)
            {
               API.remoteCall("w_name_player","PlayerStatus","leftDown");
            }
            else
            {
               API.remoteCall("w_name_player","PlayerStatus","leftMove");
            }
         }
         if(this._right)
         {
            if(this._outScence)
            {
               API.remoteCall("w_name_player","PlayerStatus","rightDown");
            }
            else
            {
               API.remoteCall("w_name_player","PlayerStatus","rightMove");
            }
         }
      }
      
      private function keyDownFun(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 37 && this._left == false)
         {
            this._left = true;
            if(this._outScence)
            {
               API.remoteCall("w_name_player","PlayerStatus","leftDown");
            }
            else
            {
               API.remoteCall("w_name_player","PlayerStatus","leftMove");
            }
         }
         if(param1.keyCode == 39 && this._right == false)
         {
            this._right = true;
            if(this._outScence)
            {
               API.remoteCall("w_name_player","PlayerStatus","rightDown");
            }
            else
            {
               API.remoteCall("w_name_player","PlayerStatus","rightMove");
            }
         }
      }
      
      private function frameIng(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         ++this._countTime;
         if(this._countTime >= this._time && this._outScence == false)
         {
            this._countTime = 0;
            _loc4_ = Math.floor(110 / (3 + Math.floor(CloudControl._sCount / 3) * 0.1));
            _loc5_ = Math.floor(130 / (3 + Math.floor(CloudControl._sCount / 3) * 0.1));
            this._time = _loc4_ + Math.floor((_loc5_ - _loc4_) * Math.random());
            StepControl.getInstance().createCloud();
            ++this._count;
            if(this._count == 1)
            {
               this._time = 40;
            }
            if(this._count >= 3)
            {
               CloudWindow.Root.clickStart();
               ++_sCount;
            }
         }
         this._hit = false;
         var _loc2_:int = 0;
         while(_loc2_ < StepControl._stepArr.length)
         {
            StepControl._stepArr[_loc2_].stepMove();
            _loc2_++;
         }
         _loc2_ = StepControl._stepArr.length - 1;
         while(_loc2_ >= 0)
         {
            if(HitTest.complexHitTestObject(this._darkCloud,StepControl._stepArr[_loc2_]))
            {
               StepControl._stepArr[_loc2_].dispatchEvent(new Event("removeStep",true));
            }
            _loc2_--;
         }
         if(this._player)
         {
            this._add += 3;
         }
         this._positonP = API.getWindowRect("w_name_player").split(",");
         this._positonPX = this._positonP[0];
         this._positonPY = this._positonP[1];
         this._positonC = API.getWindowRect("w_name_cloud").split(",");
         this._positonCX = this._positonC[0];
         this._positonCY = this._positonC[1];
         if(this._player)
         {
            this._positonPY += this._add;
            if(this._positonPY > this._targetY)
            {
               this._positonPY = this._targetY;
               this.removeCloud();
               if(this._left)
               {
                  API.remoteCall("w_name_player","PlayerStatus","leftSave");
               }
               else if(this._right)
               {
                  API.remoteCall("w_name_player","PlayerStatus","rightSave");
               }
               else
               {
                  API.remoteCall("w_name_player","PlayerStatus","middleSave");
               }
               API.moveTo(this._positonPX,this._positonPY,"w_name_player");
               this.removeEvent();
               return;
            }
         }
         if(this._left)
         {
            this._positonPX -= 8;
         }
         if(this._right)
         {
            this._positonPX += 8;
         }
         var _loc3_:int = 0;
         while(_loc3_ < StepControl._stepArr.length)
         {
            if(this._outScence == false && this._player && StepControl._stepArr[_loc3_]._move && Math.abs(this._positonCX + StepControl._stepArr[_loc3_].x - (this._positonPX + 70)) <= StepControl._stepArr[_loc3_].width / 2 + 20 && Math.abs(this._positonCY + StepControl._stepArr[_loc3_].y - (this._positonPY + 127)) <= this._add + 10)
            {
               this._hit = true;
               this._positonPY = StepControl._stepArr[_loc3_].y + this._positonCY - 126.8;
               if(this._fristDown)
               {
                  this._fristDown = false;
                  API.remoteCall("w_name_player","PlayerStatus","fristDown");
               }
               if(StepControl._stepArr[_loc3_]._state == "leftright")
               {
                  this._positonPX += StepControl._stepArr[_loc3_]._speed;
               }
               this._add = 0;
               if(StepControl._stepArr[_loc3_]._frame == 2)
               {
                  StepControl._stepArr[_loc3_]._frame = 0;
                  StepControl._stepArr[_loc3_]._upSpeed = -StepControl._stepArr[_loc3_]._upSpeed * 2;
                  this._touchStep.push(StepControl._stepArr[_loc3_]);
               }
               API.moveTo(this._positonPX,this._positonPY,"w_name_player");
               API.moveTo(this._positonPX - 30,this._positonPY,"wnd_name_prompt_money");
               API.moveTo(this._positonPX - 30,this._positonPY,"wnd_name_prompt_mood");
               break;
            }
            _loc3_++;
         }
         if(this._hit == false && this._player)
         {
            API.moveTo(this._positonPX,this._positonPY,"w_name_player");
            API.moveTo(this._positonPX - 30,this._positonPY,"wnd_name_prompt_money");
            API.moveTo(this._positonPX - 30,this._positonPY,"wnd_name_prompt_mood");
         }
         if(this._player && this._positonPY - this._positonCY < -15)
         {
            this.removeCloud();
            API.remoteCall("w_name_player","PlayerStatus","hurt");
            this.removeEvent();
         }
         if(this._touchStep.length > 0)
         {
            _loc6_ = this._touchStep.length - 1;
            while(_loc6_ >= 0)
            {
               _loc2_ = StepControl._stepArr.length - 1;
               while(_loc2_ >= 0)
               {
                  if(this._touchStep[_loc6_] != StepControl._stepArr[_loc2_] && HitTest.complexHitTestObject(this._touchStep[_loc6_],StepControl._stepArr[_loc2_]) || this._touchStep[_loc6_].y >= 470)
                  {
                     this._touchStep[_loc6_].dispatchEvent(new Event("removeStep",true));
                     this._touchStep[_loc6_] = null;
                     this._touchStep.splice(_loc6_,1);
                     break;
                  }
                  _loc2_--;
               }
               _loc6_--;
            }
         }
         if(this._outScence == false && this._positonPY - this._positonCY > 500 - 127)
         {
            this._outScence = true;
            this.removeCloud();
            if(this._left)
            {
               API.remoteCall("w_name_player","PlayerStatus","leftDown");
            }
            else if(this._right)
            {
               API.remoteCall("w_name_player","PlayerStatus","rightDown");
            }
            else
            {
               API.remoteCall("w_name_player","PlayerStatus","middleDown");
            }
         }
      }
      
      public function removeCloud() : void
      {
         if(this._darkCloud)
         {
            removeChild(this._darkCloud);
            this._darkCloud = null;
            this._drakCloudBroken = new DarkCloudBroken();
            addChild(this._drakCloudBroken);
            StepControl.getInstance().removeAllCloud();
         }
      }
      
      private function removeEvent() : void
      {
         this.removeEventListener(Event.ENTER_FRAME,this.frameIng);
         CloudMain._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownFun);
         CloudMain._stage.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpFun);
         CloudWindow.Root.gameOver();
      }
   }
}
