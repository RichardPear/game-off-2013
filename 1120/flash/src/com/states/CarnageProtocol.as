package com.states
{

	import citrus.core.CitrusGroup;
	import citrus.core.starling.StarlingCitrusEngine;
	import citrus.core.starling.StarlingState;
	import citrus.objects.NapePhysicsObject;
	import citrus.objects.platformer.nape.Hero;
	import citrus.physics.nape.Nape;
	
	import com.components.CountdownToDestruction;
	import com.components.GameButton;
	import com.components.Platform;
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

			var physics:Nape = new Nape("physics");
			physics.visible = true;
			add(physics);
			
			var hero:Hero = new Hero("hero", {x: 15, y: 16, width:20, height:20});
			add(hero);
			
			/** WALLS **/
			add(new Platform("bottom", {x:stage.stageWidth / 2, y:stage.stageHeight, width:stage.stageWidth, height: 20, _oneWay:false}));
			add(new Platform("roof", {x:stage.stageWidth / 2, y:-6, width:stage.stageWidth, height: 10, _oneWay:false}));
			add(new Platform("left_wall", {x:-6, y: stage.stageHeight,  width:10, height: stage.stageHeight * 2, _oneWay:false}));
			add(new Platform("right_wall", {x: stage.stageWidth + 5, y: stage.stageHeight,  width:10, height: stage.stageHeight * 2, _oneWay:false}));
					
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
			var _numRows:int = 7;
			var _colHeight:Number = 64;
			var _colWidth:Number = 12;
			var _rowHeight:Number = 12;
			var _gapHeight:Number = _rowHeight;
			var _gapWidth:Number = _colWidth;
			var _rowWidth:Number = (Game.STAGE_WIDTH / (_numCols));
			
			var _yPos:Number = (Game.STAGE_HEIGHT - _colHeight/2) - 11;
			var _xPos:Number = 0;
			var _platform:Platform;
			var _name:String;
			var _count:int = 0;
			
			var _gapYPos:Number = 0;
			var _rowXPosArr:Array = [];
			var _rowYPosArr:Array = [];
			
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
					_platform = new Platform(_name, {x:_xPos, y:_yPos-1, width:_width, height: _height + 1.5});
					_rowXPosArr.push(_platform.x);
					_rowYPosArr.push(_platform.y);
					add(_platform);
					
					_xPos = j * _rowWidth;
					_count++
				}
				_yPos -= (_colHeight + _rowHeight*1.5) - 1;
			}
			
			/** ADD ROWS **/
			var _rowCount:int = 0;
			for (var k:int = 1; k < _numCols; k++)
			{
				for (var l:int = 2; l < _numRows + 1; l++)
				{
					_name = "row_" + _rowCount;		
					_xPos = _rowXPosArr[_rowCount] - _rowWidth/2;
					_yPos = _rowYPosArr[_rowCount] - _colHeight/2 - _rowHeight/2 - 1.5;
					
					_platform = new Platform(_name, {x:_xPos, y:_yPos, width:_rowWidth - _colWidth - 0.5, height: _rowHeight});
					add(_platform);
					
					// GAPS
					_platform = new Platform("gap_" + _count, {x:_rowXPosArr[_rowCount] , y:_yPos, width:_colWidth, height: _rowHeight});
					add(_platform);
					
					_rowCount++
				}
			}
			
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