import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sensors/sensors.dart';


class GyroBasedRotation extends StatefulWidget {
	@override
	_RotationFoundation createState() => _RotationFoundation();
}

class _RotationFoundation extends State<GyroBasedRotation> with TickerProviderStateMixin {
	AnimationController _controller;
	List<double> _gyroscopeValues;
	List<StreamSubscription<dynamic>> _streamSubscriptions =
	<StreamSubscription<dynamic>>[];

	// Rotation Calculation Logic
	double rotationX_rads = 0.0;

	@override
	void initState() {
		super.initState();
		SystemChrome.setPreferredOrientations([
			DeviceOrientation.portraitUp,
		]);
		_controller = AnimationController(
			duration: Duration(milliseconds: 1000),
			vsync: this,
		);
		_streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
			setState(() {
				_gyroscopeValues = <double>[event.x, event.y, event.z];
			});
		}));
	}

	@override
	void dispose() {
		_controller?.dispose();
		super.dispose();
	}

	double xAxis = 0.0;
	bool orientationIsPortrait = true;

	@override
	Widget build(BuildContext context) {

		final List<String> gyroscope =
		_gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();

		xAxis = xAxis + _gyroscopeValues[2];
		if (xAxis > 4.0 && orientationIsPortrait) {
			_controller.forward();
			orientationIsPortrait = false;
		} else if ( xAxis < 4.0 && ! orientationIsPortrait)
			{
				_controller.reverse();
				orientationIsPortrait = true;
			}
		print(xAxis.toString());
		print(orientationIsPortrait ? "Portrait" : "Landscape");

		return MaterialApp(
			home: Scaffold(
				appBar: AppBar(
					title: Text('Rotation Foundation'),
				),
				body: GestureDetector(
					onTap: () {
						_controller.forward();
					},
					child: Center(
						child: Container(
							width: 350.0,
							height: 350.0,
							decoration: BoxDecoration(
								color: Colors.grey.withOpacity(0.1),
								border: Border.all(
									color: Colors.blueGrey.withOpacity(0.8),
								),
							),
							child: AnimatedBox(
								controller: _controller,
								text: '$gyroscope',
							),
						),
					),
				),
			),
		);
	}
}

class AnimatedBox extends StatelessWidget {
	final String text;

	AnimatedBox({Key key, this.controller, this.text})
		:
			rotate = Tween<double>(
				begin: 0.0,
				end: 3.141 * 0.5)
				.animate(CurvedAnimation(
				parent: controller,
				curve: Interval(
					0.0,
					1.0,
					curve: Curves.ease,
				),
			),
			),
			super(key: key);

	final Animation<double> controller;
	final Animation<double> rotate;

	@override

	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: controller,
			builder: (BuildContext context, Widget child) {
				return new Center(
					child: SizedBox(
						width: 200.0,
						height: 200.0,
					  child: Transform(
					  	origin: Offset(100.0, 100.0),
					  	transform: Matrix4.identity()
					  		..rotateZ(rotate.value),
					    child: Container(
					    	alignment: Alignment.center,
					    	color: Colors.red,
					    	child: Text('Gyroscope: $text'),
					    ),
					  ),
					),
				);
			},
		);
	}
}