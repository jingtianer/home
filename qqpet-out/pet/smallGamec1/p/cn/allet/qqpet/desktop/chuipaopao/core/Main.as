package cn.allet.qqpet.desktop.chuipaopao.core
{
   import cn.allet.qqpet.desktop.api.Tickle;
   import cn.allet.qqpet.desktop.chuipaopao.bubble.BlowBubbleMovie;
   import cn.allet.qqpet.desktop.chuipaopao.bubble.QMove;
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.filters.DropShadowFilter;
   import flash.system.fscommand;
   import flash.utils.Timer;
   
   public class Main extends BasicMain
   {
      
      public static var rank:String = "simple";
       
      
      public var blowBubbleMovie10_mc:BlowBubbleMovie;
      
      private var canNotUpArray:Array;
      
      private var canDoBlowBubbleArray:Array;
      
      public var blowBubbleMovie6_mc:BlowBubbleMovie;
      
      private var allBlowBubbleArray:Array;
      
      public var runRight:BlowBubbleMovie;
      
      public var blowBubbleMovie1_mc:BlowBubbleMovie;
      
      public var blowBubbleMovie11_mc:BlowBubbleMovie;
      
      private var nowblowBubbleArray:Array;
      
      public var blowBubbleMovie7_mc:BlowBubbleMovie;
      
      private var onlineMode:Boolean = true;
      
      public var gameLose_mc:MovieClip;
      
      public var blowBubbleMovie2_mc:BlowBubbleMovie;
      
      private var timeQuit:Timer;
      
      public var beginMovie_mc:MovieClip;
      
      private var canNotRightArray:Array;
      
      public var blowBubbleMovie8_mc:BlowBubbleMovie;
      
      private var canNotLeftArray:Array;
      
      public var upMove:QMove;
      
      public var blowBubbleMovie3_mc:BlowBubbleMovie;
      
      public var runLeft:BlowBubbleMovie;
      
      private var chance:int = 3;
      
      private var canNotDownArray:Array;
      
      public var blowBubbleMovie9_mc:BlowBubbleMovie;
      
      private var positionChanged:Boolean = true;
      
      public var initMoodValue:int;
      
      public var downMove:QMove;
      
      private var waitList:Array;
      
      public var maxMoodValue:int;
      
      private var moveInterval:int = 0;
      
      public var blowBubbleMovie5_mc:BlowBubbleMovie;
      
      private var frameBool:Boolean = false;
      
      private var countNum:int = 0;
      
      public function Main()
      {
         this.chance = 3;
         this.timeQuit = new Timer(10000,1);
         this.onlineMode = true;
         this.positionChanged = true;
         this.frameBool = false;
         this.countNum = 0;
         this.moveInterval = 0;
         super();
         window = new MainWindow(this);
         window.addEventListener(GameEvent.WINDOW_CREATE,this.windowCreateHandler);
         window.addEventListener(GameEvent.DELETE_CHANCE,this.deleteChance);
         window.addEventListener(GameEvent.ADD_COUNT,this.addCount);
         this.waitList = [Data.WND_NAME_STATUS_MOOD,Data.WND_NAME_STATUS_COUNT,Data.WND_NAME_PROMPT_MOOD,Data.WND_NAME_PROMPT_MONEY];
         filters = [new DropShadowFilter(0,0,0,0,0,0,0,0,false,false)];
      }
      
      private function _onMouseDown(param1:Event) : void
      {
         this.timeQuit.stop();
         this.timeQuit.removeEventListener(TimerEvent.TIMER,this.timeToQuit);
         this.timeQuit = null;
         this.beginMovie_mc.gotoAndStop(1);
         this.beginMovie_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this._onMouseDown);
         this.gameStart();
      }
      
      private function showBlowBubbleMovie(param1:GameEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:* = undefined;
         if(param1 != null)
         {
            if(param1.currentTarget == this.runRight || param1.currentTarget == this.runLeft || param1.currentTarget == this.upMove || param1.currentTarget == this.downMove)
            {
               this.positionChanged = true;
            }
            else
            {
               this.positionChanged = false;
            }
         }
         if(this.positionChanged)
         {
            this.canDoBlowBubbleArray = this.checkPosition();
         }
         do
         {
            if(rank == "difficult")
            {
               _loc2_ = this.setRunProbability(this.canDoBlowBubbleArray);
            }
            else
            {
               _loc3_ = int(Math.random() * this.canDoBlowBubbleArray.length);
               _loc2_ = this.canDoBlowBubbleArray[_loc3_];
            }
         }
         while(this.moveInterval < 2 && (_loc2_ == this.upMove || _loc2_ == this.downMove));
         
         if(_loc2_ == this.upMove || _loc2_ == this.downMove)
         {
            this.moveInterval = 0;
         }
         else
         {
            ++this.moveInterval;
         }
         _loc2_.showBlowBubbleMovie();
      }
      
      private function checkPosition() : Array
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         _loc1_ = MainWindow(window).checkScreenPosition();
         _loc2_ = 0;
         _loc3_ = this.nowblowBubbleArray.slice();
         if(_loc1_.up)
         {
            _loc2_ = 0;
            while(_loc2_ < this.canNotUpArray.length)
            {
               if(_loc3_.indexOf(this.canNotUpArray[_loc2_]) != -1)
               {
                  _loc3_.splice(_loc3_.indexOf(this.canNotUpArray[_loc2_]),1);
                  _loc2_--;
               }
               _loc2_++;
            }
         }
         if(_loc1_.down)
         {
            _loc2_ = 0;
            while(_loc2_ < this.canNotDownArray.length)
            {
               if(_loc3_.indexOf(this.canNotDownArray[_loc2_]) != -1)
               {
                  _loc3_.splice(_loc3_.indexOf(this.canNotDownArray[_loc2_]),1);
                  _loc2_--;
               }
               _loc2_++;
            }
         }
         if(_loc1_.left)
         {
            _loc2_ = 0;
            while(_loc2_ < this.canNotLeftArray.length)
            {
               if(_loc3_.indexOf(this.canNotLeftArray[_loc2_]) != -1)
               {
                  _loc3_.splice(_loc3_.indexOf(this.canNotLeftArray[_loc2_]),1);
                  _loc2_--;
               }
               _loc2_++;
            }
         }
         if(_loc1_.right)
         {
            _loc2_ = 0;
            while(_loc2_ < this.canNotRightArray.length)
            {
               if(_loc3_.indexOf(this.canNotRightArray[_loc2_]) != -1)
               {
                  _loc3_.splice(_loc3_.indexOf(this.canNotRightArray[_loc2_]),1);
                  _loc2_--;
               }
               _loc2_++;
            }
         }
         return _loc3_;
      }
      
      private function quit() : void
      {
         fscommand("quit");
      }
      
      private function timeToQuit(param1:TimerEvent) : void
      {
         this.timeQuit.stop();
         this.timeQuit.removeEventListener(TimerEvent.TIMER,this.timeToQuit);
         fscommand("quit");
      }
      
      private function _onEnterFrame(param1:Event) : void
      {
         if(BlowBubbleMovie.run == "right")
         {
            MainWindow(window).move(10,0);
         }
         else if(BlowBubbleMovie.run == "left")
         {
            MainWindow(window).move(-10,0);
         }
         else if(QMove.run == "up")
         {
            MainWindow(window).move(0,-10);
         }
         else if(QMove.run == "down")
         {
            MainWindow(window).move(0,10);
         }
      }
      
      private function windowCreateHandler(param1:GameEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         _loc2_ = this.waitList.indexOf(param1.param.name);
         if(_loc2_ != -1)
         {
            this.waitList.splice(_loc2_,1);
         }
         ExternalInterface.call("SMALLGAMEAPI.MSay","windowCreateHandler _loc2_",this.waitList);
         if(this.waitList.length == 0)
         {
            window.removeEventListener(GameEvent.WINDOW_CREATE,this.windowCreateHandler);
            removeChild(this.beginMovie_mc);
            this.beginMovie_mc = null;
            if(this.onlineMode)
            {
               _loc3_ = Tickle.getFeeling();
            }
            else
            {
               _loc3_ = {
                  "feelNow":200,
                  "feelTotal":1000
               };
            }
            this.initMoodValue = _loc3_.feelNow;
            this.maxMoodValue = _loc3_.feelTotal;
            MainWindow(window).upDataMoodCount(this.initMoodValue,this.maxMoodValue);
            MainWindow(window).upDateTitleAndCount("心情");
            this.showBlowBubbleMovie(null);
         }
      }
      
      private function deleteChance(param1:GameEvent) : void
      {
         --this.chance;
         if(this.chance <= 0)
         {
            this.gameOver(String(param1.param));
         }
      }
      
      private function addCount(param1:GameEvent) : void
      {
         ++this.countNum;
         ExternalInterface.call("SMALLGAMEAPI.MSay","addCount",this.countNum);
         if(this.countNum == 10)
         {
            rank = "center";
            this.setBlowBubbleArray(rank);
         }
         else if(this.countNum == 30)
         {
            rank = "difficult";
            this.setBlowBubbleArray(rank);
         }
         if(this.countNum < 999)
         {
            MainWindow(window).updateCount(this.countNum);
         }
         else
         {
            MainWindow(window).updateCount(999);
         }
         if(this.countNum % 5 == 0)
         {
            if(this.onlineMode)
            {
               MainWindow(window).sendAction(this.countNum);
            }
            else
            {
               MainWindow(window).onResult(55,1);
            }
         }
      }
      
      private function addMouseDownEvent() : void
      {
         if(this.frameBool)
         {
            return;
         }
         this.frameBool = true;
         this.beginMovie_mc.buttonMode = true;
         this.beginMovie_mc.addEventListener(MouseEvent.MOUSE_DOWN,this._onMouseDown);
         this.timeQuit.addEventListener(TimerEvent.TIMER,this.timeToQuit);
         this.timeQuit.start();
      }
      
      override public function init() : void
      {
         this.allBlowBubbleArray = [this.upMove,this.downMove,this.blowBubbleMovie1_mc,this.blowBubbleMovie2_mc,this.blowBubbleMovie3_mc,this.runRight,this.blowBubbleMovie5_mc,this.blowBubbleMovie6_mc,this.blowBubbleMovie7_mc,this.blowBubbleMovie8_mc,this.blowBubbleMovie9_mc,this.blowBubbleMovie10_mc,this.blowBubbleMovie11_mc,this.runLeft];
         this.nowblowBubbleArray = [this.blowBubbleMovie3_mc,this.blowBubbleMovie6_mc,this.blowBubbleMovie8_mc,this.blowBubbleMovie9_mc,this.blowBubbleMovie10_mc,this.blowBubbleMovie11_mc];
         this.canDoBlowBubbleArray = this.nowblowBubbleArray;
         if(currentLabel == "adult")
         {
            this.canNotRightArray = [this.blowBubbleMovie1_mc,this.blowBubbleMovie2_mc,this.runRight,this.blowBubbleMovie6_mc,this.blowBubbleMovie9_mc];
            this.canNotLeftArray = [this.blowBubbleMovie2_mc,this.blowBubbleMovie3_mc,this.blowBubbleMovie5_mc,this.blowBubbleMovie10_mc,this.blowBubbleMovie11_mc,this.runLeft];
            this.canNotUpArray = [this.upMove,this.blowBubbleMovie1_mc,this.runRight,this.blowBubbleMovie6_mc,this.blowBubbleMovie8_mc,this.blowBubbleMovie10_mc,this.runLeft];
            this.canNotDownArray = [this.downMove,this.blowBubbleMovie2_mc,this.blowBubbleMovie7_mc,this.blowBubbleMovie9_mc,this.blowBubbleMovie11_mc];
         }
         else
         {
            this.canNotRightArray = [this.blowBubbleMovie1_mc,this.runRight,this.blowBubbleMovie6_mc,this.blowBubbleMovie7_mc,this.blowBubbleMovie9_mc];
            this.canNotLeftArray = [this.blowBubbleMovie3_mc,this.blowBubbleMovie5_mc,this.blowBubbleMovie10_mc,this.blowBubbleMovie11_mc,this.runLeft];
            this.canNotUpArray = [this.upMove,this.blowBubbleMovie1_mc,this.blowBubbleMovie2_mc,this.runRight,this.blowBubbleMovie6_mc,this.blowBubbleMovie10_mc,this.runLeft];
            this.canNotDownArray = [this.downMove,this.blowBubbleMovie8_mc,this.blowBubbleMovie9_mc,this.blowBubbleMovie11_mc];
         }
         this.beginMovie_mc.addFrameScript(this.beginMovie_mc.currentLabels[0].frame - 1,this.addMouseDownEvent);
         BlowBubbleMovie.win = MainWindow(window);
         this.initAllBlowBubbleMovieMc();
      }
      
      private function setBlowBubbleArray(param1:String) : void
      {
         if(param1 == "center")
         {
            this.nowblowBubbleArray = [this.blowBubbleMovie1_mc,this.blowBubbleMovie2_mc,this.blowBubbleMovie6_mc,this.blowBubbleMovie7_mc,this.blowBubbleMovie8_mc,this.upMove,this.downMove];
            this.canDoBlowBubbleArray = this.checkPosition();
         }
         else
         {
            this.nowblowBubbleArray = this.allBlowBubbleArray;
            this.canDoBlowBubbleArray = this.checkPosition();
         }
      }
      
      private function gameStart() : void
      {
         var firstBubble:BlowBubbleMovie = null;
         ExternalInterface.call("SMALLGAMEAPI.MSay","gameStart","start");
         addEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         MainWindow(window).createAllChildrenWindow();
      }
      
      private function setRunProbability(param1:Array) : MovieClip
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Number = NaN;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:Number = NaN;
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:int = 0;
         if(param1.indexOf(this.runLeft) != -1 && param1.indexOf(this.runRight) != -1)
         {
            _loc3_ = Math.random();
            if(_loc3_ < 1 / 6)
            {
               _loc2_ = this.runLeft;
            }
            else if(_loc3_ > 1 / 6 && _loc3_ < 1 / 3)
            {
               _loc2_ = this.runRight;
            }
            else
            {
               (_loc4_ = param1.slice()).splice(param1.indexOf(this.runLeft),1);
               _loc4_.splice(param1.indexOf(this.runRight),1);
               _loc5_ = int(Math.random() * _loc4_.length);
               _loc2_ = _loc4_[_loc5_];
            }
         }
         else if(param1.indexOf(this.runLeft) != -1 && param1.indexOf(this.runRight) == -1)
         {
            if((_loc6_ = Math.random()) < 1 / 3)
            {
               _loc2_ = this.runLeft;
            }
            else
            {
               (_loc7_ = param1.slice()).splice(param1.indexOf(this.runLeft),1);
               _loc8_ = int(Math.random() * _loc7_.length);
               _loc2_ = _loc7_[_loc8_];
            }
         }
         else if(param1.indexOf(this.runLeft) == -1 && param1.indexOf(this.runRight) != -1)
         {
            if((_loc9_ = Math.random()) < 1 / 3)
            {
               _loc2_ = this.runRight;
            }
            else
            {
               (_loc10_ = param1.slice()).splice(param1.indexOf(this.runRight),1);
               _loc11_ = int(Math.random() * _loc10_.length);
               _loc2_ = _loc10_[_loc11_];
            }
         }
         else
         {
            _loc12_ = Math.random();
            if(this.moveInterval >= 2 && _loc12_ < 1 / 3)
            {
               _loc2_ = this.downMove;
            }
            else
            {
               _loc13_ = int(Math.random() * param1.length);
               _loc2_ = param1[_loc13_];
            }
         }
         return _loc2_;
      }
      
      private function initAllBlowBubbleMovieMc() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(currentLabel == "adult")
         {
            this.blowBubbleMovie1_mc.direction = "rightMore";
            this.blowBubbleMovie1_mc.count = Data.oneHeap;
            this.blowBubbleMovie1_mc.bubbleArray = ["Pink","Green","Blue","Pink","Green","Orange"];
            this.blowBubbleMovie2_mc.direction = "rightMore";
            this.blowBubbleMovie2_mc.count = Data.twoHeap;
            this.blowBubbleMovie2_mc.bubbleArray = ["Pink","Orange","Blue","Orange","Blue","Green"];
            this.blowBubbleMovie3_mc.direction = "left";
            this.blowBubbleMovie3_mc.count = Data.onlyOne;
            this.blowBubbleMovie3_mc.bubbleArray = ["Pink"];
            this.runRight.direction = "runRight";
            this.runRight.count = Data.run;
            this.runRight.bubbleArray = ["Orange","Pink","Blue","Yellow","Green","Orange","Orange","Pink"];
            this.blowBubbleMovie5_mc.direction = "leftMore";
            this.blowBubbleMovie5_mc.count = Data.oneHeap;
            this.blowBubbleMovie5_mc.bubbleArray = ["Orange","Green","Pink","Blue","Orange","Green"];
            this.blowBubbleMovie6_mc.direction = "rightUp";
            this.blowBubbleMovie6_mc.count = Data.onlyOne;
            this.blowBubbleMovie6_mc.bubbleArray = ["Green"];
            this.blowBubbleMovie7_mc.direction = "downMore";
            this.blowBubbleMovie7_mc.count = Data.oneHeap;
            this.blowBubbleMovie7_mc.bubbleArray = ["Orange","Green","Pink","Blue","Orange","Pink"];
            this.blowBubbleMovie8_mc.direction = "up";
            this.blowBubbleMovie8_mc.count = Data.onlyOne;
            this.blowBubbleMovie8_mc.bubbleArray = ["Orange"];
            this.blowBubbleMovie9_mc.direction = "rightDown";
            this.blowBubbleMovie9_mc.count = Data.onlyOne;
            this.blowBubbleMovie9_mc.bubbleArray = ["Orange"];
            this.blowBubbleMovie10_mc.direction = "leftUp";
            this.blowBubbleMovie10_mc.count = Data.onlyOne;
            this.blowBubbleMovie10_mc.bubbleArray = ["Orange"];
            this.blowBubbleMovie11_mc.direction = "leftDown";
            this.blowBubbleMovie11_mc.count = Data.onlyOne;
            this.blowBubbleMovie11_mc.bubbleArray = ["Orange"];
            this.runLeft.direction = "runLeft";
            this.runLeft.count = Data.run;
            this.runLeft.bubbleArray = ["Orange","Pink","Blue","Yellow","Green","Orange","Orange","Pink"];
         }
         else
         {
            this.blowBubbleMovie1_mc.direction = "rightMore";
            this.blowBubbleMovie1_mc.count = Data.oneHeap;
            this.blowBubbleMovie1_mc.bubbleArray = ["Blue","Green","Pink","Green"];
            this.blowBubbleMovie2_mc.direction = "upMore";
            this.blowBubbleMovie2_mc.count = Data.twoHeap;
            this.blowBubbleMovie2_mc.bubbleArray = ["Pink","Orange","Blue","Orange","Blue","Green"];
            this.blowBubbleMovie3_mc.direction = "left";
            this.blowBubbleMovie3_mc.count = Data.onlyOne;
            this.blowBubbleMovie3_mc.bubbleArray = ["Blue"];
            this.runRight.direction = "runRight";
            this.runRight.count = Data.run;
            this.runRight.bubbleArray = ["Green","Orange","Pink","Pink","Green","Blue","Blue","Orange"];
            this.blowBubbleMovie5_mc.direction = "leftMore";
            this.blowBubbleMovie5_mc.count = Data.oneHeap;
            this.blowBubbleMovie5_mc.bubbleArray = ["BLue","Green","Pink","Blue","Orange","Pink"];
            this.blowBubbleMovie6_mc.direction = "rightUp";
            this.blowBubbleMovie6_mc.count = Data.onlyOne;
            this.blowBubbleMovie6_mc.bubbleArray = ["Pink"];
            this.blowBubbleMovie7_mc.direction = "rightMore";
            this.blowBubbleMovie7_mc.count = Data.oneHeap;
            this.blowBubbleMovie7_mc.bubbleArray = ["Blue","Pink","Green","Green","Orange","Blue"];
            this.blowBubbleMovie8_mc.direction = "down";
            this.blowBubbleMovie8_mc.count = Data.onlyOne;
            this.blowBubbleMovie8_mc.bubbleArray = ["Green"];
            this.blowBubbleMovie9_mc.direction = "rightDown";
            this.blowBubbleMovie9_mc.count = Data.onlyOne;
            this.blowBubbleMovie9_mc.bubbleArray = ["Green"];
            this.blowBubbleMovie10_mc.direction = "leftUp";
            this.blowBubbleMovie10_mc.count = Data.onlyOne;
            this.blowBubbleMovie10_mc.bubbleArray = ["Green"];
            this.blowBubbleMovie11_mc.direction = "leftDown";
            this.blowBubbleMovie11_mc.count = Data.onlyOne;
            this.blowBubbleMovie11_mc.bubbleArray = ["Green"];
            this.runLeft.direction = "runLeft";
            this.runLeft.count = Data.run;
            this.runLeft.bubbleArray = ["Orange","Pink","Blue","Yellow","Green","Orange","Orange","Pink"];
         }
         _loc1_ = this.allBlowBubbleArray.length;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(_loc2_ >= 2)
            {
               this.allBlowBubbleArray[_loc2_].initFrameScript();
               this.allBlowBubbleArray[_loc2_].addEventListener(GameEvent.MOVE_PLAY_OVER,this.showBlowBubbleMovie);
            }
            else
            {
               this.allBlowBubbleArray[_loc2_].addEventListener(GameEvent.QMOVE_OVER,this.showBlowBubbleMovie);
            }
            _loc2_++;
         }
      }
      
      private function gameOver(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         removeEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         MainWindow(window).destroyAllChildrenWindow(param1);
         _loc2_ = this.allBlowBubbleArray.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            this.allBlowBubbleArray[_loc3_].gotoAndStop(1);
            this.allBlowBubbleArray[_loc3_].visible = false;
            _loc3_++;
         }
         this.gameLose_mc.visible = true;
         this.gameLose_mc.play();
         this.gameLose_mc.addFrameScript(this.gameLose_mc.totalFrames - 1,this.quit);
      }
   }
}
