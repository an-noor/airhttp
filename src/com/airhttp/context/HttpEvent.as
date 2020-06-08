package com.airhttp.context
{
	import flash.events.Event;
	
	public class HttpEvent extends Event
	{
		/**
		 * 新的连接的接入 
		 */		
		public static const NEW_CONTEXT:String="newContext";
		
		private var _context:HttpContext;
		
		public function HttpEvent(context:HttpContext, type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._context = context;
		}
		
		public function get context():HttpContext{
			return _context;
		}
		
	}
}