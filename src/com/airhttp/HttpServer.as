package com.airhttp
{
    import com.airhttp.context.HttpContext;
    import com.airhttp.context.HttpEvent;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.ServerSocketConnectEvent;
    import flash.net.ServerSocket;
    import flash.net.Socket;
    import flash.net.URLVariables;
    import flash.utils.Dictionary;
    
    import mx.controls.Alert;
    
    import avmplus.getQualifiedClassName;

    /**
    * HttpServer is a simple HTTP server capable of responding to GET requests
    * for Controllers that have been registered with it and files that can
    * be found relative to webroot under an AIR application's applicationStorage
    * directory. This server only binds to a port on localhost and is meant as
    * a way to provide access to services within/for a local process.
    * <p>
    * After construction, instances of controllers may be added to respond to
    * various HTTP GET requests. @see com.minihttp.HttpController for more on this.
    * </p>
    * <p>
    * If a matching controller to a request is found, the action (defaulting to
    * index) specified is called along with any provided parameters.
    * </p>
    * </p>
    * If no matching controller is found, the server attempts to use its FileController
    * to load the specified file (@see com.minihttp.FileController).
    * <p>
    * <p>
    * The following is a simple example showing how to initialize and start a server
    * instance. This example will respond to the urls <code>http://localhost/app/config</code>
    * and <code>http://localhost/app/status</code>.
    * </p>
    * <code>
    * ...
    *   var webserv:HttpServer = new HttpServer();
    * 
    *   webserv.registerController(new Appcontroller(myApplication));
    *   webserv.listen(4567);
    * ...
    * </code>
    * 
     */
	[Event(name="newContext", type="com.isdraw.http.HttpEvent")] 
    public class HttpServer extends EventDispatcher
    {
        private var _serverSocket:ServerSocket;
        private var _controllers:Object = new Object();
        private var _fileController:FileController;
        private var _errorCallback:Function = null;
        private var _isConnected:Boolean = false;
        private var _maxRequestLength:int = 2048;
        
		// Additions
		private var cache:Dictionary=new Dictionary(true);
		
		protected var _host:String;
		protected var _port:int;
		
        public function HttpServer(host:String="127.0.0.1", port:int=80)
        {
			_host = host;
			_port = port;
			
            registerController(new FileController());    
			addEventListener(HttpEvent.NEW_CONTEXT, onNewContext);
        }
		
        /**
        * Retrieve the document root from the server.
         */
        public function get docRoot():String
        {
            return _fileController.docRoot;
        }
        
        public function get isConnected():Boolean
        {
            return _isConnected;
        }

        /**
        * Get the maximum lenght of a request in bytes.
        * Requests longer than this will be truncated.
        */
        public function get maxRequestLength():int
        {
          return _maxRequestLength;
        }
        
        /**
        * Set the maximum lenght of a request in bytes.
        * Requests longer than this will be truncated.
        */
        public function set maxRequestLength(value:int):void
        {
          _maxRequestLength = value;
        }
        
		
		protected function initialize():void{
			_serverSocket = new ServerSocket();
			_serverSocket.addEventListener(Event.CONNECT, onConnect);
			_serverSocket.bind(_port, _host);
			_serverSocket.listen();
		}
        /**
        * Begin listening on a specified port.
        * 
        * @param port The localhost port to begin listening on.
        * @param errorCallback The callback to call when an error occurs. If this
        * is null, an Alert box is displayed.
        * 
        * @return true if the port was opened, false if it could not be opened.
         */
        public function listen(errorCallback:Function = null):Boolean
        {
            this._errorCallback = errorCallback;
            
            try
            {
				initialize();
            }
            catch (error:Error)
            {
                var message:String = "Port " + _port.toString() +
                    " may be in use. Enter another port number and try again.\n(" +
                    error.message +")";
                if (errorCallback != null) {
                    errorCallback(error, message);
                }
                else {
                    Alert.show(message, "Error");
                }
                return false;
            }
            return true;
        }
        
        /**
        * Add a Controller to the Server
         */
        public function registerController(controller:ActionController):HttpServer
        {
            _controllers[controller.route] = controller;
            return this;  
        }
        
		/**
		 * 连接客户端 
		 * @param e
		 */		
		protected function onConnect(e:ServerSocketConnectEvent):void{
			var context:HttpContext=new HttpContext(e.socket,e.socket.remoteAddress+":"+e.socket.remotePort);
			context.addEventListener(Event.COMPLETE,onContextComplete);
		}
		
		/**
		 * request处理结束 
		 * @param e
		 * 
		 */		
		protected function onContextComplete(e:Event):void{
			var context:HttpContext=e.target as HttpContext;
			context.removeEventListener(Event.COMPLETE,onContextComplete);
			var h:HttpEvent=new HttpEvent(context, HttpEvent.NEW_CONTEXT);
			this.dispatchEvent(h);
			context.response.flush();
		}
		
		protected function onNewContext(event:HttpEvent):void
		{
			// Parse out the controller name, action name and paramert list
			var url_pattern:RegExp      = /(.*)\/([^\?]*)\??(.*)$/;
			var url:String				= event.context.request.rawURL;
			var controller_key:String   = url.replace(url_pattern, "$1");
			var action_key:String       = url.replace(url_pattern, "$2");
			var param_string:String     = url.replace(url_pattern, "$3");
			
			var controller:ActionController = _controllers[controller_key];
			
			if (controller) {
				controller.doAction(action_key, event.context.request.json);
				/*try{
				}catch(e:Error){
					throw new Error("The method [" + action_key + "] in " + getQualifiedClassName(controller) + " class doesn't exit");
				}*/
			}
			
		}

    }
}