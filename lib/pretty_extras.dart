// Copyright (c) 2013, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Rafael de Andrade (rafa.bra@gmail.com)

library pretty_extras;

import 'pretty.dart';
export 'pretty.dart';


const int _DEFAULT_INDENTATION = 2;

final Document space = text(' '),
               comma = text(','),
               openingBrace = text('{'),
               closingBrace = text('}'),
               emptyMap = openingBrace + closingBrace,
               openingBracket = text('['),
               closingBracket = text(']'),
               emptyList = openingBracket + closingBracket;


Iterable<Document> _joinMap(Map<String, Document> map) {
  List<Document> result = <Document>[];
  map.forEach((String key, Document value) {
    result.add(text('$key: ') + value);
  });
  return result;
}


Document _join(Iterable<Document> iterable) =>
  (iterable != null && !iterable.isEmpty)
      ? (comma + line).join(iterable.map((d) => d.group))
      : empty;


Document _enclose(Iterable<Document> iterable, Document open, Document close,
              Document emptyValue, int indentation) =>
  ((iterable != null && !iterable.isEmpty)
      ? open + (line + _join(iterable)).nest(indentation) + line +  close
      : emptyValue).group;


Document _prettyMap(Map<String, Document> map, int indentation) =>
  _enclose(_joinMap(map), openingBrace, closingBrace, emptyMap, indentation);


Document _prettyList(Iterable<Document> list, int indentation) =>
  _enclose(list, openingBracket, closingBracket, emptyList, indentation);


typedef Document ToDocumentFunction();

Document _mapToDocument(Object value, int indentation) {

  if (value is Document) {
    return value;
  }
  if(value is Pretty) {
    return (value as Pretty).pretty;
  }
  if(value is ToDocumentFunction) {
    return (value as ToDocumentFunction)();
  }
  if (value is Iterable) {
    final documentList = (value as Iterable).map((v) =>
        _mapToDocument(v, indentation)
    );
    return _prettyList(documentList, indentation);
  }
  if (value is Map<String, Object>) {
    final map = value as Map<String, Object>,
          values = map.values.map((v) => _mapToDocument(v, indentation)),
          documentMap = new Map.fromIterables(map.keys, values);

    return _prettyMap(documentMap, indentation);
  }
  return value != null ? text(value.toString()) : empty;
}


Document prettyMap(Map<String, Object> map,
                  {int indentation: _DEFAULT_INDENTATION}) =>
  _mapToDocument(map, indentation);


Document prettyList(Iterable list,
                    {int indentation: _DEFAULT_INDENTATION}) =>
  _mapToDocument(list, indentation);


Document prettyTree(String name, Iterable<Document> iterable,
                    {int indentation: _DEFAULT_INDENTATION}) =>
  text(name) + _enclose(iterable,
      (space + openingBrace), closingBrace, empty, indentation);


abstract class Pretty {
  Document get pretty;

  Document get group => pretty.group;

  String render([int width = 0]) => group.render(width);

  String toString() => render();
}
