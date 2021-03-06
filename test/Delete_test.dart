//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Feb 22, 2013  04:33:48 PM
// Author: henrichen

import 'dart:async';
import 'dart:convert' show UTF8;
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:memcached_client/memcached_client.dart';
import 'MemcachedTestUtil.dart' as m;

//delete key3
testDelete1(MemcachedClient client) async {
  expect(await client.set('key3', UTF8.encode('va13')), true);
  expect(await client.delete('key3'), true);
}

//delete inexist key3; should throw NOT_FOUND
void testDelete2(MemcachedClient client) {
  expect(client.delete('key3'), throwsA(equals(OPStatus.KEY_NOT_FOUND)));
}

void main() {
  setupLogger(level: Level.ALL);
  group('TextDeleteTest:', () {
    MemcachedClient client;
    setUp(() async {
      client = await m.prepareTextClient();
    });
    tearDown(() => client.close());
    test('TestDelete1', () => testDelete1(client));
    test('TestDelete2', () => testDelete2(client));
  });
  group('BinaryDeleteTest:', () {
    MemcachedClient client;
    setUp(() async {
      client = await m.prepareBinaryClient();
    });
    tearDown(() => client.close());
    test('TestDelete1', () => testDelete1(client));
    test('TestDelete2', () => testDelete2(client));
  });
}
