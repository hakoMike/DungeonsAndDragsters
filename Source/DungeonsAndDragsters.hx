
package ;

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import openfl.Assets;
import flash.Lib;
import flash.geom.Rectangle;
import flash.display.LoaderInfo;
import flash.display.Loader;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.Font;
import flash.display.Graphics;


@:font("Blackwood Castle.ttf") class DefaultFont extends Font {}

class DungeonsAndDragsters extends Sprite
{
	// key vars / consts
	static inline var UPSHIFT = 38;
	static inline var DOWNSHIFT = 40;
	static inline var ACCEL = 32;
	static inline var CLUTCH = 90;
	private var keystates:Array<Bool>;
	// game states
	static inline var TITLE_START=0; // first state at load
	static inline var TITLE_ZOOM=1; // dragster zooms by
	static inline var TITLE_FULL=2; // title ready to play
	static inline var TITLE_TRANSITION=3; // transition from title to game
	static inline var TITLE_DELAY1=10;
	static inline var TITLE_DELAY2=11;
	static inline var GAME_PRE=4; // before countdown
	static inline var GAME_COUNTDOWN=5; // countdown to start
	static inline var GAME_RACING=6; // during race
	static inline var GAME_FAIL=7; // show dragon and fire
	static inline var GAME_SUCCESS=8; // dragon falls and josh comes out
	static inline var GAME_TRANSITION=9; // going back to title
	static inline var TITLE_DELAY3=12;
	static inline var ENGINE_BLOWN=13;
	static inline var TITLE_DELAY2B=14;
	static inline var GAME_DRAGON=15;
	static inline var DRAGON_FLAME=16;
	static inline var GAME_LOSE=17;
	static inline var GAME_DRAGON_LOSE=18;
	static inline var GAME_DRAGON_WIN=19;
	static inline var GAME_JOSH=20;

	// game related
	private var lastTime:Int;
	private var gamestate:Int=TITLE_START;
	private var dragsterstate:Int = 1;
	private var tach:Float = 0.0;
	private var gear:Int = 1; 
	private var lastgear:Int = 1;
	private var speed:Float = 0.0; // leagues per fortnight ... max at about 31k
	private var distance:Float = 2000; // in cubit
	private var win_speed = 16500;

	//vars for enterframe function
	var localInt:Int=0;
	var localFloat:Float = 0.0;

	// step parameters
	private var accel:Float = 0.2; // 0.05;
	private var move_speed:Float = 0.0;
	private var pausetime:Int=0; // counter for pausing	private var pauseduration:Int = 50; // frames at 0 speed						
	private	var maxspeed:Float = 200.0; 
	private var sustain:Int = 0; // frames at max speed
	private var sustainDuration:Int=60; 

	// background images
	private var Background:Array <Bitmap>;
	private var BlurBackground:Array <Bitmap>;
	private var Footer:Bitmap;
	private var background_alpha:Float=1.0;
	private var titlefull:Bitmap;
	private var titlemin:Bitmap;
	private var pressspace:Bitmap;

	// game entities
	private var dragster:Bitmap;
	private var dragsterwreck:Bitmap;
	private var dragon:Bitmap;
	private var smoke:Array<Cloud>;
	private var josh:Bitmap;
	private var words:Bitmap;
	private var fire:Bitmap;
	private var numclouds:Int = 80;
	private var tachbar:Bitmap;
	private var wholescreen:Bitmap;
	private var scorchedknight:Bitmap;

	//sounds
	private var bgmusic:Sound;
	private var engine:Sound;
	private var dragonbreath:Sound;
	private var dragondeath:Sound;
	private var engineblow:Sound;
	private var driveby:Sound;
	private var carstart:Sound;
	private var geargrind:Sound;
	private var gearshift:Sound;
	private var soundchannel:Array<SoundChannel>;
	private var stransform:SoundTransform;
	private var enginesound:Sound;

	// text blocks
	var readysetgo:TextField;
	var gearlabel:TextField;
	var geartext:TextField;
	var speedlabel:TextField;
	var speedtext:TextField;
	var remainlabel:TextField;
	var remaintext:TextField;

	//Kongregate stuff
    static var onkon:Bool = false;
    static var kongregate;

