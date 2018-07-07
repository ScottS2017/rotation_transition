import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sensors/sensors.dart';


class TransformBasedRotation extends StatefulWidget {
	@override
	_TransformBasedRotation createState() => _TransformBasedRotation();
}

class _TransformBasedRotation extends State<TransformBasedRotation> with TickerProviderStateMixin {
	AnimationController _controller;
	List<double> _gyroscopeValues;
	List<StreamSubscription<dynamic>> _streamSubscriptions =
	<StreamSubscription<dynamic>>[];
	double xAxis = 0.0;
	bool orientationIsPortrait = true;
	double angle = 0.0;

	@override
	void initState() {
		super.initState();
		SystemChrome.setPreferredOrientations([
			DeviceOrientation.portraitUp,
		]);
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

	@override
	Widget build(BuildContext context) {

		/// This is the formula to track the phone orientation
		/// It's called a "complimentary filter", as opposed to a Kalman Filter
		/// Remember that the accelerometer will always read 9.8 m/s2 straight down.
		/// Reference off of that to know which way is down and gyro from there.
		///        angle = 0.98*(angle + gyroData*dt) + 0.02*accAngle;

		double accelerometerEventX = 0.0;
		double accelerometerEventY = 0.98;
		double accelerometerEventZ = 0.0;
		accelerometerEvents.listen((AccelerometerEvent event) {
			accelerometerEventX = event.x;
			accelerometerEventY = event.y;
			accelerometerEventZ = event.z;
		});

		gyroscopeEvents.listen((GyroscopeEvent event) {
		});

		final List<String> gyroscope =
		_gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();

		return MaterialApp(
			home: Scaffold(
				appBar: AppBar(
					title: Text('Rotation Foundation'),
				),
				body: Center(
					child: Container(
						width: 350.0,
						height: 350.0,
						decoration: BoxDecoration(
							color: Colors.grey.withOpacity(0.1),
							border: Border.all(
								color: Colors.blueGrey.withOpacity(0.8),
							),
						),
						child: AppContainer(
							text: '$gyroscope',
							xAccel: accelerometerEventX,
							yAccel: accelerometerEventY,
							zAccel: accelerometerEventZ,
						),
					),
				),
			),
		);
	}
}

class AppContainer extends StatelessWidget {
	final String text;
	final double xAccel;
	final double yAccel;
	final double zAccel;

	AppContainer({
		Key key,
		this.text,
		this.xAccel,
		this.yAccel,
		this.zAccel,
	}) :
			super(key: key);

	@override
	Widget build(BuildContext context) {
		print("The passed yAccel is: " + yAccel.toString());
		return Center(
			child: SizedBox(
				width: 200.0,
				height: 200.0,
				child: Text(
					"X = " + xAccel.toString()
						+ "\nY = " + yAccel.toString()
						+ "\nZ = " + zAccel.toString()
				),
				/*child: Transform.rotate(
							angle: pi / 12.0,
							origin: Offset(100.0, 100.0),
							child: Container(
								alignment: Alignment.center,
								color: Colors.red,
								child: Text('Gyroscope: $text'),
							),
						),*/
			),
		);
	}
}