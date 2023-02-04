// The MIT License (MIT)
//
// Copyright (c) 2023 foxsofter
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

const int _ampersand = 0x26;
const int _equals = 0x3d;

extension ThrioUri on String {
  static List<String> _createList() => <String>[];

  Map<String, List<String>> get rawQueryParametersAll {
    if (isEmpty) {
      return const <String, List<String>>{};
    }
    final result = <String, List<String>>{};
    var i = 0;
    var start = 0;
    var equalsIndex = -1;

    void parsePair(final int start, final int equalsIndex, final int end) {
      String key;
      String value;
      if (start == end) {
        return;
      }
      if (equalsIndex < 0) {
        key = substring(start, end);
        value = '';
      } else {
        key = substring(start, equalsIndex);
        value = substring(equalsIndex + 1, end);
      }
      result.putIfAbsent(key, _createList).add(value);
    }

    while (i < length) {
      final char = codeUnitAt(i);
      if (char == _equals) {
        if (equalsIndex < 0) {
          equalsIndex = i;
        }
      } else if (char == _ampersand) {
        parsePair(start, equalsIndex, i);
        start = i + 1;
        equalsIndex = -1;
      }
      i++;
    }
    parsePair(start, equalsIndex, i);
    return Map<String, List<String>>.unmodifiable(result);
  }

  Map<String, String> get rawQueryParameters =>
      split('&').fold({}, (final map, final it) {
        final index = it.indexOf('=');
        if (index == -1) {
          if (it != '') {
            map[it] = '';
          }
        } else if (index != 0) {
          final key = it.substring(0, index);
          final value = it.substring(index + 1);
          map[key] = value;
        }
        return map;
      });
}
