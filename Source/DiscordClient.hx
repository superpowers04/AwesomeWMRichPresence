package;

import Sys.sleep;
#if discord_rpc
import discord_rpc.DiscordRpc;
#end
using StringTools;

class DiscordClient {
	public static var id = "";
	public function new()
	{
		#if discord_rpc
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: id,
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true) {
			DiscordRpc.process();
			sleep(2);
			//trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#end
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
		DiscordRpc.presence({
			details: "Init",
			state: "beans",
			largeImageKey: 'icon',
			largeImageText: "icon"
		});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		#if discord_rpc
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		#end
	}
	static var _details:String = "";
	static var _state = "";
	static var _timestampStart:Float = 0;
	static var _timestampEnd:Float = 0;

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, startTimestamp:Float = 0, ?endTimestamp: Float = 0) {
		if(details == _details && _state == state && _timestampEnd == endTimestamp && _timestampStart == startTimestamp){return;}
		_timestampStart = startTimestamp;
		_timestampEnd = endTimestamp;
		if(startTimestamp > -1 && endTimestamp > 0){
			endTimestamp = startTimestamp + endTimestamp;
		}


		DiscordRpc.presence({
			details: _details = details,
			state: _state = state,
			largeImageKey: 'icon',
			largeImageText: "icon",
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
			endTimestamp : Std.int(endTimestamp / 1000)
		});

		trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $startTimestamp, $endTimestamp');
	}
}