	public function new() {
		super();
		if (onkon) {
			kongregate = new CKongregate();
		}
		initialize();
	}
	
	private function initialize() {
			keystates = [for( x in 0...255 ) false];
			Background  = new Array <Bitmap>();
			Background.insert(0,new Bitmap (Assets.getBitmapData ("assets/brickbg.png")));
			Background.insert(1,new Bitmap (Assets.getBitmapData ("assets/brickbg.png")));
			Background[0].x=0;
			Background[1].x = Background[0].width-1;

		
			BlurBackground  = new Array <Bitmap>();
			BlurBackground.insert(0,new Bitmap (Assets.getBitmapData ("assets/blurbg.png")));
			BlurBackground.insert(1,new Bitmap (Assets.getBitmapData ("assets/blurbg.png")));
			BlurBackground[0].x = 0;
			BlurBackground[1].x = BlurBackground[0].width-1;

			Footer = new Bitmap(Assets.getBitmapData("assets/footer.png"));
			Footer.y=400;
			tachbar = new Bitmap(Assets.getBitmapData("assets/tach-bar.png"));
			tachbar.x=109;
			tachbar.y=421;
			tachbar.scaleX = 0.1; //330.0; 
			tachbar.alpha = 0.5;

			addChild (BlurBackground[0]);
			addChild (BlurBackground[1]);
			addChild (Background[0]);
			addChild (Background[1]);
			

			dragster = new Bitmap(Assets.getBitmapData("assets/dragster.png"));
			dragsterwreck = new Bitmap(Assets.getBitmapData("assets/dragster-wreck.png"));
			dragon = new Bitmap(Assets.getBitmapData("assets/dragon.png"));
			josh = new Bitmap(Assets.getBitmapData("assets/josh.png"));
			words = new Bitmap(Assets.getBitmapData("assets/joshwords.png"));
			titlefull = new Bitmap(Assets.getBitmapData("assets/titlefull.png"));
			titlemin = new Bitmap(Assets.getBitmapData("assets/title-minimal.png"));
			fire = new Bitmap(Assets.getBitmapData("assets/flame.png"));
			pressspace = new Bitmap(Assets.getBitmapData("assets/press-space.png"));
			wholescreen = new Bitmap(Assets.getBitmapData("assets/reach-dragon.png"));
			scorchedknight = new Bitmap(Assets.getBitmapData("assets/scorched.png"));
			
			bgmusic = Assets.getSound("assets/JewelBeat - Midnight Sorrow.wav");
			engine = Assets.getSound("assets/car.wav");
			dragonbreath = Assets.getSound("assets/dragonflame.wav");
			dragondeath = Assets.getSound("assets/dragondeath.wav");
			engineblow = Assets.getSound("assets/engineblow.wav");
			driveby = Assets.getSound("assets/car-passby.wav");
			carstart = Assets.getSound("assets/car-start.wav");
			geargrind = Assets.getSound("assets/geargrind.wav");
			gearshift = Assets.getSound("assets/shift.wav");
			enginesound = Assets.getSound("assets/engine-scale.wav");

			
			Font.registerFont (DefaultFont);
			
			var format = new TextFormat ("Blackwood Castle", 50, 0xFFFF00);
			format.align=CENTER;
			readysetgo = new TextField ();
			
			readysetgo.defaultTextFormat = format;
			readysetgo.embedFonts = true;
			readysetgo.selectable = false;
			
			
			
			readysetgo.y = 240 - readysetgo.height;
			readysetgo.x=0;
			readysetgo.width=800;
			
			readysetgo.text = "Ready...";
			
			gearlabel = new TextField();
			format = new TextFormat ("Blackwood Castle", 20, 0xFFFF00);
			gearlabel.defaultTextFormat = format;
			gearlabel.embedFonts = true;
			gearlabel.selectable = false;
			gearlabel.x=110 - gearlabel.width;
			gearlabel.y=505 - gearlabel.height;
			//gearlabel.width=100;
			gearlabel.text="Thy Gear";

			geartext = new TextField();
			format = new TextFormat ("Blackwood Castle", 40, 0x000000);
			geartext.defaultTextFormat = format;
			geartext.embedFonts = true;
			geartext.selectable = false;
			geartext.x=140 - geartext.width;
			geartext.y=525 - geartext.height;
			//gearlabel.width=100;
			geartext.text="1";

			speedlabel = new TextField();
			format = new TextFormat ("Blackwood Castle", 20, 0xFFFF00);
			speedlabel.defaultTextFormat = format;
			speedlabel.embedFonts = true;
			speedlabel.selectable = false;
			speedlabel.width=330;
			speedlabel.x=340 - speedlabel.width;
			speedlabel.y=120 - speedlabel.height;
			speedlabel.text="Thy Speed (leagues per fortnight)";

			speedtext = new TextField();
			format = new TextFormat ("Blackwood Castle", 30, 0xFFFF00);
			speedtext.defaultTextFormat = format;
			speedtext.embedFonts = true;
			speedtext.selectable = false;
			speedtext.width=330;
			speedtext.x=360 - speedtext.width;
			speedtext.y=140 - speedtext.height;
			speedtext.text=Std.string(Std.int(move_speed));

			remainlabel = new TextField();
			format = new TextFormat ("Blackwood Castle", 20, 0xFFFF00);
			remainlabel.defaultTextFormat = format;
			remainlabel.embedFonts = true;
			remainlabel.selectable = false;
			remainlabel.width=330;
			remainlabel.x=340 - remainlabel.width;
			remainlabel.y=200 - remainlabel.height;
			remainlabel.text="Distance Remaining (cubits)";

			remaintext = new TextField();
			format = new TextFormat ("Blackwood Castle", 30, 0xFFFF00);
			remaintext.defaultTextFormat = format;
			remaintext.embedFonts = true;
			remaintext.selectable = false;
			remaintext.width=330;
			remaintext.x=360 - remaintext.width;
			remaintext.y=220 - remaintext.height;
			remaintext.text=Std.string(Std.int(distance));



			soundchannel = [];

			stransform = new flash.media.SoundTransform(0.3,0);
			soundchannel[0] = bgmusic.play( 0,50,stransform);
			

			dragster.alpha = 0.0;
			dragster.smoothing = true;
			dragster.x = 10;
			dragster.y = 411 - dragster.height;
			dragster.rotation = 2.0;
			addChild(dragster);
			
			dragsterwreck.x=10;
			dragsterwreck.y=170;
			dragster.rotation = 2.0;
			//addChild(dragsterwreck);
			scorchedknight.x=-29;
			scorchedknight.y=-5;
			//scorchedknight.rotation=2.0;

			fire.x=200;
			fire.y=80;
			//addChild(fire);

			dragon.x=337;
			dragon.y=32;
			//addChild(dragon);

			josh.x=500;
			josh.y=140;
			//addChild(josh);
			
			words.x=380;
			words.y=70;
			//addChild(words);

			

			addChildAt (readysetgo,this.numChildren);
			


			removeEventListener (Event.ENTER_FRAME, this_onEnterFrame);
			addEventListener (Event.ENTER_FRAME, this_onEnterFrame);


		
	}

