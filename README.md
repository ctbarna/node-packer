# PyPacker
`pypacker` is a binary packer and unpacker inspired by Python's [struct
library](http://docs.python.org/library/struct.html) for node.js.
Currently, it packs/unpacks to and from a Buffer object. When unpacking,
an array is returned with the requested values.

Interfacing is exactly the same as the Python struct python class except
there are no 8-byte integers.

## Installation
`npm install pypacker`

## Usage
```JavaScript
Packer = require('pypacker');
var unpack_array = new Packer('>H')
  .unpack(new Buffer([0x00, 0x01]));
// unpack_array will be an array containing [1]

var packed_buffer = new Packer('>H')
  .pack(1);
// packed_buffer will be a Buffer of length 2 containing 00 01
```
