# basic_dataclass

This example shows how to import a Python module which defines a custom class.

The console app creates a `Person` object in Dart (defined as a Python dataclass) and passes it to
the Python module. It can then be moved around, by calling a method on the class instance. The
current position is printed to the console in Dart, but the String is generated by the Python
module.

## Table of contents

1. [Usage (the final product)](#usage-the-final-product)
2. [Prerequisites](#prerequisites)
3. [Including the Python module source](#including-the-python-module-source)
4. [Adding the Python module to the Dart project](#adding-the-python-module-to-the-dart-project)
    1. [List the Python module as a dependency in `pubspec.yaml`](#1-list-the-python-module-as-a-dependency-in-pubspecyaml)
    2. [Run `dartpip bundle`](#2-run-dartpip-bundle)
    3. [Creating the Class-definition in Dart](#3-creating-the-class-definition-in-dart)
5. [Using the Python module in Dart](#using-the-python-module-in-dart)
6. [Testing the Python module](#testing-the-python-module)
7. [Next step](#next-step)

## Usage (the final product)

```shell
$ dart bin/basic_dataclass.dart MyPlayerName
<use W,A,S,D to move, press q to quit>
MyPlayerName @ (0, 0)
> w
MyPlayerName @ (0, -1)
> d
MyPlayerName @ (1, -1)
> q
```

## Prerequisites

* The [dartpip cli](https://pub.dev/packages/dartpip) should be installed (either globally or as
  dev-dependency in this Dart project).

## Including the Python module source

The Python module source is a single file `basic_dataclass.py` in the `python-modules` directory. It
could be located in any other directory, even outside the project root. This will result in a module
named `basic_dataclass` that we will be importing from Dart.

```py
# python-modules/basic_dataclass.py

from dataclasses import dataclass

@dataclass
class Person:
    name: str
    x: int = 0
    y: int = 0

    def move(self, dx: int, dy: int):
        self.x += dx
        self.y += dy

    def __str__(self):
        return f"{self.name} @ ({self.x}, {self.y})"
```

## Adding the Python module to the Dart project

### 1. List the Python module as a dependency in `pubspec.yaml`

```yaml
# pubspec.yaml

python_ffi:
  modules:
    basic_dataclass: any
```

### 2. Run `dartpip bundle`

The following command should be run from the root of your Dart project. It will bundle the Python
module source into the Dart project.

```shell
$ dartpip bundle -r . -m python-modules
```

The value behind the `-m` option is the path to the directory containing the Python module source.
The value behind the `-r` option is the root of the Dart project. Both are relative to the current
working directory.

### 3. Creating the Class-definition in Dart

Each Python class needs its corresponding Dart Class-definition:

```dart
// lib/basic_dataclass.dart

import "package:python_ffi_dart/python_ffi_dart.dart";

final class Person extends PythonClass {
  factory Person(String name) =>
      PythonFfiDart.instance.importClass(
        "basic_dataclass",
        "Person",
        Person.from,
        <Object?>[name],
      );

  Person.from(super.pythonClass) : super.from();

  void move(int dx, int dy) => getFunction("move").call(<Object?>[dx, dy]);
}
```

*Note: We don't need to map the Dart `toString` method to the Python `__str__` method. This is
handled automatically. Simply printing the Dart instance will invoke the Python `__str__` method.*

## Using the Python module in Dart

First we need to initialize the Python runtime once. This is done by calling the `initialize` method
on the `PythonFfiDart.instance` singleton. The `initialize` method takes the encoded Python modules
added via `dartpip bundle`.

We can then instantiate a `Person` object in Dart. It will be automatically backed by Python memory.
Then we can call the `move` method on the Dart instance, which will call the corresponding Python
method. Printing the Dart instance will invoke the Python `__str__` method.

```dart
// bin/basic_dataclass.dart

import "dart:io";

import "package:basic_dataclass/basic_dataclass.dart";
import "package:basic_dataclass/python_modules/src/python_modules.g.dart";
import "package:python_ffi_dart/python_ffi_dart.dart";

void main(List<String> arguments) async {
  await PythonFfiDart.instance.initialize(kPythonModules);

  final Person person = Person(arguments.first);
  print("<use W,A,S,D to move, press q to quit>");
  String? input;
  do {
    print(person);
    stdout.write("> ");
    input = stdin.readLineSync();
    switch (input) {
      case "w":
        person.move(0, -1);
        break;
      case "a":
        person.move(-1, 0);
        break;
      case "s":
        person.move(0, 1);
        break;
      case "d":
        person.move(1, 0);
        break;
    }
  } while (input != "q");
}
```

## Testing the Python module

We can write Dart tests to test our Python module. Again we need to make sure to initialize the
Python runtime once first. Then we can import the Python module and test its function:

```dart
// test/basic_dataclass_test.dart

import "package:basic_dataclass/basic_dataclass.dart";
import "package:basic_dataclass/python_modules/src/python_modules.g.dart";
import "package:python_ffi_dart/python_ffi_dart.dart";
import "package:test/test.dart";

void main() async {
  await PythonFfiDart.instance.initialize(kPythonModules);

  late Person person;

  setUp(() => person = Person("John"));

  test("move W", () {
    expect((person..move(0, -1)).toString(), "John @ (0, -1)");
  });

  test("move A", () {
    expect((person..move(-1, 0)).toString(), "John @ (-1, 0)");
  });

  test("move S", () {
    expect((person..move(0, 1)).toString(), "John @ (0, 1)");
  });

  test("move D", () {
    expect((person..move(1, 0)).toString(), "John @ (1, 0)");
  });
}
```

## Next step

Importing a Python module from pypi. See [pytimeparse_dart](../pytimeparse_dart/README.md).
