import 'package:flutter/material.dart';
import 'package:sketcher/models/sketch_tool.dart';
import 'package:sketcher/models/stroke.dart';
import 'package:sketcher/models/stroke_style.dart';
import 'package:sketcher/ui/operations/operation.dart';
import 'package:sketcher/ui/sketch_layer.dart';
import 'package:sketcher/ui/static_painter.dart';

class SketchController extends ChangeNotifier {
  final _layers = <SketchLayer>[];
  final _undoStack = <Operation>[];
  final _redoStack = <Operation>[];
  SketchTool _activeTool;
  StrokeStyle _pencilStyle;
  StrokeStyle _highlighterStyle;
  int _lastLayerId = 0;

  List<SketchLayer> get layers => _layers;

  SketchController({
    StrokeStyle pencilStyle,
    StrokeStyle highlighterStyle,
  }) {
    _pencilStyle = pencilStyle ?? StrokeStyle(1, Colors.black, 2);
    _highlighterStyle = highlighterStyle ?? StrokeStyle(0.3, Colors.black, 18);
  }

  int get nextLayerId => ++_lastLayerId;

  SketchTool get activeTool => _activeTool;

  StrokeStyle get pencilConfig => _pencilStyle;

  StrokeStyle get highlightConfig => _highlighterStyle;

  bool get isRedoAvailable => _redoStack.isNotEmpty;

  bool get isUndoAvailable => _undoStack.isNotEmpty;

  void setActiveTool(SketchTool tool) {
    _activeTool = tool;
    notifyListeners();
  }

  void undo() {
    final operation = _undoStack.removeLast();
    _redoStack.add(operation);
    operation.undo(this);
    //   if (reactivePainter.strokes.isEmpty) {
    //     final staticPainter = staticPainters.removeLast();
    //     final kanjiStokes = staticPainter.strokes;
    //     _redoQueue.add(kanjiStokes.removeLast());
    //     reactivePainter.strokes.addAll(kanjiStokes);
    //   } else {
    //     _redoQueue.add(reactivePainter.strokes.removeLast());
    //   }
    //   notifyListeners();
  }

  void redo() {
    final operation = _redoStack.removeLast();
    _undoStack.add(operation);
    operation.redo(this);
    //   if (_redoQueue.isNotEmpty) {
    //     reactivePainter.strokes.add(_redoQueue.removeLast());
    //     notifyListeners();
    //   }
  }

  void setActiveColor(Color color) {
    activeToolStyle = activeToolStyle?.copy(color: color);
  }

  void setActiveWeight(double weight) {
    activeToolStyle = activeToolStyle?.copy(weight: weight);
  }

  // ignore: missing_return
  StrokeStyle get activeToolStyle {
    switch (_activeTool) {
      case SketchTool.None:
      case SketchTool.Eraser:
        return null;
      case SketchTool.Pencil:
        return _pencilStyle;
      case SketchTool.Highlighter:
        return _highlighterStyle;
    }
  }

  set activeToolStyle(StrokeStyle config) {
    switch (_activeTool) {
      case SketchTool.None:
      case SketchTool.Eraser:
        break;
      case SketchTool.Pencil:
        _pencilStyle = config;
        break;
      case SketchTool.Highlighter:
        _highlighterStyle = config;
        break;
    }
    notifyListeners();
  }

  void notify() {
    print("notify()");
    notifyListeners();
  }

  // bool commitStrokes() {
  //   _redoQueue.clear();
  //   if (reactivePainter.strokes.isNotEmpty) {
  //     staticPainters.add(StaticPainter(List.of(reactivePainter.strokes)));
  //     reactivePainter.strokes.clear();
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  void init(List<Stroke> strokes) {
    final layer = SketchLayer(nextLayerId, StaticPainter(strokes));
    layers.add(layer);
    notifyListeners();
  }

  void commitOperation(Operation operation) {
    _undoStack.add(operation);
    _redoStack.clear();
    operation.redo(this);
  }
}
