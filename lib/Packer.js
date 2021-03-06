// Generated by CoffeeScript 1.3.3
(function() {
  var Packer, exports,
    __slice = [].slice;

  Packer = (function() {

    function Packer(format) {
      var char, endian, num_length;
      this.format = format;
      this.size = 0;
      this.endian = "BE";
      if (endian = /^(<|>|!)/.exec(format)) {
        if (endian[0] === "<") {
          this.endian = "LE";
        }
        format = this.format = format.substring(1);
      }
      this.ops = {
        x: null,
        b: ["Int8", 1],
        B: ["UInt8", 1],
        h: ["Int16" + this.endian, 2],
        H: ["UInt16" + this.endian, 2],
        i: ["Int32" + this.endian, 4],
        I: ["UInt32" + this.endian, 4],
        l: ["Int32" + this.endian, 4],
        L: ["UInt32" + this.endian, 4],
        q: null,
        Q: null,
        f: ["Float" + this.endian, 4],
        d: ["Double" + this.endian, 8],
        s: "toString",
        p: "toString"
      };
      while (format.length > 0) {
        if (num_length = /^[0-9]+/.exec(format)) {
          format = format.substring(num_length[0].length);
          num_length = parseInt(num_length[0]);
        } else {
          num_length = 1;
        }
        char = format[0];
        if (char === 's' || char === 'p' || char === 'x') {
          this.size += num_length;
        } else {
          this.size += this.ops[char][1] * num_length;
        }
        format = format.substring(1);
      }
    }

    Packer.prototype.unpack = function(buffer) {
      if (buffer.length !== this.size) {
        throw new Error("Buffer length must be the same as the formatting string length.");
      }
      return this.unpack_from(buffer);
    };

    Packer.prototype.unpack_from = function(buffer, position) {
      var char, format, num_re, op, times, val, vals, _, _i;
      if (position == null) {
        position = 0x00;
      }
      vals = [];
      format = this.format;
      while (format.length > 0) {
        times = 1;
        num_re = /^[0-9]+/;
        if (val = num_re.exec(format)) {
          times = parseInt(val[0]);
          format = format.substring(val[0].length);
        }
        char = format[0];
        format = format.substring(1);
        if (char === "s" || char === "p") {
          vals.push(buffer.toString('utf8', position, position + times));
          position += times;
        } else if (char === "x") {
          position += times;
        } else {
          op = this.ops[char];
          for (_ = _i = 0; 0 <= times ? _i < times : _i > times; _ = 0 <= times ? ++_i : --_i) {
            val = buffer["read" + op[0]](position);
            vals.push(val);
            position += op[1];
          }
        }
      }
      return vals;
    };

    Packer.prototype.pack = function() {
      var args, buffer, vals;
      vals = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      buffer = new Buffer(this.size);
      args = [buffer, 0].concat(vals);
      return this.pack_into.apply(this, args);
    };

    Packer.prototype.pack_into = function() {
      var buffer, char, format, index, offset, op, times, val, vals, _, _i;
      buffer = arguments[0], offset = arguments[1], vals = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      index = 0;
      format = this.format;
      while (format.length > 0) {
        if (index > vals.length) {
          throw new Error("Need more values.");
        }
        times = 1;
        if (val = /^[0-9]+/.exec(format)) {
          times = parseInt(val[0]);
          format = format.substring(val[0].length);
        }
        char = format[0];
        format = format.substring(1);
        if (char === "s" || char === "p") {
          buffer.write(vals[index], offset, times);
          offset += times;
        } else if (char === "x") {
          offset += times;
        } else {
          op = this.ops[char];
          for (_ = _i = 0; 0 <= times ? _i < times : _i > times; _ = 0 <= times ? ++_i : --_i) {
            buffer["write" + op[0]](vals[index], offset);
            offset += op[1];
          }
        }
        index += 1;
      }
      return buffer;
    };

    return Packer;

  })();

  exports = module.exports = Packer;

}).call(this);
