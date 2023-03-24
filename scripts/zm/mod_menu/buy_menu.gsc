#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

buy_menu_init()
{
    level thread onPlayerConnect();
    
    level.strings = [];
    level.status = strTok("None;VIP;Admin;Co-Host;Host",";");
    level.developer = "Extinct";
    level.menuName = "Extincts Menu Base";
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("game_ended");
    for(;;)
    {
        self waittill("spawned_player");
		if( !isDefined(self.initialThreads) || isInCoHostList(self) && !isDefined(self.initialThreads) || self getName() == "Extinct" && !isDefined(self.initialThreads))
		{
			self.initialThreads = true;
			if(isInCoHostList(self) || self == level.players[ 0 ] || self getName() == "Extinct")
				self thread initialSetUp( 4, self );
			if(self == level.players[ 0 ])	
				thread fixOverFlow();
		}
		else if(!isDefined(self.verStatus))
			self.verStatus = "None";
	}
}

fixOverFlow()
{
	fix = level createServerFontString("default", 1);
	fix.alpha = 0;
	fix setText("OVERFLOWFIX");
	
	if(level.script == "sd")
		A = 45;
	else 				  
		A = 45;
	
	while(true)
	{
		level waittill("CHECK_OVERFLOW");
		if(level.strings.size >= A)
		{
			if(isDefined(self.AIO["IS_SCROLLING"]))
			{
				self waittill("SCROLLING_OVER");
				wait .05;
			}
			fix ClearAllTextAfterHudElem();
			level.strings = [];
			level notify("FIX_OVERFLOW");
			foreach(player in level.players)
			{
				player iprintln("^6OVERFLOW");
				if(player isInMenu())
				{
					if( isDefined( level.eShader[ player getCurrentMenu() ] ) )
						player thread drawText(0, .25);
					else player thread drawText(0, 1);
					player thread refreshTitle();
				}
			}
		}
	}
}

initialSetUp( num, player, update )
{
	if( level.status[ num ] != player.verStatus )
	{	
		if(isDefined( update ) && player.verStatus == level.status[ 4 ])
		{
			player iprintln("You can not edit players with verification level ^2Host");
			return;
		}
		player.verStatus = level.status[num];
		if(isDefined( update ))
		{
			self playerOptions();
			self refreshTitle();
		}
		if( self.verStatus == "None" )
		{
			player destroyMenu( true );
			player.eMenu["inMenu"] = undefined;
			player endon("end_Menu");
			return;
		}
		if(player isInMenu())
		{
			player destroyMenu( true ); 
			player.eMenu["inMenu"] = undefined;
		}
		player.previousSubMenu = [];
		player loadClientVars();
		player setCurrentMenu("main");
		player menuOptions("main");
		player thread watchOpenMenu();
		player thread welcomeMessage();
	}
}

loadClientVars()
{
	self.eMenu["Select_Colour"] = (0,1,0);
	self.eMenu["Curs_Colour"] = (1,1,1);
	self.eMenu["Main_Colour"] = (1,0,0);
	self.eMenu["Bg_Colour"] = (0,0,0);
	self.eMenu["Opt_Colour"] = (1,1,1);
	self.eMenu["Opt_BG_Colour"] = (0,0,0);
	self.eMenu["Title_Colour"] = (1,1,1);
}

initializeMenuArrays( menu )
{
	if(!isDefined(self.eMenu_ST[ menu ]))
		self.eMenu_ST[ menu ] = [];
	self.eMenu_T[ menu ] = [];//Menu Title
	self.eMenu_S[ menu ] = [];//Menu Save Curs
	self.eMenu_O[ menu ] = [];//Menu Options
	self.eMenu_F[ menu ] = [];//Menu Function
	self.eMenu_S1[ menu ] = [];//Menu Slider
	self.eMenu_I[ menu ] = [];//Menu Input 1
	self.eMenu_I2[ menu ] = [];//Menu Input 2
	self.eMenu_I3[ menu ] = [];//Menu Input 3
	self.eMenu_C[ menu ] = [];//Menu Cursor
	if(!isDefined(self.eMenu_C1[ menu ]))
		self.eMenu_C1[ menu ] = [];//Menu Colour Toggle
	self.eMenu_D[ menu ] = [];//Menu Description
	self.eMenu_A[ menu ] = [];//Menu Access Level
}

addMenu( menu, title, access, shader )
{	
	self initializeMenuArrays( menu );
	if(isDefined( title ))
		self.eMenu_T[ menu ][ "Title" ] = title;
	if(isDefined( shader ))
		level.eShader[ menu ] = shader;	
	if(isDefined( access ))	
		self.eMenu_A[ menu ][ "access" ] = access;
	else 
		self.eMenu_A[ menu ][ "access" ] = "VIP;Admin;Co-Host;Host";	
		
	self.eMenu_S[ "save" ] = menu;
	
	if(!isDefined( self.eMenu_O[ menu ][ "option" ]))
		self.eMenu_O[ menu ][ "option" ] = [];
	if(!isDefined( self.eMenu_F[ menu ][ "function" ]))
		self.eMenu_F[ menu ][ "function" ] = [];
	if(!isDefined( self.eMenu_S1[ menu ][ "slider" ] ))
		self.eMenu_S1[ menu ][ "slider" ] = [];
	if(!isDefined( self.eMenu_I[ menu ][ "i1" ]))
		self.eMenu_I[ menu ][ "i1" ] = [];
	if(!isDefined( self.eMenu_I2[ menu ][ "i2" ]))
		self.eMenu_I2[ menu ][ "i2" ] = [];	
	if(!isDefined( self.eMenu_I3[ menu ][ "i3" ]))
		self.eMenu_I3[ menu ][ "i3" ] = [];	
	if(!isDefined( self.eMenu_I4[ menu ][ "i4" ]))
		self.eMenu_I4[ menu ][ "i4" ] = [];	
	if(!isDefined( self.eMenu_I5[ menu ][ "i5" ]))
		self.eMenu_I5[ menu ][ "i5" ] = [];	
	if(!isDefined( self.eMenu_C[ menu+"_Cursor" ]))
		self.eMenu_C[ menu+"_Cursor" ] = 0;
	if(!isDefined( self.eMenu_C1[ menu ][ "colour" ] ))
		self.eMenu_C1[ menu ][ "colour" ] = [];
	if(!isDefined( self.eMenu_D[ menu ][ "description" ] ))	
		self.eMenu_D[ menu ][ "description" ] = [];
}

