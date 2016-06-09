package com.greensock.plugins{
	import com.greensock.*;
	import com.greensock.core.*;
	import com.greensock.plugins.*;
	import com.greensock.plugins.helpers.*;

	public class ThrowPropsPlugin extends TweenPlugin {
		/** @private **/
		public static var API:Number=1.0;//If the API/Framework for plugins changes in the future, this number helps determine compatibility
		/** 
		 * The default <code>resistance</code> that is used to calculate how long it will take 
		 * for the tweening property (or properties) to come to rest by the static <code>ThrowPropsPlugin.to()</code>
		 * and <code>ThrowPropsPlugin.calculateTweenDuration()</code> methods. Keep in mind that you can define
		 * a <code>resistance</code> value either for each individual property in the <code>throwProps</code> tween
		 * like this:<br /><br /><code>
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{_x:{velocity:500, resistance:150}, _y:{velocity:-300, resistance:50}}});
		 * </code><br /><br />
		 * 
		 * <strong>OR</strong> you can define a single <code>resistance</code> value that will be used for all of the 
		 * properties in that particular <code>throwProps</code> tween like this:<br /><br /><code>
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{_x:500, _y:-300, resistance:150}}); <br /><br />
		 * 
		 * //-OR- <br /><br />
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{_x:{velocity:500, max:800, min:0}, _y:{velocity:-300, max:800, min:100}, resistance:150}});
		 * </code><br /><br /> 
		 **/
		public static var defaultResistance:Number=100;

		/** @private **/
		private var _tween:TweenLite;
		/** @private **/
		private var _target:Object;
		/** @private **/
		private var _props:Array;


		/** @private **/
		public function ThrowPropsPlugin() {
			super();
			this.propName="throwProps";//name of the special property that the plugin should intercept/manage
			this.overwriteProps=[];
		}

		/**
		 * Automatically analyzes various throwProps variables (like <code>velocity</code>, <code>max</code>, <code>min</code>, 
		 * and <code>resistance</code>) and creates a TweenLite instance with the appropriate duration. You can use
		 * <code>ThrowPropsPlugin.to()</code> instead of <code>TweenLite.to()</code> to create
		 * a tween - they're identical except that <code>ThrowPropsPlugin.to()</code> doesn't have a 
		 * <code>duration</code> parameter (it figures it out for you) and it adds a few extra parameters
		 * to the end that can optionally be used to affect the duration. <br /><br />
		 * 
		 * Another key difference is that <code>ThrowPropsPlugin.to()</code> will recognize the 
		 * <code>resistance</code> special property which basically controls how quickly each 
		 * property's velocity decelerates (and consequently influences the duration of the tween). 
		 * For example, if the initial <code>velocity</code> is 500 and the <code>resistance</code> 
		 * is 300, it will decelerate much faster than if the resistance was 20. You can define
		 * a <code>resistance</code> value either for each individual property in the <code>throwProps</code> 
		 * tween like this:<br /><br /><code>
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{_x:{velocity:500, resistance:150}, _y:{velocity:-300, resistance:50}}});
		 * </code><br /><br />
		 * 
		 * <strong>OR</strong> you can define a single <code>resistance</code> value that will be used for all of the 
		 * properties in that particular <code>throwProps</code> tween like this:<br /><br /><code>
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{_x:500, _y:-300, resistance:150}}); <br /><br />
		 * 
		 * //-OR- <br /><br />
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{_x:{velocity:500, max:800, min:0}, _y:{velocity:-300, max:700, min:100}, resistance:150}});
		 * </code><br /><br /> 
		 * 
		 * <code>resistance</code> should always be a positive value, although <code>velocity</code> can be negative. 
		 * <code>resistance</code> always works against <code>velocity</code>. If no <code>resistance</code> value is 
		 * found, the <code>ThrowPropsPlugin.defaultResistance</code> value will be used. The <code>resistance</code>
		 * values merely affect the duration of the tween and can be overriden by the <code>maxDuration</code> and 
		 * <code>minDuration</code> parameters. Think of the <code>resistance</code> as more of a suggestion that 
		 * ThrowPropsPlugin uses in its calculations rather than an absolute set-in-stone value. When there are multiple
		 * properties in one throwProps tween (like <code>x</code> and <code>y</code>) and the calculated duration
		 * for each one is different, the longer duration is always preferred in order to make things animate more 
		 * smoothly.<br /><br />
		 * 
		 * You also may want to impose some restrictions on the tween's duration (if the user drags incredibly 
		 * fast, for example, you might not want the tween to last 200 seconds). Use <code>maxDuration</code> and 
		 * <code>minDuration</code> parameters for that. You can use the <code>overshootTolerance</code>
		 * parameter to set a maximum number of seconds that can be added to the tween's duration (if necessary) to 
		 * accommodate temporarily overshooting the end value before smoothly returning to it at the end of the tween. 
		 * This can happen in situations where the initial velocity would normally cause it to exceed the <code>max</code> 
		 * or <code>min</code> values. An example of this would be in the iOS (iPhone or iPad) when you flick-scroll 
		 * so quickly that the content would shoot past the end of the scroll area. Instead of jerking to a sudden stop
		 * when it reaches the edge, the content briefly glides past the max/min position and gently eases back into place. 
		 * The larger the <code>overshootTolerance</code> the more leeway the tween has to temporarily shoot past the 
		 * max/min if necessary. 
		 * 
		 * 
		 * @param target Target object whose properties the tween affects. This can be ANY object, not just a DisplayObject. 
		 * @param vars An object containing the end values of the properties you're tweening, and it must also contain a <code>throwProps</code> object. For example, to create a tween that tweens <code>mc.x</code> at an initial velocity of 500 and <code>mc.y</code> at an initial velocity of -300 and applies a <code>resistance<code> of 80 and uses the <code>Strong.easeOut</code> easing equation and calls the method <code>tweenCompleteHandler</code> when it is done, the <code>vars</code> object would look like: <code>{throwProps:{x:500, y:-300, resistance:80}, ease:Strong.easeOut, onComplete:tweenCompleteHandler}</code>.
		 * @param maxDuration Maximum duration of the tween
		 * @param minDuration Minimum duration of the tween
		 * @param overshootTolerance sets a maximum number of seconds that can be added to the tween's duration (if necessary) to 
		 * accommodate temporarily overshooting the end value before smoothly returning to it at the end of the tween. 
		 * This can happen in situations where the initial velocity would normally cause it to exceed the <code>max</code> 
		 * or <code>min</code> values. An example of this would be in the iOS (iPhone or iPad) when you flick-scroll 
		 * so quickly that the content would shoot past the end of the scroll area. Instead of jerking to a sudden stop
		 * when it reaches the edge, the content briefly glides past the max/min position and gently eases back into place. 
		 * The larger the <code>overshootTolerance</code> the more leeway the tween has to temporarily shoot past the 
		 * max/min if necessary.
		 * @return TweenLite instance
		 * 
		 * @see #defaultResistance
		 */
		static public function to(target:Object, vars:Object, maxDuration:Number, minDuration:Number, overshootTolerance:Number):TweenLite {
			if (vars.throwProps==undefined) {
				vars={throwProps:vars};
			}
			return new TweenLite(target, calculateTweenDuration(target, vars, maxDuration, minDuration, overshootTolerance), vars);
		}

		/**
		 * Determines the amount of change given a particular velocity, an specific easing equation, 
		 * and the duration that the tween will last. This is useful for plotting the resting position
		 * of an object that starts out at a certain velocity and decelerates based on an ease (like 
		 * <code>Strong.easeOut</code>). 
		 * 
		 * @param velocity The initial velocity
		 * @param ease The easing equation (like <code>Strong.easeOut</code> or <code>Quad.easeOut</code>).
		 * @param duration The duration (in seconds) of the tween
		 * @param checkpoint A value between 0 and 1 (typically 0.05) that is used to measure an easing equation's initial strength. The goal is for the value to have moved at the initial velocity through that point in the ease. So 0.05 represents 5%. If the initial velocity is 500, for example, and the ease is <code>Strong.easeOut</code> and <code>checkpoint</code> is 0.05, it will measure 5% into that ease and plot the position that would represent where the value would be if it was moving 500 units per second for the first 5% of the tween. If you notice that your tween appears to start off too fast or too slow, try adjusting the <code>checkpoint</code> higher or lower slightly. Typically 0.05 works great. 
		 * @return The amount of change (can be positive or negative based on the velocity)
		 */
		public static function calculateChange(velocity:Number, ease:Function, duration:Number, checkpoint:Number):Number {
			if (checkpoint == 0) {
				checkpoint=0.05;
			}
			return (duration * checkpoint * velocity) / ease(checkpoint, 0, 1, 1);
		}

		/**
		 * Calculates the duration (in seconds) that it would take to move from a particular start value
		 * to an end value at the given initial velocity, decelerating according to a certain easing 
		 * equation (like <code>Strong.easeOut</code>). 
		 * 
		 * @param start Starting value
		 * @param end Ending value
		 * @param velocity the initial velocity at which the starting value is changing
		 * @param ease The easing equation used for deceleration (like <code>Strong.easeOut</code> or <code>Quad.easeOut</code>).
		 * @param checkpoint A value between 0 and 1 (typically 0.05) that is used to measure an easing equation's initial strength. The goal is for the value to have moved at the initial velocity through that point in the ease. So 0.05 represents 5%. If the initial velocity is 500, for example, and the ease is <code>Strong.easeOut</code> and <code>checkpoint</code> is 0.05, it will measure 5% into that ease and plot the position that would represent where the value would be if it was moving 500 units per second for the first 5% of the tween. If you notice that your tween appears to start off too fast or too slow, try adjusting the <code>checkpoint</code> higher or lower slightly. Typically 0.05 works great. 
		 * @return The duration (in seconds) that it would take to move from the start value to the end value at the initial velocity provided, decelerating according to the ease. 
		 */
		public static function calculateDuration(start:Number, end:Number, velocity:Number, ease:Function, checkpoint:Number):Number {
			if (checkpoint == 0) {
				checkpoint=0.05;
			}
			return Math.abs( (end - start) * ease(checkpoint, 0, 1, 1) / velocity / checkpoint );
		}

		/**
		 * Analyzes various throwProps variables (like initial velocities, max/min values, 
		 * and resistance) and determines the appropriate duration. Typically it is best to 
		 * use the <code>ThrowPropsPlugin.to()</code> method for this, but <code>calculateTweenDuration()</code>
		 * could be convenient if you want to create a TweenMax instance instead of a TweenLite instance
		 * (which is what <code>throwPropsPlugin.to()</code> returns).
		 * 
		 * @param target Target object whose properties the tween affects. This can be ANY object, not just a DisplayObject. 
		 * @param vars An object containing the end values of the properties you're tweening, and it must also contain a <code>throwProps</code> object. For example, to create a tween that tweens <code>mc.x</code> at an initial velocity of 500 and <code>mc.y</code> at an initial velocity of -300 and applies a <code>resistance<code> of 80 and uses the <code>Strong.easeOut</code> easing equation and calls the method <code>tweenCompleteHandler</code> when it is done, the <code>vars</code> object would look like: <code>{throwProps:{x:500, y:-300, resistance:80}, ease:Strong.easeOut, onComplete:tweenCompleteHandler}</code>.
		 * @param maxDuration Maximum duration (in seconds)
		 * @param minDuration Minimum duration (in seconds)
		 * @param overshootTolerance sets a maximum number of seconds that can be added to the tween's duration (if necessary) to 
		 * accommodate temporarily overshooting the end value before smoothly returning to it at the end of the tween. 
		 * This can happen in situations where the initial velocity would normally cause it to exceed the <code>max</code> 
		 * or <code>min</code> values. An example of this would be in the iOS (iPhone or iPad) when you flick-scroll 
		 * so quickly that the content would shoot past the end of the scroll area. Instead of jerking to a sudden stop
		 * when it reaches the edge, the content briefly glides past the max/min position and gently eases back into place. 
		 * The larger the <code>overshootTolerance</code> the more leeway the tween has to temporarily shoot past the 
		 * max/min if necessary.
		 * @return The duration (in seconds) that the tween should use. 
		 */
		public static function calculateTweenDuration(target:Object, vars:Object, maxDuration:Number, minDuration:Number, overshootTolerance:Number):Number {
			var duration:Number=0;
			var clippedDuration:Number=9999999999;
			var throwPropsVars:Object = (vars.throwProps != undefined) ? vars.throwProps : vars;
			var ease:Function = (typeof(vars.ease) == "function") ? vars.ease : _easeOut;
			var checkpoint:Number=isNaN(throwPropsVars.checkpoint)?0.05:Number(throwPropsVars.checkpoint);
			var resistance:Number=isNaN(throwPropsVars.resistance)?defaultResistance:Number(throwPropsVars.resistance);
			var curProp:Object,curDuration:Number,curVelocity:Number,curResistance:Number,end:Number,curClippedDuration:Number;
			for (var p:String in throwPropsVars) {

				if (p != "resistance" && p != "checkpoint") {
					curProp=throwPropsVars[p];
					if (typeof(curProp) == "number") {
						curVelocity=Number(curProp);
						curDuration = (curVelocity * resistance > 0) ? curVelocity / resistance : curVelocity / -resistance;

					} else {
						curVelocity=Number(curProp.velocity)||0;
						curResistance=isNaN(curProp.resistance)?resistance:Number(curProp.resistance);
						curDuration = (curVelocity * curResistance > 0) ? curVelocity / curResistance : curVelocity / -curResistance;
						end=target[p]+calculateChange(curVelocity,ease,curDuration,checkpoint);
						if (curProp.max!=undefined&&end>Number(curProp.max)) {
							curClippedDuration=calculateDuration(target[p],curProp.max,curVelocity,ease,checkpoint);
							if (curClippedDuration + overshootTolerance < clippedDuration) {
								clippedDuration=curClippedDuration+overshootTolerance;
							}

						} else if (curProp.min != undefined && end < Number(curProp.min)) {
							curClippedDuration=calculateDuration(target[p],curProp.min,curVelocity,ease,checkpoint);
							if (curClippedDuration + overshootTolerance < clippedDuration) {
								clippedDuration=curClippedDuration+overshootTolerance;
							}
						}

						if (curClippedDuration > duration) {
							duration=curClippedDuration;
						}
					}

					if (curDuration > duration) {
						duration=curDuration;
					}

				}
			}
			if (duration > clippedDuration) {
				duration=clippedDuration;
			}
			if (duration > maxDuration) {
				return maxDuration;
			} else if (duration < minDuration) {
				return minDuration;
			}
			return duration;
		}

		/** @private **/
		override public function onInitTween(target:Object, value:*, tween:TweenLite):Boolean {
		//override public function onInitTween(target:Object, value:Object, tween:TweenLite):Boolean {
			_target=target;
			_tween=tween;
			_props=[];
			var ease:Function = (typeof(_tween.vars.ease) == "function") ? _tween.vars.ease : _easeOut;
			var checkpoint:Number=isNaN(value.checkpoint)?0.05:Number(value.checkpoint);
			var p:String,curProp:Object,velocity:Number,change1:Number,end:Number,change2:Number,duration:Number=_tween.cachedDuration,cnt:Number=0;
			for (p in value) {
				if (p != "resistance" && p != "checkpoint") {
					curProp=value[p];
					if (typeof(curProp) == "number") {
						velocity=Number(curProp);
					} else if (!isNaN(curProp.velocity)) {
						velocity=Number(curProp.velocity);
					} else {
						trace("ERROR: No velocity was defined in the throwProps tween of " + target + " property: " + p);
						velocity=0;
					}
					change1=calculateChange(velocity,ease,duration,checkpoint);
					change2=0;
					if (typeof(curProp) != "number") {
						end=_target[p]+change1;
						if (curProp.max!=undefined&&Number(curProp.max)<end) {
							change2 = (curProp.max - _target[p]) - change1;

						} else if (curProp.min != undefined && Number(curProp.min) > end) {
							change2 = (curProp.min - _target[p]) - change1;
						}
					}
					_props[cnt++]= new ThrowProp(p,Number(target[p]),change1,change2);
					this.overwriteProps[cnt]=p;
				}
			}
			return true;
		}

		/** @private **/
		private static function _easeOut(t:Number, b:Number, c:Number, d:Number):Number {
			return 1 - (t = 1 - (t / d)) * t;
		}


		override public function killProps(lookup:Object):void {
			var i:Number=_props.length;
			while (i--) {
				if (lookup[_props[i].property]!=undefined) {
					_props.splice(i, 1);
				}
			}
			super.killProps(lookup);
		}


		override public function set changeFactor(n:Number):void {

			var i:Number=_props.length
			var curProp:ThrowProp;
			if (! this.round) {
				while (i--) {
					curProp=_props[i];
					_target[curProp.property]=curProp.start+curProp.change1*n+curProp.change2*n*n;
				}
			} else {
				var val:Number;
				while (i--) {
					curProp=_props[i];
					val=curProp.start+curProp.change1*n+curProp.change2*n*n;
					_target[curProp.property] = (val >= 0) ? (val + 0.5) >> 0 : (val - 0.5) >> 0;//4 times as fast as Math.round();
				}
			}
		}

	}
}