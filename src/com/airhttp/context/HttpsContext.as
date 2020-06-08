package com.airhttp.context
{
	import com.hurlant.crypto.tls.TLSConfig;
	import com.hurlant.crypto.tls.TLSEngine;
	import com.hurlant.crypto.tls.TLSSocket;
	
	import flash.events.Event;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	
	public class HttpsContext extends HttpContext
	{
		private var _tlsSocket:TLSSocket;
		private var _tlsEngine:TLSEngine;
		private var _clientInput:ByteArray;
		private var _serverConfig:TLSConfig;
		
		public function HttpsContext(socket:Socket, clientID:String, serverConfig:TLSConfig)
		{
			_serverConfig = serverConfig;
			super(socket, clientID);
		}
		
		override protected function initialize():void{
			_request=new SecureHttpRequest(_socket, _serverConfig);
			_response=new HttpResponse(_socket);
			_request.addEventListener(Event.COMPLETE,onRequestComplete);
		}
	}
}