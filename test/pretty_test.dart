// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

import 'dart:io';
import 'package:args/args.dart' as args;
import 'package:propcheck/propcheck.dart';
import 'package:unittest/unittest.dart';
import 'src/factories.dart';
import 'src/tree.dart';
import 'src/algebra.dart' as algebra;

final someTree = new Tree("aaa",
    [new Tree("bbbbb",
        [new Tree("ccc", []),
         new Tree("dd", [])]),
    new Tree("eee", []),
    new Tree("ffff",
        [new Tree("gg", []),
         new Tree("hhh", []),
         new Tree("ii", [])])]);

void checkImplemMatchesModelForWidth(int width) {
  expect(
      someTree.pretty(implemFactory).render(width),
      equals(someTree.pretty(modelFactory).render(width)));
}

void testImplemMatchesModel() {
  for (int width = 0; width < 100; width++) {
    checkImplemMatchesModelForWidth(width);
  }
}

bool implemMatchesModel(algebra.Document doc) {
  final implem = doc.convert(implemFactory);
  final model = doc.convert(modelFactory);
  for (int width = 0; width < 100; width++) {
    if (implem.render(width) != model.render(width)) {
      print("unexpected $width $doc");
      print("implem: [${implem.render(width).replaceAll("\n", "\\n")}]");
      print("model: [${model.render(width).replaceAll("\n", "\\n")}]");
      return false;
    }
  }
  return true;
}

final Property implemMatchesModelProp =
    forall(algebra.documents, implemMatchesModel);



main() {
  final parser = new args.ArgParser();
  parser.addFlag('help', negatable: false);
  parser.addFlag('quiet', negatable: false);
  final flags = parser.parse(new Options().arguments);

  if (flags['help']) {
    print(parser.getUsage());
    return;
  }

  test('quickcheck implem matches model', () {
    final qc = new QuickCheck(maxSize: 300, seed: 42, quiet: flags['quiet']);
    qc.check(implemMatchesModelProp);
  });
  test('smallcheck implem matches model', () {
    final sc = new SmallCheck(depth: 4, quiet: flags['quiet']);
    sc.check(implemMatchesModelProp);
  });
  test('implem matches model for some tree', testImplemMatchesModel);
}
