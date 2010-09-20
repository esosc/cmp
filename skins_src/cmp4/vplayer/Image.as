﻿package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	
	public class Image extends Sprite {

		//cmp的api接口
		private var api:Object;

		private var loader:Loader;
		
		//修正加载皮肤时找不到bitmapData属性报错的情况
		public var bitmapData:BitmapData;
		
		public function Image() {
			//侦听api的发送
			this.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			this.loaderInfo.sharedEvents.addEventListener('api_remove', apiRemoveHandler);
		}

		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//添加侦听事件，必须传入通信key
			//改变大小时调用
			api.addEventListener(apikey.key, 'resize', resizeHandler);
			//状态改变时调用
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			api.addEventListener(apikey.key, 'model_start', startHandler);
			
			loadImage();

			api.win_list.media.video.vi.ip.visible = true;

			//初始位置尺寸
			resizeHandler();
			//初始化播放状态
			stateHandler();
		}
		
		private function apiRemoveHandler(e:Event = null):void {
			api.win_list.media.video.vi.ip.visible = false;
		}
		
		
		private function loadImage():void {

			if (!api.config.image) {
				return;
			}
			
			//api.tools.output(api.config.image);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			var request:URLRequest = new URLRequest(api.config.image);
            loader.load(request);
          	img.addChild(loader);
		}
		private function completeHandler(event:Event):void {
			resizeHandler();
        }
		private function ioErrorHandler(event:IOErrorEvent):void {
        }
		
		//video_scalemode: 缩放模式 默认为1
		//1在指定区域中可见，且不会发生扭曲，同时保持应用程序的原始高宽比
		//2在指定区域中可见，但不尝试保持原始高宽比。可能会发生扭曲，应用程序可能会拉伸或压缩显示
		//3指定整个应用程序填满指定区域，不会发生扭曲，但有可能会进行一些裁切，同时保持应用程序的原始高宽比
		//0不进行缩放，即使在更改播放器窗口大小时，它仍然保持不变


		//尺寸改变时调用
		private function resizeHandler(e:Event = null):void {
			//获取cmp的宽高
			var cw:Number = api.config.video_width;
			var ch:Number = api.config.video_height;
			//
			this.scaleX = this.scaleY = 1;
			bg.width = cw;
			bg.height = ch;
			
			api.tools.zoom.fit(img, cw, ch, api.config.video_scalemode);
			
			x = api.win_list.media.video.x;
			y = api.win_list.media.video.y;
		}

		//播放状态改变时调用
		private function stateHandler(e:Event = null):void {
			
			if (api.config.state == "stopped") {
				img.visible = true;
				api.win_list.media.video.vi.ip.visible = true;
			}
			
		}
		
		private function startHandler(e:Event = null):void {
			img.visible = false;
		}

		

	}

}