package com.window.main
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.APIEvent;
   import cn.allet.qqpet.desktop.api.Tickle;
   import cn.allet.qqpet.desktop.api.TickleActionType;
   import cn.allet.qqpet.desktop.api.TickleEvent;
   import cn.allet.qqpet.desktop.api.WindowOperation;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import cn.allet.qqpet.desktop.util.BasicWindow;
   import flash.system.Capabilities;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   
   public class MainWindow extends BasicWindow
   {
      
      public static var Root:MainWindow;
      
      public static var _wScale:Number = 0;
       
      
      private var pWndName:String;
      
      private var cWndName:String;
      
      private var _wx:Number = 0;
      
      private var _wy:Number = 0;
      
      private var _pos:Array;
      
      private var _screenWidth:Number = 0;
      
      private var _screenHeight:Number = 0;
      
      private var _timer:Timer;
      
      private var _createNum:int = 2;
      
      private var _start:int = 0;
      
      public function MainWindow(param1:BasicMain)
      {
         this._pos = [];
         super(param1);
      }
      
      override protected function init() : void
      {
         trace("游戏初始化");
         Root = this;
         _wScale = API.getScalable();
         API.setScalable(1);
         API.enableDrag(true);
         API.registerFunction("WindowCreateComplete",this.createComplete);
         API.registerFunction("playerShow",this.playerShow);
         API.registerFunction(APIEvent.OnWindowMove,this.onWindowMove);
         API.registerFunction("gameOver",this.gameOver);
         API.registerFunction("clickStart",this.clickStart);
         this.createAllWindow();
         API.registerFunction(TickleEvent.OnResult,this.onResult);
      }
      
      private function createAllWindow() : void
      {
         this._pos = API.getWindowPosition(true).split(",");
         this._wx = Number(this._pos[0]);
         this._wy = Number(this._pos[1]);
         this._screenWidth = Capabilities.screenResolutionX;
         this._screenHeight = Capabilities.screenResolutionY;
         if(this._wx < 175 - 70)
         {
            this._wx = 175 - 70;
            API.moveTo(this._wx,this._wy);
         }
         if(this._wx > this._screenWidth - 140 - 175 + 70)
         {
            this._wx = this._screenWidth - 140 - 175 + 70;
            API.moveTo(this._wx,this._wy);
         }
         if(this._wy < 310 - 127)
         {
            this._wy = 310 - 127;
            API.moveTo(this._wx,this._wy);
         }
         if(this._wy > this._screenHeight - 320)
         {
            this._wy = this._screenHeight - 320;
            API.moveTo(this._wx,this._wy);
         }
         this._pos = API.getWindowPosition(true).split(",");
         this._wx = int(this._pos[0]);
         this._wy = int(this._pos[1]);
         API.createWindow("w_name_cloud",this._wx - 175 + 70,this._wy - 309.5 + 127,350,500,0,"cloud_boy.swf",1);
      }
      
      private function createComplete(param1:String) : void
      {
         --this._createNum;
         if(this._createNum == 1)
         {
            API.createWindow("w_name_player",this._wx,this._wy,140,140,1,"player_boy.swf",1);
         }
         if(this._createNum == 0)
         {
            API.remoteCall("w_name_cloud","allCreate");
            API.setWindow(WindowOperation.TOP_MOST,"w_name_player");
            API.createWindow("wnd_name_prompt_mood",this._wx,this._wy,180,90,0,"prompt_mood.swf");
            API.createWindow("wnd_name_prompt_money",this._wx,this._wy,300,180,0,"prompt_money.swf");
         }
      }
      
      private function playerShow(param1:String) : void
      {
         API.showWindow(1,"w_name_player");
         API.remoteCall("w_name_player","PlayerStatus","middleDown");
         this._wy -= 309.8 - 273.25;
         API.moveTo(this._wx,this._wy,"w_name_player");
      }
      
      private function onWindowMove(param1:int, param2:int, param3:int, param4:int) : void
      {
      }
      
      private function clickStart(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._start > 0)
         {
            ++this._start;
            _loc2_ = API.getWindowRect("w_name_player").split(",");
            _loc3_ = this._pos[0];
            _loc4_ = this._pos[1];
            if(this._start % 5 == 0)
            {
               Tickle.sendAction(TickleActionType.DOWN,this._start);
            }
            return;
         }
         ++this._start;
         API.setWindow(WindowOperation.TOP_MOST,"w_name_player");
         API.setWindow(WindowOperation.TOP_MOST,"wnd_name_prompt_mood");
         API.setWindow(WindowOperation.TOP_MOST,"wnd_name_prompt_money");
      }
      
      private function gameOver(param1:String) : void
      {
         setTimeout(GameMain.Root.exitGame,4000);
      }
      
      private function onResult(param1:uint, param2:uint) : void
      {
         var _loc3_:Object = null;
         _loc3_ = Tickle.getFeeling();
         if(param2 != 0)
         {
            API.remoteCall("wnd_name_prompt_money","MoneyPrompt.onMoneyPrompt");
         }
         if(param1 != 0)
         {
            API.remoteCall("wnd_name_prompt_mood","MoodPrompt.onMoodPrompt",true,param1);
         }
      }
      
      public function upDate() : void
      {
         var _loc1_:Object = null;
         _loc1_ = Tickle.getFeeling();
         API.remoteCall("wnd_name_status_mood","MoodStatus.onMoodUpdate",_loc1_.feelNow,_loc1_.feelTotal);
         API.remoteCall("wnd_name_status_count","CountStatus.onCountUpdate",this._start);
      }
   }
}
