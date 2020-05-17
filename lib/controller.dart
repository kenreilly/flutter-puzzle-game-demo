import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_puzzle_game_demo/game-piece.dart';
import 'package:flutter_puzzle_game_demo/score.dart';

enum Direction { UP, DOWN, LEFT, RIGHT, NONE }

class Controller {

	static ScoreModel score = ScoreModel();

	static Random rnd = Random();

	static List<GamePiece> _pieces = [];
	static Map<Point, GamePiece> index = {};

	static get pieces => _pieces;

	static StreamController bus = StreamController.broadcast();
	static StreamSubscription listen(Function handler) => bus.stream.listen(handler);

	static dispose() => bus.close();

	static Direction lastDirection = Direction.RIGHT;

	static Direction parse(Offset offset) {

		if (offset.dx < 0 && offset.dx.abs() > offset.dy.abs()) return Direction.LEFT;		
		if (offset.dx > 0 && offset.dx.abs() > offset.dy.abs()) return Direction.RIGHT;
		if (offset.dy < 0 && offset.dy.abs() > offset.dx.abs()) return Direction.UP;
		if (offset.dy > 0 && offset.dy.abs() > offset.dx.abs()) return Direction.DOWN;
		return Direction.NONE;
	}

	static addPiece(GamePiece piece) {

		_pieces.add(piece);
		index[piece.position] = piece;
	}

	static removePiece(GamePiece piece) {

		_pieces.remove(piece);
		index[piece.position] = null;
	}

	static void on(Offset offset) {

		lastDirection = parse(offset);
		process(lastDirection);

		bus.add(null);
		if (_pieces.length > 48) { start(); } // Game Over :/

		Point p;
		while (p == null || index.containsKey(p)) { p = Point(rnd.nextInt(6), rnd.nextInt(6)); }
		
		addPiece(GamePiece(model: GamePieceModel(position: p, value: 0)));
	}

	static void process(Direction direction) {
		
		switch (direction) {

			case (Direction.UP):
				return scan(0, 7, 1, Axis.vertical);
				
			case (Direction.DOWN):
				return scan(6, -1, -1, Axis.vertical);

			case (Direction.LEFT):
				return scan(0, 7, 1, Axis.horizontal);

			case (Direction.RIGHT):
				return scan(6, -1, -1, Axis.horizontal);

			default:
				break;
		}
	}
	
	static scan(int start, int end, int op, Axis axis) {

		for (int j = start; j != end; j += op) {
			for (int k = 0; k != 7; k++) {
				
				Point p = axis == Axis.vertical ? Point(k, j) : Point(j, k);
				if (index.containsKey(p)) { check(start, op, axis, index[p]); }
			}
		}
	}

	static void check(int start, int op, Axis axis, GamePiece piece) {

		int target = (axis == Axis.vertical) ? piece.position.y : piece.position.x;
		for (var n = target - op; n != start - op; n -= op) {

			Point lookup = (axis == Axis.vertical) 
				? Point(piece.position.x, n) 
				: Point(n, piece.position.y);

			if (!index.containsKey(lookup)) { target -= op; }
			else if (index[lookup].value == piece.value) { return merge(piece, index[lookup]); }
			else { break; }
		}

		Point destination = (axis == Axis.vertical) 
			? Point(piece.position.x, target) 
			: Point(target, piece.position.y);

		if (destination != piece.position) { relocate(piece, destination); }
	}

	static void merge(GamePiece source, GamePiece target) {

		if (source.value == 6) {

			index.remove(source.position);
			index.remove(target.position);
			_pieces.remove(source);
			_pieces.remove(target);
			score.value += source.model.value * 100;
			return;
		}

		source.model.value += 1;
		index.remove(target.position);
		_pieces.remove(target);
		relocate(source, target.position);
		score.value += source.model.value * 10;
	}

	static void relocate(GamePiece piece, Point destination) {

		index.remove(piece.position);
		piece.move(destination);
		index[piece.position] = piece;
	}

	static void start() {

		_pieces = [];
		index = {};
		on(Offset(1,0));
	}
}