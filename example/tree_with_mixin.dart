// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)
//         Rafael Brandão (rafa.bra@gmail.com)

import 'package:pretty/pretty_extras.dart';

class Tree extends Object with Pretty {
  final String name;
  final List<Tree> children;

  Tree(this.name, this.children);

  Document get pretty => prettyTree(name, children);

  //Identation defaults to 2. Clients could overwrite like this
  //Document get pretty => prettyTree(name, children, identation: 4);
}

final Tree someTree = new Tree("aaa",
    [new Tree("bbbbb",
        [new Tree("ccc", []),
         new Tree("dd", [])]),
    new Tree("eee", []),
    new Tree("ffff",
        [new Tree("gg", []),
         new Tree("hhh", []),
         new Tree("ii", [])])]);

void main() {
  for (int width in [100, 50, 20, 10]) {
    print(someTree.render(width));
    print("");
  }
}