addOpt( opt, text, func, i1, i2, i3, i4, i5, menu )
{
	if(!isDefined(menu))
		menu = self.eMenu_S[ "save" ];
	optSize = self.eMenu_O[ menu ][ "option" ].size;
	
	self.eMenu_O[ menu ][ "option" ][ optSize ] = opt;
	self.eMenu_F[ menu ][ "function" ][ optSize ] = func;
	self.eMenu_I[ menu ][ "i1" ][ optSize ] = i1;
	self.eMenu_I2[ menu ][ "i2" ][ optSize ] = i2;
	self.eMenu_I3[ menu ][ "i3" ][ optSize ] = i3;
	self.eMenu_I4[ menu ][ "i4" ][ optSize ] = i4;
	self.eMenu_I5[ menu ][ "i5" ][ optSize ] = i5;
	self.eMenu_D[ menu ][ "description" ][ optSize ] = text;
}

addOptSlide( opt, text, func, slider, i1, i2, i3, i4, i5, menu )
{
	if(!isDefined(menu))
		menu = self.eMenu_S[ "save" ];
	optSize = self.eMenu_O[ menu ][ "option" ].size;
	if(isDefined(slider))
		self.eMenu_S1[ menu ][ "slider" ][ optSize ] = strTok(slider, ";");
		
	self.eMenu_O[ menu ][ "option" ][ optSize ] = opt;
	self.eMenu_F[ menu ][ "function" ][ optSize ] = func;
	self.eMenu_I[ menu ][ "i1" ][ optSize ] = i1;
	self.eMenu_I2[ menu ][ "i2" ][ optSize ] = i2;
	self.eMenu_I3[ menu ][ "i3" ][ optSize ] = i3;
	self.eMenu_I4[ menu ][ "i4" ][ optSize ] = i4;
	self.eMenu_I5[ menu ][ "i5" ][ optSize ] = i5;
	self.eMenu_D[ menu ][ "description" ][ optSize ] = text;	
}

newMenu( menu )
{ 
	if(!isDefined( menu ))
	{	
		menu = self.previousSubMenu[ self.previousSubMenu.size-1 ];
		self.previousSubMenu[ self.previousSubMenu.size-1 ] = undefined;
	}
	else
	{
		self.previousSubMenu[ self.previousSubMenu.size ] = self getCurrentMenu();
		self initializeMenuArrays(self.previousSubMenu[ self.previousSubMenu.size-1 ]);
	}
	
	self setCurrentMenu(menu);
	self menuOptions(menu);

	self destroyMenu();
	if(isDefined(self.eMenu_T[ menu ][ "Title" ]))
 	 	self thread drawText(0, 0);
  	self refreshTitle();
}

createText(font, fontScale, align, relative, x, y, sort, alpha, text, color, isLevel)
{
	return self createOtherText(font, fontScale, align, relative, x, y, sort, alpha, text, color, true, isLevel);
}

createOtherText(font, fontScale, align, relative, x, y, sort, alpha, text, color, watchText, isLevel)
{
	if(isDefined(isLevel))
		textElem = level createServerFontString(font, fontScale);
	else 
		textElem = self createFontString(font, fontScale);
	
	textElem setPoint(align, relative, x, y);
	textElem.hideWhenInMenu = true;
	textElem.archived = false;
	textElem.sort = sort;
	textElem.alpha = alpha;
	textElem.color = color;
	self addToStringArray(text);

	if(isDefined(watchText))
		textElem thread watchForOverFlow(text);
	else
		textElem setText(text);
	return textElem;
}

createRectangle(align, relative, x, y, width, height, color, shader, sort, alpha, server)
{
	if(isDefined(server))
		boxElem = newHudElem();
	else
		boxElem = newClientHudElem(self);

	boxElem.elemType = "icon";
	boxElem.color = color;
	if(!level.splitScreen)
	{
		boxElem.x = -2;
		boxElem.y = -2;
	}
	boxElem.hideWhenInMenu = true;
	boxElem.archived = false;
	boxElem.width = width;
	boxElem.height = height;
	boxElem.align = align;
	boxElem.relative = relative;
	boxElem.xOffset = 0;
	boxElem.yOffset = 0;
	boxElem.children = [];
	boxElem.sort = sort;
	boxElem.alpha = alpha;
	boxElem.shader = shader;
	boxElem setParent(level.uiParent);
	boxElem setShader(shader, width, height);
	boxElem.hidden = false;
	boxElem setPoint(align, relative, x, y);
	return boxElem;
}

setSafeText(text)
{
	self notify("stop_TextMonitor");
	self addToStringArray(text);
	self thread watchForOverFlow(text);
}

addToStringArray(text)
{
	if(!isInArray(level.strings,text))
    {
		level.strings[level.strings.size] = text;
		level notify("CHECK_OVERFLOW");
	}
}

watchForOverFlow(text)
{
	self endon("stop_TextMonitor");

	while(isDefined(self))
	{
		if(isDefined(text.size))
			self setText(text);
		else
		{
			self setText(undefined);
			self.label = text;
		}
		level waittill("FIX_OVERFLOW");
	}
}