	public function setkeystate(key:Int,state:Bool) {
		keystates[key]=state;
	}

	public function getkeystate(key:Int):Bool {
		return keystates[key];
	}


//********************************************************************************************************
	private function this_onEnterFrame (event:Event):Void {
		
		var delta = Lib.getTimer()- lastTime;

		if (gamestate == TITLE_START) {
			addChild(titlemin);
			localInt = Lib.getTimer();
			gamestate=TITLE_DELAY1;
		}
		if (gamestate == TITLE_DELAY1) {
			soundchannel[1] = driveby.play(0,0,stransform);
			if ((Lib.getTimer() - localInt) > 2000) {
				dragster.alpha = 1.0;
				dragster.x=-800;
				dragster.y = 480 - dragster.height;
				addChild(dragster);
				gamestate = TITLE_ZOOM;
			}
		}
			
		if (gamestate==TITLE_ZOOM) {
			dragster.x += 40;
			if (dragster.x > 1800) {
				removeChild(dragster);
				addChild(titlefull);
				addChild(titlemin);
				dragster.y = 411 - dragster.height;
				gamestate = TITLE_DELAY2;
			}
		}

		if (gamestate==TITLE_DELAY2) {
			titlemin.alpha -= 0.018;
			if (titlemin.alpha <= 0.0) {
				removeChild(titlemin);
				gamestate = TITLE_FULL;
				localFloat = -0.05;
				pressspace.alpha=1.0;
				pressspace.x = 200;
				pressspace.y = 200;
				addChild(pressspace);
			}
		}

		if (gamestate == TITLE_FULL) {
			pressspace.alpha = pressspace.alpha + localFloat;
			if ((pressspace.alpha >= 1.0)||(pressspace.alpha<=0.0)) {
				localFloat *= (-1.0);
			}
			if (getkeystate(ACCEL)==true) {
				gamestate = TITLE_TRANSITION;
				localInt = Lib.getTimer();
				soundchannel[0].stop();
				// maybe put an opaque screen here?
			}
		}

		

		if (gamestate==TITLE_TRANSITION) {
			removeChild(pressspace);
			removeChild(titlefull);
			addChild(Footer);
			addChild(gearlabel);
			addChild(geartext);
			addChild(speedlabel);
			addChild(remainlabel);
			addChild(remaintext);
			addChild(speedtext);
			addChild(tachbar);
			addChild(dragster);
			dragster.x = 10;
			dragster.y = 121;
			dragster.rotation = 2.0;	
			smoke = [];
			for (x in 0 ... numclouds) {
				smoke.insert(x,new Cloud());
				addChild(smoke[x]);
			}
			gamestate = TITLE_DELAY2B; 
			soundchannel[1] = carstart.play();
		}

		if (gamestate == TITLE_DELAY2B) {
			if ((Lib.getTimer() - localInt) > 2000) {
				readysetgo.text = "Set...";
				gamestate=TITLE_DELAY3;
			}
		}

		if (gamestate==TITLE_DELAY3) {
			if ((Lib.getTimer() - localInt) > 4000) {
				readysetgo.text = "Race!!!";
				gamestate = GAME_RACING;
				localInt = Lib.getTimer();
			}
		}
		



		if (gamestate == GAME_RACING) {
			if ((Lib.getTimer() - localInt) > 2500) {
				readysetgo.text = "";
			}
			moveBackground();
			updateDragster();
			updateSmoke();

			if (distance<0) {
				distance=0;
				gamestate=GAME_DRAGON;
				remaintext.text="0";
				accel=0;
				for (localInt in 0...2) 
					Background[localInt].alpha = 1.0;
				for (localInt in 0...numclouds) {
					smoke[localInt].hide();
				}
				if (soundchannel[3]!=null) soundchannel[3].stop();
				removeChild(dragster);
				addChild(dragsterwreck);
				addChild(dragon);				
				soundchannel[2] = engineblow.play();
				wholescreen.alpha=1.0;
				addChild(wholescreen);
				localInt = Lib.getTimer();
				
			}
		}

		if (gamestate == GAME_DRAGON) {
			if (Lib.getTimer()-localInt < 500) {
				wholescreen.alpha = 1.0 - (Lib.getTimer()-localInt)/500;
			}
			else {
				if (onkon) {
					//kongregate.SubmitScore(Std.int(move_speed*112), "Normal");
					kongregate.SubmitStat( "endspeed",Std.int(move_speed*112));
				}
				if (move_speed > win_speed/112) {
					gamestate=GAME_DRAGON_WIN;
					if (onkon) {
						kongregate.SubmitStat("completed",1);
					}
				}
				else {
					gamestate=GAME_DRAGON_LOSE;
				}
			}
		}

		if (gamestate == GAME_DRAGON_LOSE) {
			
			if (Lib.getTimer()-localInt > 4000) {
				gamestate=DRAGON_FLAME;
				addChildAt(fire,getChildIndex(dragon));
				addChildAt(scorchedknight,getChildIndex(fire));
				soundchannel[2] = dragonbreath.play();
				localInt = Lib.getTimer();
				addChild(readysetgo);
			}
		}

		if (gamestate == DRAGON_FLAME) {
			if (Lib.getTimer()-localInt > 2000) {
				removeChild(fire);
				readysetgo.alpha=0.0;
				readysetgo.text="Thou Hast Lost";
				gamestate=GAME_LOSE;
				localFloat=0.0;
			}
		}

		if (gamestate == GAME_LOSE) {
			if (localFloat<1.0) {
				localFloat += 0.02;
				readysetgo.alpha=localFloat;
			}
			updateSmoke();

		}

		if (gamestate == GAME_DRAGON_WIN) {
			if (dragon.scaleX > 0.0) {
				dragon.scaleX -= 0.02;
				dragon.scaleY -= 0.02;
				dragon.rotation += 2.0;
				dragon.x += 40.0;
				dragon.y -= 4.0;
			}
			else {
				localInt=0;
				localFloat=1.0;
				gamestate=GAME_JOSH;
				josh.x = 900;
				addChild(josh);
			}

		}

		if (gamestate==GAME_JOSH) {
			if (josh.x > 500) {
				josh.x -=2;
				josh.rotation += localFloat;
				if (Math.abs(josh.rotation) > 5.0) {
					josh.rotation=5 * (localFloat / Math.abs(localFloat));
					localFloat *= -1;
				}
			}
			else {
				josh.rotation=0.0;
				addChild(words);
			}
		}
		
		if (gamestate == ENGINE_BLOWN) {
			if (readysetgo.text != "ENGINE BLOWN!") {
				localInt = Lib.getTimer();
				readysetgo.text = "ENGINE BLOWN!";
			}
			//accel = -0.8;
			moveBackground();
			updateDragster();
			updateSmoke();
		}

		lastTime = Lib.getTimer();

		
	}
//**********************************************************************************************************
	private function moveBackground() {
		var i:Int;
		move_speed = CalcNewMoveSpeed();
		
		for (i in 0...2) {
			Background[i].x-=Math.floor(move_speed);
			if ((Background[i].x + Background[i].width) <= 0) {
				Background[i].x=Background[i].x+Background[i].width*2-2;				
			}	
		}
		
		for (i in 0...2) {
			BlurBackground[i].x-=Math.floor(move_speed);
			if ((BlurBackground[i].x + BlurBackground[i].width) <= 0) {
				BlurBackground[i].x=BlurBackground[i].x+BlurBackground[i].width*2-2;				
			}	
		}

	}

