package
{
	import com.as3breeze.air.ane.android.Bluetooth;
	import com.as3breeze.air.ane.android.BluetoothDevice;
	import com.as3breeze.air.ane.android.events.BluetoothBondEvent;
	import com.as3breeze.air.ane.android.events.BluetoothDataEvent;
	import com.as3breeze.air.ane.android.events.BluetoothDeviceEvent;
	import com.as3breeze.air.ane.android.events.BluetoothEvent;
	import com.as3breeze.air.ane.android.events.BluetoothScanEvent;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	[SWF(width="1080", height="1920", frameRate="60", backgroundColor="#000000")]
	public class BluetoothExam extends Sprite {
		private var bt:Bluetooth;
		private var availableDevice:Vector.<BluetoothDevice>;
		private var pairedDevice:Vector.<BluetoothDevice>;
		private var selectDevice:BluetoothDevice;
		private var connectedDevice:BluetoothDevice;
		private var device:BluetoothDevice;
		
		private var logField:TextField;
		private var messageField:TextField;
		
		public function BluetoothExam() {
			super();
			
			if(stage) init();
			else this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(event:Event = null):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.autoOrients = false;
			
			setupUI();
			
			log("init!!!");
			
			if (Bluetooth.isSupported()) {
				log("Bluetooth Ready.");
				bt = Bluetooth.currentAdapter();
				
				// Fired when bluetooth ANE is initialized
				bt.addEventListener( BluetoothEvent.BLUETOOTH_ANE_INITIALIZED, initFunc);
				
//				bt.addEventListener( BluetoothEvent.BLUETOOTH_ON, bluetoothEventHandler );
//				bt.addEventListener( BluetoothEvent.BLUETOOTH_OFF, bluetoothEventHandler );
//				bt.addEventListener( BluetoothBondEvent.BLUETOOTH_DEVICE_BONDED, bluetoothBondHandler );
//				bt.addEventListener( BluetoothBondEvent.BLUETOOTH_DEVICE_UNBONDED, bluetoothBondHandler );
				bt.addEventListener( BluetoothScanEvent.BLUETOOTH_DEVICE_FOUND, bluetoothScanEventHandler );
				bt.addEventListener( BluetoothScanEvent.BLUETOOTH_DISCOVERY_FINISHED, bluetoothScanEventHandler );
				bt.addEventListener( BluetoothScanEvent.BLUETOOTH_DISCOVERY_STARTED, bluetoothScanEventHandler );
				bt.addEventListener( BluetoothDeviceEvent.BLUETOOTH_DEVICE_CONNECTED, bluetoothDeviceEvent );
				bt.addEventListener( BluetoothDeviceEvent.BLUETOOTH_DEVICE_DISCONNECTED, bluetoothDeviceEvent );
				bt.addEventListener( BluetoothDeviceEvent.BLUETOOTH_DEVICE_PAIRING_REQUEST, bluetoothDeviceEvent );
			}
		}
		
			
		
		
		private function initFunc(event:BluetoothEvent):void {
			if( !bt.localDeviceAddress ){
				log("BT initiated but not enabled "+ bt.localDeviceName + " "+ bt.localDeviceAddress );
				return;
			}
			log("BT initiated and enabled "+ bt.localDeviceName+" "+ bt.localDeviceAddress );
		}
		
		protected function bluetoothScanEventHandler(event:BluetoothScanEvent):void
		{
			switch(event.type) {
				case BluetoothScanEvent.BLUETOOTH_DEVICE_FOUND:
					log( "Device found:  ["+event.device.address+"] - Bond ("+event.device.bondState+")" );
					break;
				case BluetoothScanEvent.BLUETOOTH_DISCOVERY_FINISHED:
					log( "Scan finished!" );
					break;
				case BluetoothScanEvent.BLUETOOTH_DISCOVERY_STARTED:
					log( "Starting scan..." );
					break;
			}
		}
		
		private function bluetoothDeviceEvent(event:BluetoothDeviceEvent):void
		{
			switch(event.type) {
				case BluetoothDeviceEvent.BLUETOOTH_DEVICE_CONNECTED:
					connectedDevice = event.device;
					log( "Device connected: " + connectedDevice.name );
					connectedDevice.addEventListener( BluetoothDataEvent.BLUETOOTH_RECEIVE_DATA, bluetoothDataHandler);
					break;
				case BluetoothDeviceEvent.BLUETOOTH_DEVICE_DISCONNECTED:
					connectedDevice.removeEventListener( BluetoothDataEvent.BLUETOOTH_RECEIVE_DATA, bluetoothDataHandler);
					log("Device disconnected: "+event.device.name);
					break;
				case BluetoothDeviceEvent.BLUETOOTH_DEVICE_PAIRING_REQUEST:
					event.device.createBond( "1234" );
					break;
			}
		}	
		
		private function scan(event:Event):void {
			bt.scanForVisibleDevices();
		}
		
		private function connectBT(event:Event):void {
			pairedDevice = bt.getPairedDevices();
			pairedDevice.forEach( function( device:BluetoothDevice, index:int, arr:Vector.<BluetoothDevice>){
				log(device.name + " ["+device.address+"] - Bond ("+device.bondState+")");
			});
			selectDevice = pairedDevice[0];
			if( selectDevice ){
				selectDevice.connect();
				return;
				switch(selectDevice.bondState){
					case 10: // Not bonded
					case 11: // In bonding state tho sometimes the pass needs to be passed when in bonding state
//						var pass:String = bondPass.text;
//						selectDevice.createBond( pass );
//						log( "Creating bond with "+selectDevice.name );
						break;
					case 12: // Device is bonded, and we'll connect using general UUID
						log( "Connecting with "+selectDevice.name );
						selectDevice.connect();
						break;
					default:break;
				}
			}
		}
		
		private function btRemoteOn(event:Event):void {
			var data:String = "on\n";
			var ba:ByteArray = new ByteArray(); 
			ba.writeUTFBytes( data ); 
			ba.position = 0; 
			
			connectedDevice.sendData(ba); 
		}
		
		private function btLedOn(event:Event):void {
			var data:String = "ledon\n";
			var ba:ByteArray = new ByteArray(); 
			ba.writeUTFBytes( data ); 
			ba.position = 0; 
			
			connectedDevice.sendData(ba); 
		}
		
		private function btLedOff(event:Event):void {
			var data:String = "ledoff\n";
			var ba:ByteArray = new ByteArray(); 
			ba.writeUTFBytes( data ); 
			ba.position = 0; 
			
			connectedDevice.sendData(ba); 
		}
		
		private function bluetoothDataHandler( b:BluetoothDataEvent ):void{
			var str:String = "";
			str = b.data.readUTFBytes( b.data.bytesAvailable );
			message("Received: "+ str);
		}
		
		private function log(text:String):void {
			logField.appendText(text + "\n");
			logField.scrollV = logField.maxScrollV;
		}
		
		private function message(text:String):void {
			messageField.appendText(text + "\n");
			messageField.scrollV = messageField.maxScrollV;
		}
		
		private function setupUI():void {
			// Btn
			createTextButton(50, 400, "scanning", scan);
			createTextButton(240, 400, "connect BT", connectBT);
			createTextButton(50, 550, "REMOTE ON", btRemoteOn);
			createTextButton(240, 550, "LED ON", btLedOn);
			createTextButton(430, 550, "LED OFF", btLedOff);
			
			 // Text Field
			logField = createTextField(0, 0, "log field", "log: ",  true, 1079);
			messageField = createTextField(0, 1580, "message", "message: \n", true, 1079);
		}
		
		
		
		private function createTextField(x:int, y:int, label:String, defaultValue:String='', editable:Boolean=true,width:int=1080, height:int=20):TextField {
			var labelField:TextField = new TextField();
			labelField.text = label;
			labelField.type = TextFieldType.DYNAMIC;
			labelField.width = 180;
			labelField.height = 40;
			labelField.x = x;
			labelField.y = y;
			
			var input:TextField = new TextField();
			input.text = defaultValue;
			input.type = TextFieldType.INPUT;
			input.border = editable;
			input.borderColor = 0xFFFFFF;
			input.selectable = editable;
			input.width = width;
			input.height = 280;
			input.x = x;
			input.y = y + labelField.height;
			
			var format:TextFormat = new TextFormat();
			format.font = "Hack";
			format.color = 0xFFFFFF;
			format.size = 24;
			
			labelField.setTextFormat(format);
			input.setTextFormat(format);
			
			this.addChild(labelField);
			this.addChild(input);
			
			return input;
		}
		
		private function createTextButton(x:int, y:int, label:String, clickHandler:Function):TextField {
			var button:TextField = new TextField();
			button.htmlText = "<u><b>" + label + "</b></u>";
			button.type = TextFieldType.DYNAMIC;
			button.selectable = false;
			button.width = 180;
			button.border = true;
			button.borderColor = 0xFFFFFF;
			button.x = x;
			button.y = y;
			button.addEventListener(MouseEvent.CLICK, clickHandler);
			
			var format:TextFormat = new TextFormat();
			format.font = "Hack";
			format.align = TextFormatAlign.CENTER;
			format.color = 0xFFFFFF;
			format.size = 28;
			
			button.setTextFormat(format);
			
			this.addChild(button);
			return button;
		}
	}
}