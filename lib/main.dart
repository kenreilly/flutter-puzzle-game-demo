import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_puzzle_game_demo/game-board.dart';
import 'package:flutter_puzzle_game_demo/score.dart';
import 'package:flutter_puzzle_game_demo/controller.dart';

void main() {

	WidgetsFlutterBinding.ensureInitialized();
	SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
	runApp(MyApp());
}

class MyApp extends StatelessWidget {

	final String _title = "Flutter Puzzle Game Demo";

	@override
	Widget build(BuildContext context) {

		return MaterialApp(
			title: _title,
			theme: ThemeData.dark(),
			home: Scaffold(
				appBar: AppBar(title: Center(child: Text(_title))),
				body: Column(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: [
						ScoreView(),
						GameBoard(),
						Padding( 
							padding: EdgeInsets.only(bottom: 4),
							child: SizedBox(
								height: 64,
								width: double.infinity,
								child: Container(
									margin: EdgeInsets.all(8),
									decoration: BoxDecoration(
										border: Border.all(color: Colors.white.withOpacity(0.2)),
										borderRadius: BorderRadius.circular(8)
									),
									child: MaterialButton(
										color: Colors.grey.withOpacity(0.2),
										onPressed: Controller.start,
										child: Text('start')
									)
								)
							)
						)
					]
				),
			)
		);
	}
}