	private function updateSmoke() {
		for (x in 0...numclouds) {
			smoke[x].update();
		}
		if (!keystates[ACCEL] && gamestate!=ENGINE_BLOWN && gamestate!=GAME_LOSE) return;
		if (Math.random()<.4) {
			for (x in 0...numclouds) {
				if (smoke[x].active==false) {
					if (gamestate == ENGINE_BLOWN) {
						smoke[x].goBlack();
						smoke[x].yvel = -5 - (Math.random()*5+1);
						smoke[x].xvel = -1 + (Math.random()*2+1) - (move_speed/5);
						smoke[x].show(140,270);
						break;
					}
					else if (gamestate==GAME_LOSE) {
						smoke[x].goBlack();
						smoke[x].yvel = -5 - (Math.random()*5+1);
						smoke[x].xvel = -2 + (Math.random()*2+1);
						smoke[x].show(235,270);
						break;
					}
					else {
						smoke[x].xvel = -3 - (move_speed/5);
						smoke[x].yvel = (Math.random()*50+1-25)*0.05;
						smoke[x].show(80,370);
						break;
					}
				}
			}
			
			
		}
		

	}

	private function CalcNewMoveSpeed():Float {	
			var i:Int;		
			if (gamestate==ENGINE_BLOWN || keystates[CLUTCH]) {
				move_speed -= 0.3;
			} else {
				if (keystates[ACCEL]) {
					move_speed += gear*accel;
				} else {
					move_speed -= 0.1;
				}
			}
			if (move_speed >= maxspeed) {
				return maxspeed-1;
			}
			
			if (move_speed<0) {
				move_speed=0;
			}
			background_alpha = 1.0-(move_speed/maxspeed)*2;
			if (background_alpha < 0.0) {
				background_alpha = 0.0;
			}
			for (i in 0...2) {
				Background[i].alpha = background_alpha;

			}
			speedtext.text = Std.string(Std.int(move_speed*112.00));
			distance = distance - move_speed/10.0;
			if (gamestate != ENGINE_BLOWN) {
				remaintext.text = Std.string(Std.int(distance));
			} else {
				remaintext.text = "";
			}
			return move_speed;
	}