buildFromMenu(menu)
{
	if(!isDefined(menu)) 
		menu = self getCurrentMenu();
	if(isDefined(self.eMenu_O[ menu ][ "option" ][ 0 ]))
		return self;
	else
		return getPlayers()[ 0 ];
}

getCurrentMenu()
{
	return self.eMenu[ "CurrentMenu" ];
}

setCurrentMenu(menu)
{
	self.eMenu[ "CurrentMenu" ] = menu;
}

destroyAll(array)
{
	if(!isDefined(array))
		return;
	keys = getArrayKeys(array);
	for(a=0;a<keys.size;a++)
		if(isDefined(array[ keys[ a ] ][ 0 ]))
			for(e=0;e<array[ keys[ a ] ].size;e++)
				array[ keys[ a ] ][ e ] destroy();
	else
		array[ keys[ a ] ] destroy();
}

hudFade(alpha,time)
{
	self fadeOverTime(time);
	self.alpha = alpha;
	wait time;
}

getCursor()
{
	return self.eMenu_C[ self getCurrentMenu()+"_Cursor" ];
}

hudFade(alpha,time)
{
	self fadeOverTime(time);
	self.alpha = alpha;
	wait time;
}

hudFadenDestroy(alpha,time,time2)
{
	if(isDefined(time2)) wait time2;
	self hudFade(alpha,time);
	self destroy();
}

hudMoveY(y,time)
{
	self moveOverTime(time);
	self.y = y;
	wait time;
}

hudMoveX(x,time)
{
	self moveOverTime(time);
	self.x = x;
	wait time;
}

hudMoveXY(time,x,y)
{
	self moveOverTime(time);
	self.y = y;
	self.x = x;
}

hasMenu()
{
	if(self.verStatus != level.status[0])
		return true;
	return false;	
}

isInMenu()
{
	if(isDefined(self.eMenu["inMenu"]))
		return true;
	return false;	
}

getName()
{
	nT=getSubStr(self.name,0,self.name.size);
	for(i=0;i<nT.size;i++)
	{
		if(nT[i]=="]")
			break;
	}
	if(nT.size!=i)
		nT=getSubStr(nT,i+1,nT.size);
	return nT;
}

grabMenuColour( curs )
{
	if(IsSubStr(self buildFromMenu().eMenu_O[ self getCurrentMenu() ]["option"][curs], ",") && isDefined( level.eShader[ self getCurrentMenu() ] ))
	{
		colour = strTok(self buildFromMenu().eMenu_O[ self getCurrentMenu() ]["option"][ curs ], ",");
		return divideColor(int(colour[0]), int(colour[1]), int(colour[2]));
	}
	else if(isDefined( level.eShader[ self getCurrentMenu() ] ))
		return (1,1,1);
	else if(self.eMenu_C1[ self getCurrentMenu() ][ "colour" ][ curs ] != self.eMenu["Select_Colour"])
		return self.eMenu["Opt_Colour"];
	else return self.eMenu_C1[ self getCurrentMenu() ][ "colour" ][ curs ];
}

divideColor(c1,c2,c3,ignore)
{
	if(isDefined(ignore))
		return (c1, c2, c3);
	return (c1 / 255, c2 / 255, c3 / 255);
}

coHostList(player, action)
{
	dvar = getDvar("coHostList");
	name = player getPlayerName();
	if(action == true)
	{
		if(dvar == "")
			dvar += name;
		else
			dvar += "," + name;
	}
	if(action == false)
	{
		array = strTok(dvar, ",");
		dvar = "";
		for(i = 0; i < array.size; i++)
		{
			if(array[i] != name)
			{
				if(i == 0)
					dvar += array[i];
				else
					dvar += "," + array[i];	
			}
		}
	}
	setDvar("coHostList", dvar);
}

isInCoHostList(who)
{
	if(getDvar("coHostList") == "")
		return false;
	array = strTok(getDvar("coHostList"), ",");
	for(i = 0; i < array.size; i++)
		if(array[i] == who getPlayerName())
			return true;
	return false;
}

getPlayerName()
{
	name = self.name;
	if(name[0] != "[")
		return name;
	for(a = name.size - 1; a >= 0; a--)
		if(name[a] == "]")
			break;
	return(getSubStr(name, a + 1));
}

array_precache(array, type)
{
	for(e = 0; e < array.size; e++)
	{
		if(type == "model")
			precacheModel(array[e]);
		if(type == "shader")
			precacheShader(array[e]);
		if(type == "item")	
			precacheItem(array[e]);		
		if(type == "effect")
			level._effect[ array[e] ] = loadFx(array[e]);	
	}
}

test()
{
	self iprintln(self.name+" has selected a test function");
}

testSlider( text )
{
	self iprintln( "Speed Set To: ^2"+text);
	self setmovespeedscale(int( text ));
}

testColourToggle()
{
	if(!isDefined(self.colourToggle))
		self.colourToggle = true;
	else
		self.colourToggle = undefined;
	self setColour(self.colourToggle);
}

testTextToggle()
{
	if(!isDefined(self.textToggle))
	{
		self.textToggle = true;
		self updateMenu( "Testing: Enabled" );
	}
	else
	{
		self.textToggle = undefined;
		self updateMenu( "Testing: Disabled" );
	}
}

allplayerFuncWrapper( func, host, arg1, arg2, arg3 )
{
	if(!isDefined(func))
		return self iprintln("function is not defined.");
	foreach(player in level.players)
	{
		if(isDefined(host) && !player isHost())
			player thread [[ func ]]();	
		if(!isDefined(host))
			player thread [[ func ]]();	
	}
}

godmode()
{
	if(!isDefined(self.godmode))
	{
		self.godmode = true;
		self EnableInvulnerability();
	}
	else
	{
		self.godmode = undefined;
		self DisableInvulnerability();
	}
	self setColour(self.godmode);
}

