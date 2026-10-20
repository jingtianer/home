package cn.allet.qqpet.desktop.chuipaopao.bubble
{
   import cn.allet.qqpet.desktop.chuipaopao.core.Data;
   import cn.allet.qqpet.desktop.chuipaopao.core.Main;
   import cn.allet.qqpet.desktop.chuipaopao.core.MainWindow;
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class BlowBubbleMovie extends MovieClip
   {
      
      public static var bubbleNum:int = 0;
      
      public static var run:String = "";
      
      public static var win:MainWindow;
       
      
      public var count:int;
      
      public var bubbleArray:Array;
      
      public var direction:String;
      
      private var random1:int;
      
      private var random2:int;
      
      private var nowCount:int = 0;
      
      public function BlowBubbleMovie()
      {
         nowCount = 0;
         super();
         stop();
         visible = false;
      }
      
      private function checkTwoRandom() : void
      {
         if(nowCount < random2)
         {
            showAndMoveBubbleWindow();
            ++nowCount;
         }
      }
      
      private function stopRun() : void
      {
         run = "";
      }
      
      public function showBlowBubbleMovie() : void
      {
         visible = true;
         if(count != Data.onlyOne)
         {
            produceRandom();
         }
         newBubble(null);
      }
      
      private function newBubble(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Timer = null;
         if(count != Data.onlyOne)
         {
            if(param1 == "two")
            {
               _loc2_ = random2;
            }
            else
            {
               _loc2_ = random1;
            }
         }
         else
         {
            _loc2_ = bubbleArray.length;
         }
         if(_loc2_ == 0)
         {
            play();
         }
         else
         {
            _loc3_ = new Timer(20,_loc2_);
            _loc3_.addEventListener(TimerEvent.TIMER,_onTimer);
            _loc3_.reset();
            _loc3_.start();
         }
      }
      
      private function _onTimer(param1:TimerEvent) : void
      {
         win.createBubbleWindow("bubble" + bubbleNum,"pet\\smallGame\\paopao2\\Bubble" + bubbleArray[param1.currentTarget.currentCount - 1] + ".swf");
         ++bubbleNum;
         if(param1.currentTarget.currentCount == param1.currentTarget.repeatCount)
         {
            param1.currentTarget.removeEventListener(TimerEvent.TIMER,_onTimer);
            play();
         }
      }
      
      public function initFrameScript() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _loc1_ = 0;
         switch(count)
         {
            case Data.onlyOne:
               addFrameScript(currentLabels[0].frame - 1,showAndMoveBubbleWindow);
               break;
            case Data.oneHeap:
               _loc2_ = currentLabels.length;
               _loc1_ = 0;
               while(_loc1_ < _loc2_)
               {
                  addFrameScript(currentLabels[_loc1_].frame - 1,checkOneRandom);
                  _loc1_++;
               }
               break;
            case Data.twoHeap:
               _loc1_ = 0;
               while(_loc1_ < 6)
               {
                  addFrameScript(currentLabels[_loc1_].frame - 1,checkOneRandom);
                  _loc1_++;
               }
               _loc1_ = 7;
               while(_loc1_ < 13)
               {
                  addFrameScript(currentLabels[_loc1_].frame - 1,checkTwoRandom);
                  _loc1_++;
               }
               addFrameScript(currentLabels[6].frame - 1,changeDirectionAndNewBubble);
               addFrameScript(currentLabels[currentLabels.length - 1].frame - 1,changeDirectionAndNewBubble);
               break;
            case Data.run:
               addFrameScript(currentLabels[0].frame - 1,startRun);
               _loc3_ = currentLabels.length - 1;
               _loc1_ = 1;
               while(_loc1_ < _loc3_)
               {
                  addFrameScript(currentLabels[_loc1_].frame - 1,checkOneRandom);
                  _loc1_++;
               }
               addFrameScript(currentLabels[_loc3_].frame - 1,stopRun);
         }
      }
      
      private function changeDirectionAndNewBubble() : void
      {
         nowCount = 0;
         direction = currentLabel.split("_")[0];
         if(currentLabel == currentLabels[currentLabels.length - 1].name)
         {
            bubbleArray = ["Pink","Orange","Blue","Orange","Blue","Green"];
            return;
         }
         bubbleArray = ["Green","Orange","Blue","Green","Pink","Blue"];
         newBubble("two");
      }
      
      private function checkOneRandom() : void
      {
         var _loc1_:MovieClip = null;
         if(nowCount < random1)
         {
            showAndMoveBubbleWindow();
            ++nowCount;
         }
         else
         {
            _loc1_ = getChildByName(currentLabel) as MovieClip;
            _loc1_.visible = false;
         }
      }
      
      private function produceRandom() : void
      {
         if(Main.rank == "center")
         {
            random1 = int(Math.random() * 2) + 2;
            random2 = int(Math.random() * 2) + 2;
         }
         else if(Main.rank == "difficult")
         {
            random1 = Math.min(currentLabels.length,int(Math.random() * 3) + 4);
            random2 = int(Math.random() * 3) + 4;
         }
      }
      
      private function startRun() : void
      {
         run = currentLabel;
      }
      
      private function showAndMoveBubbleWindow() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = getChildByName(currentLabel) as MovieClip;
         _loc1_.visible = false;
         win.setBubbleWindow(_loc1_.x + x,_loc1_.y + y,_loc1_.scaleX,direction);
      }
      
      private function _stop() : void
      {
         nowCount = 0;
         gotoAndStop(1);
         visible = false;
         dispatchEvent(new GameEvent(GameEvent.MOVE_PLAY_OVER));
      }
   }
}
