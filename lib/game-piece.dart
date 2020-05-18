import 'package:flutter_puzzle_game_demo/controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class GamePieceModel extends ChangeNotifier {

	GamePieceModel({ this.value, this.position }) {
		prev = initialPoint(this.initialDirection);
	}

	int value;
	Point position;
	Point prev;

	Direction get initialDirection => Controller.lastDirection;

	Point initialPoint(Direction direction) {

		switch (initialDirection) {

			case Direction.UP:
				return Point(this.position.x, 6);

			case Direction.DOWN:
				return Point(this.position.x, 0);

			case Direction.LEFT:
				return Point(6, this.position.y);
			
			case Direction.RIGHT:
				return Point(0, this.position.y);

			case Direction.NONE:
				break;
		}

		return Point(0, 0);
	}

	void move(Point to) {

		this.prev = position;
		this.position = to;
		notifyListeners();
	}
}

class GamePieceView extends AnimatedWidget {

	GamePieceView({Key key, this.model, controller}) :
	
	 	x = Tween<double>( begin: model.prev.x.toDouble(),  end: model.position.x.toDouble(), )
		 	.animate( CurvedAnimation( parent: controller, curve: Interval( 0.0, 0.100,  curve: Curves.ease, ))),

		y = Tween<double>( begin: model.prev.y.toDouble(),  end: model.position.y.toDouble(), )
			.animate( CurvedAnimation( parent: controller, curve: Interval( 0.0, 0.100,  curve: Curves.ease, ))),

		super(key: key, listenable: controller);

	final GamePieceModel model;
	AnimationController get controller => listenable;

	final Animation<double> x;
	final Animation<double> y;

	final List<Color> colors = const [
		Colors.red,
		Colors.orange,
		Colors.yellow,
		Colors.green,
		Colors.blue,
		Colors.indigo,
		Colors.purple
	];

	Widget build(BuildContext context) {

		model.prev = model.position;

		Size size = MediaQuery.of(context).size;
		double itemSize = size.width / 7;

		return Align(
			alignment: FractionalOffset(x.value/6, y.value/6),
			child: Container(
				constraints: BoxConstraints(maxHeight: itemSize, maxWidth: itemSize),
				height: itemSize,
				width: itemSize,
				child: Align( 
					alignment: Alignment.center,
					child: Container(
						height: itemSize * .7,
						width: itemSize * .7,
						padding: EdgeInsets.all(3),
						decoration: BoxDecoration(
							color: colors[model.value].withOpacity(0.1),
							border: Border.all(color: colors[model.value], width: 1),
							borderRadius: BorderRadius.circular(itemSize / 2)
						)
					)
				)
			)
		);
	}
}

class GamePiece extends StatefulWidget {

	GamePiece({ Key key, @required this.model }) : super(key: key);

	final GamePieceModel model;

	int get value => model.value;
	Point get position => model.position;
	void move(Point to) => model.move(to);

	@override
	_GamePieceState createState() => _GamePieceState();
}

class _GamePieceState extends State<GamePiece> with TickerProviderStateMixin {

	_GamePieceState();

	AnimationController _controller;

	@override
	void initState() {

		super.initState();
		_controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
	}

	@override
	void dispose() {

		super.dispose();
		_controller.dispose();
	}

	@override
	Widget build(BuildContext context) {
		
		return ChangeNotifierProvider.value(
			value: widget.model,
			child: Consumer<GamePieceModel>(
				builder: (context, model, child) {

					try {
						_controller.reset();
						_controller.forward();
					} 
					on TickerCanceled {}
				
					return GamePieceView(model: model, controller: _controller);
				}
			)
		);
	}
}