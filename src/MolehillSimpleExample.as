package
{
	import com.adobe.*;
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.TriangleCulling;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	[SWF(frameRate="60")]
	
	public class MolehillSimpleExample extends Sprite
	{
		private var context3D:Context3D;
		private var vertexBuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		private var stage3D:Stage3D;
		private var program:Program3D;
		
		private var originalWidth:uint;
		private var originalHeight:uint;

		public function MolehillSimpleExample()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			originalWidth = stage.stageWidth;
			originalHeight = stage.stageHeight;
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, context3DCreateHandler);
			stage3D.requestContext3D(); 
		}
		
		private function createShader(type:String, opcodes:Array):ByteArray
		{
			var assembler:AGALMiniAssembler = new AGALMiniAssembler();
			assembler.assemble(type, opcodes.join('\n'));
			return assembler.agalcode;
		}
		
		private function context3DCreateHandler(event:Event):void
		{
			context3D = stage3D.context3D;
			
			trace(context3D.driverInfo);
			
			context3D.enableErrorChecking = true;
			
			context3D.configureBackBuffer(originalWidth, originalHeight, 2, true);
			
			vertexBuffer = context3D.createVertexBuffer(3, 6);
			vertexBuffer.uploadFromVector(Vector.<Number>([
				-1, -1, 0, 1, 0, 0,
				-1,  1, 0, 0, 1, 0,
				 1, -1, 0, 0, 0, 1]), 0, 3); 
				
			context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
			
			indexBuffer = context3D.createIndexBuffer(3);
			indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2]), 0, 3);
			
			var viewMatrix:Matrix3D = new Matrix3D();

			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, viewMatrix, true);
			
			program = context3D.createProgram();
			program.upload(
				createShader(Context3DProgramType.VERTEX,
					["m44 op, va0, vc0", "mov v0, va1"]),
				createShader(Context3DProgramType.FRAGMENT,
					["mov oc, v0"]));
			
			context3D.setProgram(program);
			
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function enterFrameHandler(event:Event):void
		{
			context3D.clear();
			context3D.drawTriangles(indexBuffer, 0, 1);
			context3D.present();
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			vertexBuffer.uploadFromVector(Vector.<Number>([
				-1, -1, 0, Math.random(), Math.random(), Math.random(),
				-1, 1, 0,  Math.random(), Math.random(), Math.random(),
				1, -1, 0,  Math.random(), Math.random(), Math.random()]), 0, 3); 
		}
	}
}