package com.airhttp.context
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.Socket;
	
	[Event(name="complete", type="flash.events.Event")]
	public class HttpContext extends EventDispatcher
	{
		protected var _request:HttpRequest;
		protected var _response:HttpResponse;
		private var _clientID:String;
		protected var _socket:Socket;
		
		public function HttpContext(socket:Socket,clientID:String)
		{
			this._socket=socket;
			this._clientID=clientID;
			initialize();
		}
		
		protected function initialize():void{
			_request=new HttpRequest(_socket);
			_response=new HttpResponse(_socket);
			_request.addEventListener(Event.COMPLETE,onRequestComplete);
		}
		
		protected function onRequestComplete(e:Event):void{
			_request.removeEventListener(Event.COMPLETE,onRequestComplete);
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function get request():HttpRequest{return _request;}
		public function get response():HttpResponse{return _response;}
		public function get clientID():String{return _clientID;}
	}
}