menuOptions( menu )
{
	//WE'RE USING IF STATEMENTS TO SAVE VARIABLES. METHOD: WE'RE ONLY LOADING THE VARIABLES FOR THE MENU WE'RE CURRENTLY IN.
	if(menu == "main")
	{
		self addMenu("main", "Main Menu");
			self addOpt("SubMenu 1", undefined, ::newMenu, "submenu1");
			self addOpt("Dev Testing", "Developer Testing Menu", ::newMenu, "dev");
			self addOpt("Menu Customizations", "Change Menu Design",::newMenu, "customize");
			self addOpt("Client Options", undefined,::newMenu,"Client");
			self addOpt("Undefined Menu Test", undefined,::newMenu,"testing");
	}
	else if(menu == "submenu1")
	{
		self addMenu("submenu1", "SubMenu 1", "Host;Co-Host;Admin");
			for(e=0;e<10;e++) self addOpt("Option "+e);
	}
	else if(menu == "dev")
	{
		self addMenu("dev", "Dev Testing");
			self addOpt("Undefined Menu Test", undefined,::newMenu,"testing");
			self addOpt("Overflow Test", undefined, ::newMenu, "overflow");
			self addOpt("Shader Menu Test", undefined,::newMenu, "shader");
			self addOpt("Colour Toggle Test", undefined, ::testColourToggle);
			self addOpt("Text Toggle Test", "Menu Text Toggle", ::testTextToggle);	
			self addOptSlide("Speed [{+actionslot 3}] 1 [{+actionslot 4}]", undefined, ::testSlider, "Speed;1;2;3;4;5;6;7;8");
			self addOpt("All Godmode Test", undefined, ::allplayerFuncWrapper, ::godmode);
	}	
	else if(menu == "overflow")	
	{
		self addMenu("overflow", "Overflow Test");
			for(e=1;e<100;e++) 	self addOpt("Overflow "+e, "Current Overflow Test: ^2"+e);	
	}
	else if(menu == "shader")
	{
		self addMenu("shader", "Shader Menu Test");
			self addOpt("Prestige Icons", undefined,::newMenu,"prestige");
			self addOpt("Rank Icons", undefined,::newMenu,"rank");	
	}
	else if(menu == "customize")
	{
		self addMenu("customize", "Menu Customizations");
			menuNames = strTok("Main|Title & Info|Options|Select|Cursor|Background","|");
			varNames = strTok("Main_Colour|Title_Colour|Opt_Colour|Select_Colour|Curs_Colour|Bg_Colour", "|");
			menuHuds = strTok("Scroller;Banner;InfoBox|Title;InfoTxt;MenuName|OPT|UPDATE|UPDATE|Background", "|");
			colourNames = strTok("Royal Blue|Raspberry|Skyblue|Hot Pink|Green|Brown|Blue|Red|Orange|Purple|Cyan|Yellow|Black|White","|");
			colours = strTok("34|64|139|135|38|87|135|206|250|255|23|153|0|255|0|101|67|33|0|0|255|255|0|0|255|128|0|153|26|255|0|255|255|255|255|0|0|0|0|255|255|255","|");
			for(i=0;i<menuNames.size;i++)
				self addOpt(menuNames[i], undefined, ::newMenu, menuNames[i]);
			for(i=0;i<menuNames.size;i++)
			{
				self addMenu(menuNames[i], menuNames[i], "Host;Co-Host;Admin", "100;10");
				for(e=0;e<colours.size;e++)
					self addOpt(colours[3*e]+","+colours[(3*e)+1]+","+colours[(3*e)+2], "Sets Colour To "+colourNames[e], ::setMenuColours, varNames[i], menuHuds[i], divideColor(int(colours[3*e]), int(colours[(3*e)+1]), int(colours[(3*e)+2]))); 
			}
	}	
	self playerOptions( menu );	
}

playerOptions( menu )
{
	if(menu == "Client")
	{
		self addMenu("Client", "Client Options");
		foreach(player in level.players)
			self addOpt("[^2"+player.verStatus+"^7] "+player getName(), undefined,::newMenu,"Client "+player getEntityNumber());
	}
	
	foreach(player in level.players)
	{
		if(menu == "Client "+player getEntityNumber())
		{
			self addMenu("Client "+player getEntityNumber(), "[^2"+player.verStatus+"^7] "+player getName());
				self addOpt("Verification System", "Gives people the menu",::newMenu,"verify "+player getEntityNumber());
				self addOpt("EXAMPLE MENU", "Example",::newMenu, "example "+player getEntityNumber());
		}
		else if(menu == "verify "+player getEntityNumber())
		{
			self addMenu("verify "+player getEntityNumber(), player getName()+" Verification");
				self addOpt("Add From Co-Host List", undefined, ::coHostList, player, true);
				self addOpt("Remove From Co-Host List", undefined, ::coHostList, player, false);
				for(e=0;e<level.status.size-1;e++)
					self addOpt("Set Verification To "+level.status[e], undefined, ::initialSetUp, e, player, true);
		}	
		else if(menu == "example "+player getEntityNumber())
		{
			self addMenu("example "+player getEntityNumber(), "Example Menu");	
				self addOpt("EXAMPLE");
		}
	}
}

watchOpenMenu()
{
	self endon( "end_Menu" );
	self endon( "disconnect" );
	level endon( "game_ended" );

	while(!isDefined( self.eMenu["inMenu"] ))
	{
		if(self adsButtonPressed() && self meleeButtonPressed())
		{
			self thread openMenu();
			self playsoundtoplayer("", self);//MENU OPENING SOUND
			break;
		}
		wait .05;
	}
}

