package com.airhttp
{
	import com.airhttp.context.HttpContext;
	import com.airhttp.context.HttpsContext;
	import com.hurlant.crypto.tls.SSLSecurityParameters;
	import com.hurlant.crypto.tls.TLSConfig;
	import com.hurlant.crypto.tls.TLSEngine;
	
	import flash.events.Event;
	import flash.events.ServerSocketConnectEvent;
	import flash.utils.ByteArray;

	public class HttpsServer extends HttpServer
	{
		private var _serverConfig:TLSConfig;
		private var _cert:ByteArray;
		private var _key:ByteArray;
		
		public function HttpsServer(cert:ByteArray, key:ByteArray, host:String="127.0.0.1", port:uint=443)
		{
			_serverConfig = new TLSConfig(TLSEngine.CLIENT, null, null, null, null, null, SSLSecurityParameters.PROTOCOL_VERSION);
			_serverConfig.setPEMCertificate(cert.readUTFBytes(cert.length), key.readUTFBytes(key.length));
			cert.position = 0;
			key.position = 0;
			
			super(host, port);
			
			_cert = cert;
			_key = key;
		
			if (!cert || !key)
				throw new Error("Certificate or private key invalid");
			
		}
		
		override protected function onConnect(e:ServerSocketConnectEvent):void{
			var context:HttpContext=new HttpsContext(e.socket,e.socket.remoteAddress+":"+e.socket.remotePort, _serverConfig);
			context.addEventListener(Event.COMPLETE,onContextComplete);
		}
	}
}