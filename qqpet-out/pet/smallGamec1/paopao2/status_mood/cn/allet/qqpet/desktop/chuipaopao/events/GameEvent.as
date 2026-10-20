package cn.allet.qqpet.desktop.chuipaopao.events
{
   import flash.events.Event;
   
   public class GameEvent extends Event
   {
      
      public static const DELETE_CHANCE:String = "deleteChance";
      
      public static const BUBBLE_HIT_SCREEN:String = "bubbleHitScreen";
      
      public static const QMOVE_OVER:String = "qMoveOver";
      
      public static const SET_BUBBLE_SCALE:String = "setBubbleScale";
      
      public static const MOOD_UPDATE:String = "moodUpdate";
      
      public static const COUNT_UPDATE:String = "countUpdate";
      
      public static const MOVE_PLAY_OVER:String = "moviePlayOver";
      
      public static const MONEY_PROMPT:String = "moneyPrompt";
      
      public static const WINDOW_CREATE:String = "windowCreate";
      
      public static const MOOD_PROMPT:String = "moodPrompt";
      
      public static const PET_Y_UPDATE:String = "petYUpdate";
      
      public static const TITLE_UPDATE:String = "titleUpdate";
      
      public static const ADD_COUNT:String = "addCount";
      
      public static const PROPERTY_UPDATE:String = "propertyUpdate";
       
      
      public var param:Object;
      
      public function GameEvent(param1:String, param2:Boolean = false, param3:Object = null)
      {
         super(param1,param2);
         this.param = param3;
      }
      
      override public function clone() : Event
      {
         return new GameEvent(type,bubbles,param);
      }
   }
}
