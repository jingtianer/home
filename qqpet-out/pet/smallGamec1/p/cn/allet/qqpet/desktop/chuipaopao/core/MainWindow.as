package cn.allet.qqpet.desktop.chuipaopao.core
{
   import cn.allet.qqpet.desktop.api.API;
   import cn.allet.qqpet.desktop.api.APIEvent;
   import cn.allet.qqpet.desktop.api.ShowCommand;
   import cn.allet.qqpet.desktop.api.Tickle;
   import cn.allet.qqpet.desktop.api.TickleActionType;
   import cn.allet.qqpet.desktop.api.TickleEvent;
   import cn.allet.qqpet.desktop.api.WindowNameOption;
   import cn.allet.qqpet.desktop.chuipaopao.events.GameEvent;
   import cn.allet.qqpet.desktop.util.BasicMain;
   import cn.allet.qqpet.desktop.util.BasicWindow;
   import flash.external.ExternalInterface;
   import flash.system.Capabilities;
   
   public class MainWindow extends BasicWindow
   {
       
      
      private var wx:int;
      
      private var wy:int;
      
      private var provisionalWindowArray:Array;
      
      public function MainWindow(param1:BasicMain)
      {
         this.provisionalWindowArray = [];
         super(param1);
         ExternalInterface.call("SMALLGAMEAPI.MSay","init BasicMain");
      }
      
      public function createAllChildrenWindow() : void
      {
         ExternalInterface.call("SMALLGAMEAPI.MSay","createAllChildrenWindow","start");
         API.createWindow(Data.WND_NAME_STATUS_MOOD,this.wx + 140 * (scale - 1) / 2,this.wy + 140 * scale + 20 * (scale - 1) / 2,140,20,0,Data.SWF_NAME_STATUS_MOOD);
         API.createWindow(Data.WND_NAME_STATUS_COUNT,this.wx - 80 * scale + 60 * (scale - 1) / 2,this.wy + 70 * scale + 55 * (scale - 1) / 2,60,55,0,Data.SWF_NAME_STATUS_COUNT);
         API.createWindow(Data.WND_NAME_PROMPT_MOOD,this.wx - 25 * scale + 180 * (scale - 1) / 2,this.wy - 12 * scale + 90 * (scale - 1) / 2,180,90,0,Data.SWF_NAME_PROMPT_MOOD);
         API.createWindow(Data.WND_NAME_PROMPT_MONEY,this.wx - 75 * scale + 300 * (scale - 1) / 2,this.wy + scale + 180 * (scale - 1) / 2,300,180,0,Data.SWF_NAME_PROMPT_MONEY);
      }
      
      private function onMouseDownBubble() : void
      {
        
         ExternalInterface.call("SMALLGAMEAPI.MSay","onMouseDownBubble",GameEvent.ADD_COUNT);
         dispatchEvent(new GameEvent(GameEvent.ADD_COUNT));
      }
      
      override protected function init() : void
      {
         var _loc1_:Array = null;
         API.registerFunction(APIEvent.OnWindowMove,this.onWindowMove);
         API.enableDrag(false);
         API.registerFunction("maindeleteChance",this.deleteChance);
         API.registerFunction("mainonMouseDownBubble",this.onMouseDownBubble);
         API.registerFunction("mainonWindowCreate",this.onWindowCreate);
         API.registerFunction(TickleEvent.OnResult,this.onResult);
         _loc1_ = API.getWindowPosition(true).split(",");
         ExternalInterface.call("SMALLGAMEAPI.MSay",_loc1_);
         this.wx = int(_loc1_[0]);
         this.wy = int(_loc1_[1]);
      }
      
      public function upDateTitleAndCount(param1:String) : void
      {
         API.remoteCall(Data.WND_NAME_STATUS_MOOD,"moodStatusonPlay",param1);
      }
      
      private function onWindowCreate(param1:String) : void
      {
         ExternalInterface.call("SMALLGAMEAPI.MSay","onWindowCreate",param1);
         dispatchEvent(new GameEvent(GameEvent.WINDOW_CREATE,false,{"name":param1}));
      }
      
      public function checkScreenPosition() : Object
      {
         var _loc1_:Object = null;
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         _loc1_ = new Object();
         _loc1_.up = false;
         _loc1_.down = false;
         _loc1_.left = false;
         _loc1_.right = false;
         _loc2_ = API.getWindowRect().split(",");
            ExternalInterface.call("SMALLGAMEAPI.MSay","checkScreenPosition _loc2_",_loc2_);
         _loc3_ = _loc2_[0];
         _loc4_ = _loc2_[1];
         _loc5_ = Capabilities.screenResolutionX;
         _loc6_ = Capabilities.screenResolutionY;
         if(_loc3_ < 200)
         {
            _loc1_.left = true;
         }
         if(_loc4_ < 200)
         {
            _loc1_.up = true;
         }
         if(_loc3_ > _loc5_ - 300 - 50)
         {
            _loc1_.right = true;
         }
         if(_loc4_ > _loc6_ - 300 - 65)
         {
            _loc1_.down = true;
         }
         ExternalInterface.call("SMALLGAMEAPI.MSay","checkScreenPosition _loc1_",_loc1_);
         return _loc1_;
      }
      
      public function setBubbleWindow(param1:Number, param2:Number, param3:Number, param4:String) : void
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         _loc5_ = API.getWindowPosition(true).split(",");
         this.wx = int(_loc5_[0]);
         this.wy = int(_loc5_[1]);
         _loc6_ = this.provisionalWindowArray[0];
         this.provisionalWindowArray.splice(0,1);
         API.moveTo(this.wx + param1 * scale + 70 * (scale - 1) / 2,this.wy + param2 * scale + 70 * (scale - 1) / 2,_loc6_);
         _loc7_ = API.getWindowRect(_loc6_).split(",");
         API.moveBy(-Number(_loc7_[2]) / 2 - 0,-Number(_loc7_[3]) / 2,_loc6_);
         API.showWindow(ShowCommand.SW_SHOW,_loc6_);
         API.remoteCall(_loc6_,"bubblesetScaleAndMove",param3,param4);
      }
      
      public function move(param1:Number, param2:Number, param3:String = null) : void
      {
         API.moveBy(param1,param2,param3);
      }
      
      public function onResult(param1:int, param2:int) : void
      {
         if(param2 > 0)
         {
            this.showMoneyMovie();
         }
         Main(material).initMoodValue = Math.min(Main(material).initMoodValue + param1,1000);
         this.showMoodMovie(param1 > 0,param1);
         this.upDataMoodCount(Main(material).initMoodValue,1000);
         Main(material).initMoodValue = Main(material).initMoodValue + param1;
      }
      
      public function sendAction(param1:int) : void
      {
         Tickle.sendAction(TickleActionType.BUBBLE,param1);
      }
      
      public function updateCount(param1:int) : void
      {
         API.remoteCall(Data.WND_NAME_STATUS_COUNT,"countStatusonCountUpdate",param1);
      }
      
      private function showMoneyMovie() : void
      {
         API.remoteCall(Data.WND_NAME_PROMPT_MONEY,"MoneyPrompt.onMoneyPrompt");
      }
      
      private function onWindowMove(param1:int, param2:int, param3:int, param4:int) : void
      {
         ExternalInterface.call("SMALLGAMEAPI.MSay","onWindowMove",param1);
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         param3 = param4 = 0;
         _loc5_ = param1 - this.wx;
         _loc6_ = param2 - this.wy;
         API.moveBy(_loc5_,_loc6_,Data.WND_NAME_PROMPT_MONEY);
         API.moveBy(_loc5_,_loc6_,Data.WND_NAME_PROMPT_MOOD);
         API.moveBy(_loc5_,_loc6_,Data.WND_NAME_STATUS_COUNT);
         API.moveBy(_loc5_,_loc6_,Data.WND_NAME_STATUS_MOOD);
         this.wx = param1;
         this.wy = param2;
      }
      
      public function destroyAllChildrenWindow(param1:String = null) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc2_ = API.getWindowName(WindowNameOption.CHILDREN);
         ExternalInterface.call("SMALLGAMEAPI.MSay","destroyAllChildrenWindow",_loc2_);
         _loc3_ = _loc2_.length;
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc2_[_loc4_] != param1)
            {
               API.destroyWindow(_loc2_[_loc4_]);
            }
            _loc4_++;
         }
      }
      
      public function createBubbleWindow(param1:String, param2:String) : void
      {
         ExternalInterface.call("SMALLGAMEAPI.MSay","createBubbleWindow",param1);
         var _loc3_:String = null;
         _loc3_ = Main.rank + "," + param1;
         API.createWindow(_loc3_,0,0,70,70,0,param2);
         this.provisionalWindowArray.push(_loc3_);
         API.showWindow(ShowCommand.SW_HIDE,_loc3_);
      }
      
      public function upDataMoodCount(param1:int, param2:int) : void
      {
         API.remoteCall(Data.WND_NAME_STATUS_MOOD,"MoodStatus.onMoodUpdate",param1,param2);
      }
      
      private function showMoodMovie(param1:Boolean, param2:int) : void
      {
         API.remoteCall(Data.WND_NAME_PROMPT_MOOD,"moodPromptonMoodPrompt",param1,param2);
      }
      
      private function deleteChance(param1:String) : void
      {
         dispatchEvent(new GameEvent(GameEvent.DELETE_CHANCE,false,param1));
      }
   }
}