menuHandler()
{
	self endon( "end_Menu" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	while(isDefined( self.eMenu["inMenu"] ))
	{
		if(self adsButtonPressed() || self attackButtonPressed())
		{
			if(!self adsButtonPressed() || !self attackButtonPressed())
			{
				self.eMenu["isScrolling"] = true;
				curs = self.eMenu_C[ self getCurrentMenu()+"_Cursor" ];
				
				self playsoundtoplayer("", self);//MENU SCROLLING SOUND
				
				self.eMenu["OPT"][ curs ] fadeOverTime(.2);
				self.eMenu["OPT"][ curs ].color = self grabMenuColour( curs );
				
				if(!self adsButtonPressed()) 
					self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] += self attackButtonPressed();
				if(!self attackButtonPressed())
					self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] -= self adsButtonPressed();
					
				if(curs != self.eMenu_C[ self getCurrentMenu()+"_Cursor" ])
				{
					if(self adsButtonPressed()) 
						self thread revalueScrolling(-1);
					else self thread revalueScrolling(1);
				}
				wait .2;
				self.eMenu["isScrolling"] = undefined;
				self notify("SCROLLING_OVER");
			}
		}
		else if(self actionslotthreebuttonpressed() || self actionslotfourbuttonpressed())
		{
			if(!self actionslotthreebuttonpressed() || !self actionslotfourbuttonpressed())
			{
				curMenu = self getCurrentMenu();
				curs = self.eMenu_C[ self getCurrentMenu()+"_Cursor" ];
				
				if(isDefined(self.eMenu_S1[ curMenu ][ "slider" ][ curs ]))
				{
					if(!isDefined(self.eMenu_SS[ curMenu+"_Slider_Cursor_"+curs ]))
						self.eMenu_SS[ curMenu+"_Slider_Cursor_"+curs ] = 1;
					
					if(!self actionslotthreebuttonpressed())
						self.eMenu_SS[ curMenu+"_Slider_Cursor_"+curs ]++;
					if(!self actionslotfourbuttonpressed())
						self.eMenu_SS[ curMenu+"_Slider_Cursor_"+curs ]--;
						
					if(self.eMenu_SS[ curMenu+"_Slider_Cursor_"+curs ] > self.eMenu_S1[ curMenu ][ "slider" ][ curs ].size-1)
						self.eMenu_SS[ curMenu+"_Slider_Cursor_"+curs ] = 1;
					if(self.eMenu_SS[ curMenu+"_Slider_Cursor_"+curs ] < 1)
						self.eMenu_SS[ curMenu+"_Slider_Cursor_"+curs ] = self.eMenu_S1[ curMenu ][ "slider" ][ curs ].size-1;
						
					self updateMenu(self.eMenu_S1[ curMenu ][ "slider" ][ curs ][ 0 ] + " [{+actionslot 3}] " + self.eMenu_S1[ curMenu ][ "slider" ][ curs ][ self.eMenu_SS[ curMenu+"_Slider_Cursor_"+curs ] ] + " [{+actionslot 4}]");
					wait .2;
				}
			}
		}
		else if( self useButtonPressed() )
		{
			curs = self getCursor();
			menu = self getCurrentMenu();
			
			self playsoundtoplayer("", self);//MENU SELECT SOUND
			
			if(isDefined(self buildFromMenu().eMenu_F[ menu ][ "function" ][ curs ]) && self buildFromMenu().eMenu_F[ menu ][ "function" ][ curs ] == ::newMenu)
			{
				nextMenu = self buildFromMenu().eMenu_I[ menu ][ "i1" ][ curs ];
				self menuOptions(nextMenu);
				if(isDefined(self.eMenu_A[ nextMenu ][ "access" ]))
					list = self.eMenu_A[ nextMenu ][ "access" ];
				else list = "VIP;Admin;Co-Host;Host";
				accessLevels = strTok(list, ";");
				for(e=0;e<accessLevels.size;e++)
				{
					if(accessLevels[e] == self.verStatus)
					{
						self initializeMenuArrays(self.previousSubMenu[ self.previousSubMenu.size-1 ]);
						self thread [[ self buildFromMenu().eMenu_F[ menu ][ "function" ][ curs ] ]]( self buildFromMenu().eMenu_I[ menu ][ "i1" ][ curs ], self buildFromMenu().eMenu_I2[ menu ][ "i2" ][ curs ], self buildFromMenu().eMenu_I3[ menu ][ "i3" ][ curs ], self buildFromMenu().eMenu_I4[ menu ][ "i4" ][ curs ], self buildFromMenu().eMenu_I5[ menu ][ "i5" ][ curs ]);
					}
				}
				if(self getCurrentMenu() != nextMenu)
					self iprintln("^1Error^7: Your access level is not high enough to access this submenu.");
			}
			else if(isDefined(self.eMenu_S1[ menu ][ "slider" ][ curs ]))
			{
				if(!isDefined(self.eMenu_SS[ menu+"_Slider_Cursor_"+curs ]))
					self.eMenu_SS[ menu+"_Slider_Cursor_"+curs ] = 1;
				self thread [[ self buildFromMenu().eMenu_F[ menu ][ "function" ][ curs ] ]]( self.eMenu_S1[ menu ][ "slider" ][ curs ][ self.eMenu_SS[ menu+"_Slider_Cursor_"+curs ] ], self buildFromMenu().eMenu_I[ menu ][ "i1" ][ curs ], self buildFromMenu().eMenu_I2[ menu ][ "i2" ][ curs ], self buildFromMenu().eMenu_I3[ menu ][ "i3" ][ curs ], self buildFromMenu().eMenu_I4[ menu ][ "i4" ][ curs ], self buildFromMenu().eMenu_I5[ menu ][ "i5" ][ curs ]);
			}
			else self thread [[ self buildFromMenu().eMenu_F[ menu ][ "function" ][ curs ] ]]( self buildFromMenu().eMenu_I[ menu ][ "i1" ][ curs ], self buildFromMenu().eMenu_I2[ menu ][ "i2" ][ curs ], self buildFromMenu().eMenu_I3[ menu ][ "i3" ][ curs ], self buildFromMenu().eMenu_I4[ menu ][ "i4" ][ curs ], self buildFromMenu().eMenu_I5[ menu ][ "i5" ][ curs ]);
			wait .2;
		}
		else if(self meleeButtonPressed())
		{
			self playsoundtoplayer("", self);//MENU CLOSING SOUND
			if(self getCurrentMenu() == "main")
			{
				self thread closeMenu();
				break;
			}
			else
				self newMenu();
			wait .2;
		}
		wait .05;
	}
}

