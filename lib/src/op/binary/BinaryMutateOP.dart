//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Feb 27, 2013  09:34:10 AM
// Author: hernichen

part of memcached_client;

/** A Mutate Operation of binary protocol */
class BinaryMutateOP extends SingleKeyOP implements MutateOP {
  final Completer<int>
      _cmpl; //completer to complete the future of this operation

  Future<int> get future => _cmpl.future;

  BinaryMutateOP(OPType type, String key, int by, int def, int exp)
      : _cmpl = new Completer(),
        super(key) {
    _cmd = _prepareMutateCommand(type, key, by, def, exp);
  }

  @override
  int handleData(List<int> line) {
    //_logger.finest("BinaryMutateOpData: $this, $line\n");
    if (_status != 0)
      _cmpl.completeError(new OPStatus.wrap(OPStatus.valueOf(_status), this));
    else {
      _cmpl.complete(bytesToInt64(line, 0));
    }

    return _HANDLE_COMPLETE;
  }

  /** Prepare a store command.
   */
  static const _req_extralen = 20;
  List<int> _prepareMutateCommand(
      OPType type, String key, int by, int def, int exp) {
    List<int> keybytes = UTF8.encode(key);
    int keylen = keybytes.length;
    int valuelen = 0;
    int bodylen = _req_extralen + keylen + valuelen;

    Uint8List cmd = new Uint8List(24 + bodylen);
    //0, 1 byte: Magic byte of request
    cmd[0] = _MAGIC_REQ;
    //1, 1 byte: Opcode
    cmd[1] = type.ordinal;
    //2, 2 bytes: Key length
    copyList(int16ToBytes(keylen), 0, cmd, 2, 2);
    //4, 2 bytes: extra length
    copyList(int8ToBytes(_req_extralen), 0, cmd, 4, 1);
    //6, 2 bytes: vBucket id
    //8, 4 bytes: total body length
    copyList(int32ToBytes(bodylen), 0, cmd, 8, 4);
    //12, 4 bytes: Opaque
    //16, 8 bytes: CAS
    //24, _req_extralen: extra
    //amount to add / subtract
    copyList(int64ToBytes(by), 0, cmd, 24, 8);
    //initial value if document did not exist
    if (def != null && 0 != def) copyList(int64ToBytes(def), 0, cmd, 24 + 8, 8);
    //set experiation to 0xffffffff so inexists will signal NOT_FOUND error
    if (exp != null && 0 != exp)
      copyList(int32ToBytes(exp), 0, cmd, 24 + 16, 4);
    //24+_req_extralen, keylen: key
    copyList(keybytes, 0, cmd, 24 + _req_extralen, keylen);
    //24+_req_extralen+keylen, valuelen
    //_logger.finest("_prepareMutateCommand:$cmd\n");
    return cmd;
  }
}
