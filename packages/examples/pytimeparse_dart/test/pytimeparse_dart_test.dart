import "package:python_ffi_dart/python_ffi_dart.dart";
import "package:pytimeparse_dart/python_modules/src/python_modules.g.dart";
import "package:pytimeparse_dart/pytimeparse_dart.dart";
import "package:test/test.dart";

void main() async {
  await PythonFfiDart.instance.initialize(kPythonModules);

  group("Examples from Readme:", () {
    final PyTimeParse pytimeparse = PyTimeParse.import();

    setUp(() {
      // Additional setup goes here.
    });

    test("32m", () {
      expect(pytimeparse.parse("32m").asDuration, Duration(minutes: 32));
    });
    test("2h32m", () {
      expect(
        pytimeparse.parse("2h32m").asDuration,
        Duration(hours: 2, minutes: 32),
      );
    });
    test("2:04:13:02.266", () {
      expect(
        pytimeparse.parse("2:04:13:02.266").asDuration,
        Duration(
          hours: 2 * 24 + 4,
          minutes: 13,
          seconds: 2,
          milliseconds: 266,
        ),
      );
    });
  });
}