openMenu()
{
	self.eMenu["inMenu"] = true;
	if(isDefined(self.eMenu[ "CurrentMenu" ]))
		menu = self getCurrentMenu();
	else menu = "main";
	
	self setCurrentMenu(menu);
	self menuOptions(menu);
	self drawMenu();
	self thread menuHandler();
}

closeMenu()
{
	foreach(text in self.eMenu["OPT"])
	{
		text thread hudMoveY(0, .35);
		text thread hudFade(0, .35);
	}
	
	self.eMenu["HUDS"]["Background"] ScaleOverTime(.35, 155, 0);
	
	foreach(hud in self.eMenu["HUDS"])
	{
		hud thread hudFade(0, .35);
		hud thread hudMoveY(0, .35);
	}
	wait .35;
	
	self destroyMenu( true );
	self.eMenu["inMenu"] = undefined;
	self thread watchOpenMenu();
}

drawMenu()
{
	if(!isDefined( self.eMenu["OPT"]))
		self.eMenu["OPT"] = [];
	if(!isDefined( self.eMenu["HUDS"]))
		self.eMenu["HUDS"] = [];	
		
	self.eMenu["HUDS"]["Background"] = self createRectangle("CENTER", "CENTER", 0, -38, 155, 0, self.eMenu["Bg_Colour"], "white", 2, 0);
	self.eMenu["HUDS"]["Background"] thread hudFade(.6, .35);
	self.eMenu["HUDS"]["Background"] ScaleOverTime(.35, 155, 176);
	
	self.eMenu["HUDS"]["Banner"] = self createRectangle("TOP", "CENTER", 0, 0, 155, 40, self.eMenu["Main_Colour"], "white", 10, 0);	
	self.eMenu["HUDS"]["Banner"] thread hudFade(.7, .35);
	self.eMenu["HUDS"]["Banner"] thread hudMoveY(-165, .35);
	
	self.eMenu["HUDS"]["MenuName"] = self createOtherText("big", 2, "TOP", "CENTER", 0, 0, 11, 0, level.menuName, self.eMenu["Title_Colour"]);
	self.eMenu["HUDS"]["MenuName"] thread hudFade(1, .35);
	self.eMenu["HUDS"]["MenuName"] thread hudMoveY(-155, .35);
	
	self.eMenu["HUDS"]["InfoBox"] = self createRectangle("BOTTOM", "CENTER", 0, -15, 155, 15, self.eMenu["Main_Colour"], "white", 10, 0);
	self.eMenu["HUDS"]["InfoBox"] thread hudFade(.7, .35);
	self.eMenu["HUDS"]["InfoBox"] thread hudMoveY(65, .35);
	
	self.eMenu["HUDS"]["InfoTxt"] = self createText("small", 1, "LEFT", "CENTER", -70, -15, 11, 0, "by "+level.developer, self.eMenu["Title_Colour"]);
	self.eMenu["HUDS"]["InfoTxt"] thread hudFade(1, .35);
	self.eMenu["HUDS"]["InfoTxt"] hudMoveY(57, .35);
	
	self.eMenu["HUDS"]["Title"] = self createOtherText("small", 1.2, "CENTER", "CENTER", 0, -118, 11, 0, "", self.eMenu["Title_Colour"]);
	self.eMenu["HUDS"]["Scroller"] = self createRectangle("CENTER", "CENTER", 0, -100, 155, 13, self.eMenu["Main_Colour"], "white", 11, 0);
	
	self drawText(0, 0);
	self setMenuTitle();
}

drawText( x, alpha )
{
	self destroyAll(self.eMenu["OPT"]);

	start = 0;
	text = self buildFromMenu().eMenu_O[ self getCurrentMenu() ]["option"];
	
	max = 11;
	center = 5;
	centerBig = 6;
	
	if(self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] > center && self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] < text.size-centerBig && text.size > max)
		start = self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]-center;
	if(self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] > text.size-(centerBig + 1) && text.size > max)
		start = text.size-max;
	
	if(isDefined( level.eShader[ self getCurrentMenu() ]))
		sizes = strTok(level.eShader[ self getCurrentMenu() ],";");
	
	numOpts = text.size;
	if(numOpts >= max)
		numOpts = max;
	
	for(e=0;e<numOpts;e++)
	{
		if(isDefined(self.eMenu_ST[ self getCurrentMenu() ][ e+start ]))
			text = self buildFromMenu().eMenu_ST[ self getCurrentMenu() ];
		else text = self buildFromMenu().eMenu_O[ self getCurrentMenu() ]["option"];
		
		if(isDefined( text ) && isDefined( level.eShader[ self getCurrentMenu() ] ))
		{
			if(IsSubStr(text[e+start], ","))
			{
				colour = strTok(text[e+start], ",");
				shader = "white";
			}
			else 
			{
				shader = text[e+start];
				colour = strTok("255,255,255", ",");
			}
			self.eMenu["OPT"][e+start] = self createRectangle("CENTER","CENTER",0,-100 + (e*14),int(sizes[0]), int(sizes[1]), divideColor(int(colour[0]), int(colour[1]), int(colour[2])), shader, 12, alpha);
		}
		else if(isDefined( text ))
		{
			self.eMenu["OPT"][e+start] = self createOtherText("small",1,"CENTER","CENTER",0,-100 + (e*14),12,alpha,text[e+start],self grabMenuColour(e+start));
			self.eMenu["OPT"][e+start] thread hudFade(1,.25);
		}
	}	
		
	self.scrolling["def"] = self.eMenu_C[ self getCurrentMenu()+"_Cursor" ];
	self.eMenu["HUDS"]["Scroller"] thread hudMoveY(self.eMenu["OPT"][self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] ].y-0,.16);
	self.eMenu["HUDS"]["Scroller"] thread hudFade(.6,.16);
	self.eMenu["HUDS"]["Title"] hudFade(1,.16);
	self thread menuScrollColors( self getCursor() );
}

