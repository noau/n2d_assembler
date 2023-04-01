import 'dart:io';

import 'package:n2dasm/n2dasm.dart' as n2dasm;

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print("Argument <File Name> missing.");
    return;
  }
  var fullFilename = arguments.first.split("\\").last;
  if (!fullFilename.endsWith(".asm")) {
    print("Argument <File Name> must end with <.asm>");
    return;
  }

  var filename = fullFilename.split(".").first;
  var asmFile = File(arguments.first);
  var hackFile = File("$filename.hack");
  hackFile.create();

  n2dasm.compile(asmFile).then((compiled) {
    hackFile.writeAsString(
      compiled.map((codeLine) => codeLine.toString()).toList().join("\n"),
    );
    print("Compile Finished.");
  });
}
