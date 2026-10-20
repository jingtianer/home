package cn.allet.qqpet.desktop.chuipaopao.programbubble
{
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.DropShadowFilter;
   import flash.utils.Timer;
   
   public class BubbleMain extends BasicMain
   {
      
      public static var rank:String = "simple";
       
      
      public var bubble_mc:MovieClip;
      
      private var ay:Number = 0;
      
      private var ax:Number = 0;
      
      private var maxScale:Number;
      
      private var vx:Number = 0;
      
      private var vy:Number = 0;
      
      public function BubbleMain()
      {
         vx = 0;
         vy = 0;
         ax = 0;
         ay = 0;
         super();
         bubble_mc.stop();
         filters = [new DropShadowFilter(0,0,0,0,0,0,0,0,false,false)];
         window = new BubbleWindow(this);
         window.addEventListener(GameEvent.SET_BUBBLE_SCALE,setBubbleScaleAndMove);
         window.addEventListener(GameEvent.BUBBLE_HIT_SCREEN,_onHitScreen);
         bubble_mc.buttonMode = true;
      }
      
      private function _onHitScreen(param1:GameEvent) : void
      {
         bubble_mc.addFrameScript(1,show);
         bubble_mc.removeEventListener(MouseEvent.MOUSE_DOWN,_onMouseDown);
         removeEventListener(Event.ENTER_FRAME,_onEnterFrame);
         bubble_mc.play();
         BubbleWindow(window).deleteChance();
      }
      
      private function _onMouseDown(param1:MouseEvent) : void
      {
         BubbleWindow(window).updateCount();
         bubble_mc.removeEventListener(MouseEvent.MOUSE_DOWN,_onMouseDown);
         removeEventListener(Event.ENTER_FRAME,_onEnterFrame);
         bubble_mc.gotoAndPlay(bubble_mc.currentLabels[1].frame);
      }
      
      private function setBubbleScaleAndMove(param1:GameEvent) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = Number(param1.param[0]);
         bubble_mc.scaleX = _loc2_;
         bubble_mc.scaleY = _loc2_;
         if(rank == "simple")
         {
            maxScale = (Math.random() + 9) / 10;
         }
         else
         {
            maxScale = (Math.random() * 2 + 8) / 10;
         }
         addEventListener(Event.ENTER_FRAME,_onEnterFrame);
         bubble_mc.addEventListener(MouseEvent.MOUSE_DOWN,_onMouseDown);
         initSpeedAndAcceleration(param1.param[1]);
      }
      
      private function _onTimer(param1:TimerEvent) : void
      {
         var _loc2_:Array = null;
         param1.currentTarget.removeEventListener(TimerEvent.TIMER,_onTimer);
         _loc2_ = ["upMore","downMore","leftMore","rightMore"];
         initSpeedAndAcceleration(_loc2_[int(Math.random() * 4)]);
      }
      
      private function destorySelf() : void
      {
         bubble_mc.stop();
         bubble_mc.addFrameScript(bubble_mc.totalFrames - 1,null);
         bubble_mc.addFrameScript(bubble_mc.currentLabels[0].frame - 1,null);
         destroyWindow();
      }
      
      private function destroyWindow() : void
      {
         bubble_mc = null;
         BubbleWindow(window).destroy();
      }
      
      private function _onEnterFrame(param1:Event) : void
      {
         BubbleWindow(window).move(vx,vy);
         vx += ax;
         vy += ay;
         if(bubble_mc.scaleX >= maxScale)
         {
            return;
         }
         if(rank == "simple")
         {
            bubble_mc.scaleX += 0.05;
            bubble_mc.scaleY += 0.05;
         }
         else
         {
            bubble_mc.scaleX += 0.03;
            bubble_mc.scaleY += 0.03;
         }
      }
      
      private function initSpeedAndAcceleration(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Timer = null;
         var _loc6_:Timer = null;
         _loc2_ = 0;
         _loc3_ = 0;
         if(Math.random() > 0.5)
         {
            _loc2_ = 1;
         }
         else
         {
            _loc2_ = -1;
         }
         if(Math.random() > 0.5)
         {
            _loc3_ = 1;
         }
         else
         {
            _loc3_ = -1;
         }
         _loc4_ = 1;
         if(rank == "simple")
         {
            _loc4_ = 2;
         }
         else if(rank == "center")
         {
            _loc4_ = 1.5;
         }
         switch(param1)
         {
            case "leftMore":
               vx = _loc2_ * (Math.random() * 5 + 3) / _loc4_;
               vy = _loc3_ * (Math.random() * 5 + 3) / _loc4_;
               ax = _loc2_ * Math.random() / _loc4_;
               ay = _loc3_ * Math.random() / _loc4_;
               break;
            case "rightMore":
               vx = _loc2_ * (Math.random() * 5 + 3) / _loc4_;
               vy = _loc3_ * (Math.random() * 5 + 3) / _loc4_;
               ax = _loc2_ * Math.random() / _loc4_;
               ay = _loc3_ * Math.random() / _loc4_;
               break;
            case "upMore":
               vx = _loc2_ * (Math.random() * 5 + 3) / _loc4_;
               vy = _loc3_ * (Math.random() * 5 + 3) / _loc4_;
               ax = _loc2_ * Math.random() / _loc4_;
               ay = _loc3_ * Math.random() / _loc4_;
               break;
            case "downMore":
               vx = _loc2_ * (Math.random() * 5 + 3) / _loc4_;
               vy = _loc3_ * (Math.random() * 5 + 3) / _loc4_;
               ax = _loc2_ * Math.random() / _loc4_;
               ay = _loc3_ * Math.random() / _loc4_;
               break;
            case "up":
               vx = (Math.random() + 1) * _loc2_ / _loc4_;
               vy = -(Math.random() * 3 + 8) * 2 / _loc4_;
               ax = Math.random() * _loc2_ / _loc4_;
               ay = -Math.random() / 2 / _loc4_;
               break;
            case "down":
               vx = (Math.random() + 1) * _loc2_ / _loc4_;
               vy = (Math.random() * 3 + 8) * 2 / _loc4_;
               ax = Math.random() * _loc2_ / _loc4_;
               ay = Math.random() / 2 / _loc4_;
               break;
            case "left":
               vx = -(Math.random() * 3 + 8) * 2 / _loc4_;
               vy = (Math.random() + 1) * _loc3_ / _loc4_;
               ax = -Math.random() / 2 / _loc4_;
               ay = Math.random() * _loc3_ / _loc4_;
               break;
            case "right":
               vx = (Math.random() * 3 + 8) * 2 / _loc4_;
               vy = (Math.random() + 1) * _loc3_ / _loc4_;
               ax = Math.random() / 2 / _loc4_;
               ay = Math.random() * _loc3_ / _loc4_;
               break;
            case "rightUp":
               vx = (Math.random() * 3 + 8) * 2 / _loc4_;
               vy = 0;
               ax = Math.random() / 2 / _loc4_;
               ay = -(Math.random() * 2 + 2) / _loc4_;
               break;
            case "rightDown":
               vx = (Math.random() * 3 + 8) * 2 / _loc4_;
               vy = 0;
               ax = Math.random() / _loc4_;
               ay = Math.random() / _loc4_;
               break;
            case "leftUp":
               vx = -(Math.random() * 3 + 8) * 2 / _loc4_;
               vy = 0;
               ax = -Math.random() / 2 / _loc4_;
               ay = -(Math.random() * 2 + 2) / _loc4_;
               break;
            case "leftDown":
               vx = -(Math.random() * 3 + 8) * 2 / _loc4_;
               vy = 0;
               ax = -Math.random() / _loc4_;
               ay = Math.random() / _loc4_;
               break;
            case "runRight":
               vx = -(Math.random() * 4 + 4) * 1.5 / _loc4_;
               vy = (Math.random() * 2 + 3) * _loc3_ / _loc4_;
               ax = Math.random() / 3 / _loc4_;
               ay = Math.random() / 3 * _loc3_ / _loc4_;
               (_loc5_ = new Timer(1000,1)).addEventListener(TimerEvent.TIMER,_onTimer);
               _loc5_.start();
               break;
            case "runLeft":
               vx = (Math.random() * 4 + 4) * 1.5 / _loc4_;
               vy = (Math.random() * 2 + 3) * _loc3_ / _loc4_;
               ax = -Math.random() / 3 / _loc4_;
               ay = Math.random() / 3 * _loc3_ / _loc4_;
               (_loc6_ = new Timer(1000,1)).addEventListener(TimerEvent.TIMER,_onTimer);
               _loc6_.start();
         }
      }
      
      private function show() : void
      {
         visible = true;
         bubble_mc.addFrameScript(1,null);
      }
   }
}