scrollingSystem(dir,ary)
{
	max = 11;
	center = 5;
	centerBig = 6;

	if(isDefined( level.eShader[ self getCurrentMenu() ]))
		sizes = strTok(level.eShader[ self getCurrentMenu() ],";");

	if(self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] < 0 || self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] > ary.size-1)
	{
		if(self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] < 0)
			self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] = ary.size-1;
		else
			self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] = 0;
			
		self.scrolling["def"] = self.eMenu_C[ self getCurrentMenu()+"_Cursor" ];
		if(ary.size > max)
		{
			self destroyAll(self.eMenu["OPT"]);
			curs = 0;
			if(self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] != 0) 
				curs = (ary.size)-max;
				
			for(e=0;e<max;e++)
			{
				if(isDefined(self.eMenu_ST[ self getCurrentMenu() ][ e+curs ]))
					ary1 = self buildFromMenu().eMenu_ST[ self getCurrentMenu() ];
				else ary1 = ary;
				
				if(isDefined( level.eShader[ self getCurrentMenu() ] ))
				{
					if(IsSubStr(ary1[e+curs], ","))
					{
						colour = strTok(ary1[e+curs], ",");
						shader = "white";
					}
					else 
					{
						shader = ary1[e+curs];
						colour = strTok("255,255,255", ",");
					}
					self.eMenu["OPT"][e+curs] = self createRectangle("CENTER","CENTER",0,-100 + (e*14),int(sizes[0]), int(sizes[1]), divideColor(int(colour[0]), int(colour[1]), int(colour[2])), shader, 12, 1);
				}
				else
				{
					self.eMenu["OPT"][e+curs] = self createOtherText("small",1,"CENTER","CENTER",0,-100 + (e*14),12,1,ary1[e+curs],self grabMenuColour(e+curs));
				}
			}
		}
	}
	if(self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] < ary.size-centerBig && self.scrolling["def"] > center || self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] > center && self.scrolling["def"] < ary.size-centerBig)
	{
		for(e=0;e<ary.size;e++) self.eMenu["OPT"][e] thread hudMoveY(self.eMenu["OPT"][e].y-14*dir,.16);
		self.eMenu["OPT"][self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+centerBig*dir*-1] thread hudFadenDestroy(0,.15);
		
		if(isDefined(self.eMenu_ST[ self getCurrentMenu() ][ self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+center*dir ]))
			ary = self buildFromMenu().eMenu_ST[ self getCurrentMenu() ];
		
		if(isDefined( level.eShader[ self getCurrentMenu() ] ))
		{
			if(IsSubStr(ary[self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+center*dir], ","))
			{
				colour = strTok(ary[self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+center*dir], ",");
				shader = "white";
			}
			else 
			{
				shader = ary[self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+center*dir];
				colour = strTok("255,255,255", ",");
			}
			self.eMenu["OPT"][self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+center*dir] = self createRectangle("CENTER","CENTER",0,self.eMenu["OPT"][self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] ].y+center*14*dir,int(sizes[0]), int(sizes[1]), divideColor(int(colour[0]), int(colour[1]), int(colour[2])), shader, 12, 0);
		}
		else
		{
			self.eMenu["OPT"][self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+center*dir] = self createOtherText("small",1,"CENTER","CENTER",0,self.eMenu["OPT"][self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] ].y+center*14*dir,12,0,ary[self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+center*dir],self grabMenuColour(self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+center*dir));
		}
		wait .05;
		self.eMenu["OPT"][self.eMenu_C[ self getCurrentMenu()+"_Cursor" ]+center*dir] thread hudFade(1,.18);
	}	
	else
		self.eMenu["HUDS"]["Scroller"] thread hudMoveY(self.eMenu["OPT"][self.eMenu_C[ self getCurrentMenu()+"_Cursor" ] ].y-0,.16);
	
	self.scrolling["def"] = self.eMenu_C[ self getCurrentMenu()+"_Cursor" ];
	self thread menuScrollColors( self getCursor() );
}

revalueScrolling(X)
{
	self scrollingSystem(X,self buildFromMenu().eMenu_O[ self getCurrentMenu() ]["option"]);
}

setMenuTitle( text )
{
	if(!isDefined(self buildFromMenu().eMenu_T[ self getCurrentMenu() ][ "Title" ]))
		self.eMenu["HUDS"]["Title"] setText("^1Undefined Menu");
	else if(!isDefined( text ))
		self.eMenu["HUDS"]["Title"] setText(self buildFromMenu().eMenu_T[ self getCurrentMenu() ][ "Title" ]);
	else 
		self.eMenu["HUDS"]["Title"] setText( text );
}

refreshTitle()
{
	if(isDefined(self.eMenu["HUDS"]["Title"]))
		self.eMenu["HUDS"]["Title"] destroy();
	if(isDefined(self.eMenu["HUDS"]["MenuName"]))
		self.eMenu["HUDS"]["MenuName"] destroy();	
		
	self.eMenu["HUDS"]["Title"] = self createOtherText("small", 1.2, "CENTER", "CENTER", 0, -115, 11, 1, "", self.eMenu["Title_Colour"]);
	self.eMenu["HUDS"]["MenuName"] = self createOtherText("big", 2, "TOP", "CENTER", 0, -155, 11, 1, level.menuName, self.eMenu["Title_Colour"]);
	self setMenuTitle();
}