	public function updateDragster() {

		if ((keystates[UPSHIFT]||keystates[DOWNSHIFT]) && !keystates[CLUTCH]) {
			soundchannel[2] = geargrind.play();
		}

		if (keystates[CLUTCH]) {
			geartext.text="N";
			if (keystates[UPSHIFT]) {
				lastgear=gear+1;
				if (lastgear>4) lastgear=4;
			}
			if (keystates[DOWNSHIFT]) {
				lastgear = gear-1;
				if (lastgear<1) lastgear=1;
			}
		} else {
			gear=lastgear;
			geartext.text=Std.string(gear);
		}

		if (keystates[ACCEL] && keystates[CLUTCH] && (gamestate!=ENGINE_BLOWN)) {
			tach = tach + 10;
		} else if (keystates[ACCEL] && (gamestate!=ENGINE_BLOWN)) {
			tach = tach + accel* 2*(5-gear);
			if (dragsterstate==1 ) {
				//soundchannel[3] = enginesound.play(11517/(tach/330));
				soundchannel[3] = enginesound.play(5000);
				dragster.x = -22;
				dragster.y = 148;
				dragster.rotation = -10.0;
				dragsterstate=0;
			}
		} else	{
			tach = tach - accel*40.0;
			if (dragsterstate==0) {
				if (soundchannel[3]!=null) soundchannel[3].stop();
				dragster.x = 10;
				dragster.y = 121;
				dragster.rotation = 2.0;
				dragsterstate=1;
			}
		}

		

		if (tach>330.0) {
			tach=329.0;
			if (gamestate != ENGINE_BLOWN) {
				if (soundchannel[3]!=null) soundchannel[3].stop();
				soundchannel[2] = engineblow.play();
				gamestate=ENGINE_BLOWN;
			}
			
			
			
		}

		if (gamestate == ENGINE_BLOWN) {
			tach -= 15;
		}

		if (tach<0.1)  {
			tach = 0.1;
		}
		tachbar.scaleX = tach; // 0.1; //330.0; 


	}

	

}

