package com.states
{
	import citrus.core.CitrusGroup;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.objects.Box2DPhysicsObject;
	import citrus.objects.platformer.box2d.Hero;
	import citrus.objects.platformer.box2d.Platform;
	import citrus.objects.platformer.box2d.Sensor;
	import citrus.physics.box2d.Box2D;
	
	import com.components.CountdownToDestruction;
	import com.components.GameButton;
	import com.constants.Game;
	import com.constants.Textures;
	import com.events.CreateEvent;
	
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class CarnageProtocol extends StarlingState
	{
		private var _bg:Image;
		private var _restartButton:Button;
		private var _splashButton:Button;
		
		private var _countDown:CountdownToDestruction;
		private var _unstablePlatform:CitrusGroup;
		
		public function CarnageProtocol() {
			
			trace("CARNAGE PROTOCOL")
			
			super();
		}

		override public function initialize():void {
			
			super.initialize();
			
			if (!_bg)
				_bg = new Image(Texture.fromBitmap(new Textures.LEVEL_1_BG));
			
			addChild(_bg);
			
			var box2d:Box2D = new Box2D("box2d");
			box2d.visible = true;
			add(box2d);
			
			var hero:Hero = new Hero("hero", {x:210, y:100, width:20, height:20});
			hero.acceleration = 100;
			hero.jumpAcceleration = 5;
			add(hero);
			
			/** WALLS **/
			add(new Platform("bottom", {x:stage.stageWidth / 2, y:stage.stageHeight, width:stage.stageWidth, height: 20}));
			add(new Platform("roof", {x:stage.stageWidth / 2, y:0, width:stage.stageWidth, height: 10}));
			add(new Platform("left_wall", {x:0, y: stage.stageHeight,  width:10, height: stage.stageHeight * 2}));
			add(new Platform("right_wall", {x: stage.stageWidth, y: stage.stageHeight,  width:10, height: stage.stageHeight * 2}));
					
			/** UI **/
			_restartButton = GameButton.imageButton(Textures.BUTTON_RESTART, Game.RESTART, 46, 46, 845, 15); 
			_splashButton = GameButton.imageButton(Textures.BUTTON_EXIT, Game.SPLASH, 46, 46, 900, 15); 
			_restartButton.addEventListener(TouchEvent.TOUCH, handleUI);
			_splashButton.addEventListener(TouchEvent.TOUCH, handleUI);
			addChild(_restartButton);
			addChild(_splashButton);
			
			this.visible = true;
			
			_unstablePlatform = createUnstablePlatform();
			addEntity(_unstablePlatform);
			
			_countDown = new CountdownToDestruction();
			addChild(_countDown);
		}
		
		public function createUnstablePlatform(name:String="UnstablePlatform"):CitrusGroup
		{
			var _platformGroup:CitrusGroup = new CitrusGroup(name);

			var _numCols:int = 7;
			var _numRows:int = _numCols; // yep.
			var _colHeight:Number = 70;
			var _colWidth:Number = 10;
			var _rowHeight:Number = 10;
			var _rowWidth:Number = (Game.STAGE_WIDTH) / _numCols;
			
			var _yPos:Number = (Game.STAGE_HEIGHT - _colHeight/2) - 12;
			var _xPos:Number = 0;
			var _platform:Platform;
			var _name:String;
			var _count:int = 0;
			
			var _width:Number = 0;
			var _height:Number = 0;
			
			/** ADD COLUMNS **/
			for (var i:int = 1; i < _numCols; i++)
			{
				_xPos = _rowWidth;
				for (var j:int = 2; j < _numRows + 1; j++)
				{
					_name = "col_" + _count;
					_height = _colHeight;
					_width = _colWidth;
					
					// COLUMNS
					_platform = new Platform(_name, {x:_xPos, y:_yPos, width:_width, height: _height, oneWay:true});
					add(_platform);
					
					// GAPS
					_platform = new Platform("gap_" + _count, {x:_xPos, y: (_yPos - (_colHeight/2 + _rowHeight/2 - 10) - 12), width:_width, height: _rowHeight + 1, oneWay:true});
					add(_platform);
					
					_xPos = j * _rowWidth;
					_count++
				}
				_yPos -= (_colHeight + _rowHeight*1.5);
			}
			
			/** ADD ROWS **/
			/*_yPos = (Game.STAGE_HEIGHT) - (_colHeight + _rowHeight*1.7);
			for (var k:int = 1; k < _numCols; k++)
			{
				_xPos = _rowWidth;
				for (var l:int = 2; l < _numRows + 1; l++)
				{
					_name = "row_" + _count;
					_height = _rowHeight;
					_width = _rowWidth;
					
					_platform = new Platform(_name, {x:_xPos, y:_yPos, width:_width, height: _height, oneWay:true});
					add(_platform);
					
					_xPos = l * _rowWidth;
					_count++
				}
				_yPos -= _colHeight + _rowHeight;
			}*/
			
			return _platformGroup;
		}
		
		public function handleUI(e:TouchEvent):void
		{
			var touch:Touch = e.getTouch(stage);
			if(touch)
			{
				var button:Button = e.currentTarget as Button;
				if (button)
				{					
					 if(touch.phase == TouchPhase.ENDED)
					{
						 clear();
						 if(button.name == Game.RESTART)
						 	dispatchEvent(new CreateEvent(CreateEvent.CREATE, {type: Game.RESTART}, true));
						 else if (button.name == Game.SPLASH)
							 dispatchEvent(new CreateEvent(CreateEvent.CREATE, {type: Game.SPLASH}, true));
					}	
					
				}
				
			}	
		}
		
		private function clear():void
		{
			if (_bg)
				_bg = null;
			
			if (_countDown)
			{
				_countDown.clear();
				_countDown = null;
			}
			
			if (_restartButton)
			{
				_restartButton.removeEventListener(TouchEvent.TOUCH, handleUI);
				_restartButton = null;
			}
			
			if (_splashButton)
			{
				_splashButton.removeEventListener(TouchEvent.TOUCH, handleUI);
				_splashButton = null;
			}
			
			this.removeEventListener(TouchEvent.TOUCH, handleUI);
			this.removeChildren();
			this.dispose();
		}
		
	}
}