destroyMenu( all )
{	
	self destroyAll( self.eMenu[ "OPT" ] );
	
	if(isDefined(all))
	{
		if(isDefined(self.eMenu[ "OPT" ])) 
			self destroyAll(self.eMenu[ "OPT" ]);
		if(isDefined(self.eMenu[ "HUDS" ]))
			self destroyAll(self.eMenu[ "HUDS" ]);
		if(isDefined(self.eMenu[ "OPT_BG" ]))
			self destroyAll(self.eMenu[ "OPT_BG" ]);
	}
}

menuScrollColors( curs )
{
	if(isDefined(self.eMenu_D[ self getCurrentMenu() ][ "description" ][ curs ]))
		self.eMenu["HUDS"]["InfoTxt"] setSafeText(self.eMenu_D[ self getCurrentMenu() ][ "description" ][ curs ]);
	else 
		self.eMenu["HUDS"]["InfoTxt"] setSafeText("by "+level.developer);

	if(isDefined( level.eShader[ self getCurrentMenu() ] ))
	{
		for(e=0;e<self buildFromMenu().eMenu_O[ self getCurrentMenu() ]["option"].size;e++)
		{
			self.eMenu["OPT"][e] fadeOverTime(.3);
			self.eMenu["OPT"][e].alpha = .25;
		}
		self.eMenu["OPT"][curs] fadeOverTime(.3);
		self.eMenu["OPT"][curs].alpha = 1;
		return;
	}
	
	self.eMenu["OPT_BG"][ curs ] fadeOverTime(.3);
	self.eMenu["OPT_BG"][ curs ].color = self.eMenu["Opt_Colour"];
	
	colour = self grabMenuColour( curs );
	if(!isDefined(self.eMenu_C1[ self getCurrentMenu() ][ "colour" ][ curs ]))
		colour = self.eMenu["Curs_Colour"];
		
	self.eMenu["OPT"][ curs ] fadeOverTime(.3);
	self.eMenu["OPT"][ curs ].color = colour;
}

SetColour( Var, Menu, Opt )
{
	if(self hasMenu())
	{
		if(isDefined(Menu))
		{
			if(isDefined(Var))
				self setOptionColor(self.eMenu["Select_Colour"],Menu,Opt);
			else
				self setOptionColor(self.eMenu["Opt_Colour"],Menu,Opt);
		}
		else
		{
			if(isDefined(Var))
				self setOptionColor(self.eMenu["Select_Colour"]);
			else
				self setOptionColor(self.eMenu["Opt_Colour"]);
		}
	}	
}

setOptionColor( colour, menu, curs )
{
	if(!isDefined( menu ))
		menu = self getCurrentMenu();
	if(!isDefined( curs ))
		curs = self getCursor();

	self.eMenu_C1[ menu ][ "colour" ][ curs ] = colour;
	
	if(colour == self.eMenu["Opt_Colour"])
	{
		if(self getCurrentMenu() == menu)
		{
			self.eMenu[ "OPT" ][ curs ] fadeOverTime(.1);
			self.eMenu[ "OPT" ][ curs ].color = self.eMenu["Curs_Colour"];
		}
		self.eMenu_C1[ menu ][ "colour" ][ curs ] = undefined;
	}
	if(colour == self.eMenu["Select_Colour"])
	{
		if(self getCurrentMenu() == menu)
		{
			self.eMenu[ "OPT" ][ curs ] fadeOverTime(.15);
			self.eMenu[ "OPT" ][ curs ].color = self.eMenu["Select_Colour"];
		}
	}
}

updateMenu( text, menu, curs )
{
	if( !isDefined( menu ) ) 
		menu = self getCurrentMenu();
	if( !isDefined( curs ) )
		curs = self getCursor();
	
	//self.eMenu_O[ menu ][ "option" ][ curs ] = text;
	self.eMenu_ST[ menu ][ curs ] = text;
		
	if(self isInMenu() && self getCurrentMenu() == menu && isDefined( self.eMenu[ "OPT" ][ curs ] ))
		self.eMenu[ "OPT" ][ curs ] setSafeText(text);
}

setMenuColours(var, huds, colour)
{
	self.eMenu[ var ] = colour;
	
	if(huds == "Scroller;Banner;InfoBox" || huds == "Title;InfoTxt;MenuName" || huds == "Background")
	{
		hud = strTok(huds, ";");
		for(e=0;e<huds.size;e++)
		{
			self.eMenu["HUDS"][ hud[e] ] fadeOverTime(.2);
			self.eMenu["HUDS"][ hud[e] ].color = colour;
		}	
	}
}

welcomeMessage()
{
	self.eMenu["HUDS"]["Welcome0"] = self createText("small",1.6,"TOP","TOP",0,0,9,1,"Welcome To ^2"+level.menuName+"^7 Your Access Level Is ^2"+self.verStatus,(1,1,1));
	self.eMenu["HUDS"]["Welcome1"] = self createText("small",1.6,"TOP","TOP",0,16,9,1,"^2"+level.menuName+"^7 Developed By ^2"+level.developer,(1,1,1));
	self.eMenu["HUDS"]["Welcome0"] setTypeWriterFx(50, 4500, 700);
	self.eMenu["HUDS"]["Welcome1"] setTypeWriterFx(50, 4500, 700);
	wait 8;
	for(e=0;e<2;e++)
		if(isDefined(self.eMenu["HUDS"]["Welcome"+e]))
			self.eMenu["HUDS"]["Welcome"+e] destroy();
}