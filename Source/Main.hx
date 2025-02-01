package;
// This DOESN'T need to be a lime app, I'm just using lime so I can get a window

import lime.app.Application;
import lime.graphics.RenderContext;
import DiscordClient;
import Sys.sleep;
import Sys;
import discord_rpc.DiscordRpc;

class Main extends Application {
	public static var presence:DiscordPresenceOptions = {
		state: "N/A",
		details: "Waiting for valid application",
		largeImageKey: 'foobar2000',
		largeImageText: "icon",
		activityType:2
	};

	var stdin:haxe.io.Input;
	var char = ('|').charCodeAt(0);
	public function new () {
		
		super();

		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: Sys.args()[0] ?? sys.io.File.getContent('APPID'),
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");
		sys.thread.Thread.create(() ->{
			while(true){
				var _in = Sys.stdin().readLine();
				if(_in == "END") {
					shutdown();
					Sys.exit(0);
				}
				if(_in.indexOf('=') != -1){
					try{
						var everything = _in.split('&');
						for (i in everything){
							var stuff = i.split("=");
							trace(stuff);
							Reflect.setField(presence,stuff[0],stuff[1]);
						}
						DiscordRpc.presence(presence);
					}catch(e){
						trace('Unable to update presence with $_in:$e');
					}
				}else{

					trace(_in);
					var stuff = _in.split("|");
					presence.details = stuff[0];
					presence.state = stuff[1];
					DiscordRpc.presence(presence);
				}
				DiscordRpc.process();
			}
		});
		sys.thread.Thread.create(() ->{
			while (true) {
				DiscordRpc.process();
				sleep(30);
			}
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}
	public static function shutdown()
	{
		#if discord_rpc
		DiscordRpc.shutdown();
		#end
	}
	
	static function onReady()
	{
		#if discord_rpc
		DiscordRpc.presence(presence);
		#end
	}


	
}