class Cloud extends Sprite {
		private var myimage:Bitmap;
		public var xvel:Float=0.0;
		public var yvel:Float=0.0;
		public var active:Bool;
		private var black:Bool;
		public function new() {
			super();
			myimage = new Bitmap(Assets.getBitmapData("assets/smoke.png"));
			myimage.x = -100;
			myimage.y = -100;
			black=false;
			addChild(myimage);
		}
		public function update() {
			if (active) {
				myimage.x += xvel;
				myimage.y += yvel;
				if ((myimage.x < -50)||(myimage.y < -50)) {
					active = false;
				}
				addChild(myimage);
			}
		}
		public function show(x:Int=0,y:Int=0) {
			myimage.alpha=0.5;
			myimage.x = x;
			myimage.y = y;
			active = true;
			addChild(myimage);
		}
		public function hide() {
			myimage.alpha=0.0;
			active = false;
		}

		public function goBlack() {
			if (!black) {
				removeChild(myimage);
				myimage = new Bitmap(Assets.getBitmapData("assets/smokeblack.png"));
				black = true;
				addChild(myimage);
			}
		}
	} 


class CKongregate
{
        var kongregate: Dynamic;

        public function new()
        {
                kongregate = null;
                var parameters = flash.Lib.current.loaderInfo.parameters;
                var url: String;
                url = parameters.api_path;
                if(url == null)
                url = "http://www.kongregate.com/flash/API_AS3_Local.swf";
                var request = new flash.net.URLRequest(url);             
                var loader = new flash.display.Loader();
                loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, OnLoadComplete);
                loader.load(request);
                flash.Lib.current.addChild(loader);
        }

        function OnLoadComplete(e: flash.events.Event)
        {
                try
                {
                        kongregate = e.target.content;
                        kongregate.services.connect();
                }
                catch(msg: Dynamic)
                {
                        kongregate = null;
                }
        }

        public function SubmitScore(score: Float, mode: String)
        {
                if(kongregate != null)
                {
                        kongregate.scores.submit(score, mode);
                }
        }

        public function SubmitStat(name: String, stat: Float)
        {
                if(kongregate != null)
                {
                        kongregate.stats.submit(name, stat);
                }
        }

}
