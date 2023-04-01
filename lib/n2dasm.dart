import 'dart:io';

import 'package:n2dasm/parser.dart';
import 'package:n2dasm/symbol_table.dart';

Future<List<String>> compile(File asmFile) async {
  var compiled = <String>[];
  var parser = await Parser.newParser(asmFile);
  var symbolTable = SymbolTable();
  var placeHolders = <int, String>{};
  while (parser.hasMoreCommands) {
    parser.advance();
    var codeStr = StringBuffer();
    switch (parser.commandType) {
      case CommandType.aCommand:
        var addr = int.tryParse(parser.symbol) ?? -1;
        if (addr < 0) {
          addr = symbolTable.getAddress(parser.symbol);
        }
        if (addr < 0) {
          placeHolders[parser.currentLine - 1] = parser.symbol;
        }
        compiled.add(_int2code(addr));
        break;
      case CommandType.cCommand:
        codeStr
          ..write("111")
          ..write(parser.comp)
          ..write(parser.dest)
          ..write(parser.jump);
        compiled.add(codeStr.toString());
        codeStr.clear();
        break;
      case CommandType.lCommand:
        symbolTable.addEntry(parser.symbol, parser.currentLine);
        break;
    }
  }

  var variableAddress = 16;
  placeHolders.forEach((lineIndex, symbol) {
    var val = symbolTable.getAddress(symbol);
    if (val < 0) {
      symbolTable.addEntry(symbol, variableAddress++);
    }
    compiled[lineIndex] = _int2code(symbolTable.getAddress(symbol));
  });

  return compiled;
}

String _int2code(int codeInt) => codeInt.toRadixString(2).padLeft(16, "0");
