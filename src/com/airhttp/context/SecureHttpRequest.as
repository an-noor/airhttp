package com.airhttp.context
{
	import com.hurlant.crypto.tls.TLSConfig;
	import com.hurlant.crypto.tls.TLSSocket;
	
	import flash.net.Socket;
	import flash.utils.ByteArray;
	
	public class SecureHttpRequest extends HttpRequest
	{
		private var _tlsSocket:TLSSocket;
		private var _clientInput:ByteArray;
		private var _serverConfig:TLSConfig;

		public function SecureHttpRequest(socket:Socket, serverConfig:TLSConfig)
		{
			_serverConfig = serverConfig;
			super(socket);
		}
		
		override protected function initialize():void{
			
			/*_clientInput = new ByteArray;
			_tlsEngine = new TLSEngine(_serverConfig, socket, socket);
			socket.addEventListener(ProgressEvent.SOCKET_DATA, _tlsEngine.dataAvailable);
			_tlsEngine.addEventListener(ProgressEvent.SOCKET_DATA, function(e:*):void { socket.flush(); });
			_tlsEngine.start();
			
			clearTimeout(_timeout);
			_timeout=setTimeout(reader_end,1000);*/
			_tlsSocket = new TLSSocket(null, null, _serverConfig);
			_tlsSocket.startTLS(socket, socket.localAddress, _serverConfig);
			
		}
	}
}