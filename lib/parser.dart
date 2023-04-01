import 'dart:io';

import 'package:n2dasm/coder.dart';

class Parser {
  late File asmFile;
  late List<String> lines;
  var _currentLine = -1, _currentValidLine = 0;
  late CommandType _commandType;
  late String _symbol, _dest, _jump, _comp;

  Parser._();

  static Future<Parser> newParser(File asmFile) async {
    var instance = Parser._();
    instance.asmFile = asmFile;
    instance.lines = await asmFile.readAsLines();
    return instance;
  }

  bool get hasMoreCommands => _currentLine < lines.length - 1;

  advance() {
    do {
      _currentLine++;
    } while (hasMoreCommands && !_validateLine(lines[_currentLine]));
    _currentValidLine++;

    var line = _removeSpaceAndTrailingComment(lines[_currentLine]);
    _commandType = line.startsWith("@")
        ? CommandType.aCommand
        : (line.startsWith("(") ? CommandType.lCommand : CommandType.cCommand);
    switch (_commandType) {
      case CommandType.aCommand:
        _symbol = line.substring(1);
        break;
      case CommandType.cCommand:
        List<String> parts;

        if (line.contains("=")) {
          parts = line.split("=");
          var dest = parts.first;
          line = parts.last;
          _dest = Coder.dest(dest);
        } else {
          _dest = "000";
        }

        if (line.contains(";")) {
          parts = line.split(";");
          line = parts.first;
          _jump = Coder.jump(parts.last);
        } else {
          _jump = "000";
        }
        _comp = Coder.comp(line);
        break;
      case CommandType.lCommand:
        _symbol = line.substring(1, line.length - 1);
        _currentValidLine--;
        break;
    }
  }

  CommandType get commandType => _commandType;

  int get currentLine => _currentValidLine;

  String get symbol => _symbol;

  String get dest => _dest;

  String get comp => _comp;

  String get jump => _jump;

  bool _validateLine(String line) {
    line = line.trim();
    return line.isNotEmpty && !line.startsWith("//");
  }

  String _removeSpaceAndTrailingComment(String line) =>
      line.split("//").first.trim().split(" ").join("");
}

enum CommandType { aCommand, cCommand, lCommand }
