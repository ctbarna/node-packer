class Packer
  constructor: (format) ->
    @format = format

    @size = 0
    @endian = "BE"
    if endian = /^(<|>|!)/.exec(format)
      if endian[0] is "<"
        @endian = "LE"
      format = @format = format.substring(1)

    # Set the operations
    @ops = {
      x: null # Pad byte
      b: ["Int8", 1] # Char (1)
      B: ["UInt8", 1] # Unsigned char (1)
      h: ["Int16#{ @endian }", 2] # Short (2)
      H: ["UInt16#{ @endian }", 2] # Unsigned short (2)
      i: ["Int32#{ @endian }", 4] # Int (4)
      I: ["UInt32#{ @endian }", 4] # Unsigned int (4)
      l: ["Int32#{ @endian }", 4] # Long (4)
      L: ["UInt32#{ @endian }", 4] # Unsigned long (4)
      q: null # Long long (8)
      Q: null # Unsigned long long (8)
      f: ["Float#{ @endian }", 4] # Float (4)
      d: ["Double#{ @endian }", 8] # Double (8)
      s: "toString" # String
      p: "toString" # String
    }

    while format.length > 0
      if num_length = /^[0-9]+/.exec(format)
        format = format.substring(num_length[0].length)
        num_length = parseInt(num_length[0])
      else
        num_length = 1

      char = format[0]

      if char is 's' or char is 'p' or char is 'x'
        @size += num_length
      else
        @size += @ops[char][1] * num_length
      format = format.substring(1)

  unpack: (buffer) ->
    unless buffer.length is @size
      throw new Error("Buffer length must be the same as the formatting string length.")

    @unpack_from(buffer)

  unpack_from: (buffer, position=0x00) ->
    vals = []
    format = @format

    while format.length > 0
      times = 1
      num_re = /^[0-9]+/
      if val = num_re.exec(format)
        times = parseInt(val[0])

        format = format.substring(val[0].length)

      char = format[0]
      format = format.substring(1)

      if char is "s" or char is "p"
        vals.push(buffer.toString('utf8', position, position+times))
        position += times
      else if char is "x"
        position += times
      else
        op = @ops[char]
        for _ in [0...times]

          val = buffer["read#{ op[0] }"](position)
          vals.push(val)
          position += op[1]

    vals

  pack: (vals...) ->
    buffer = new Buffer(@size)
    args = [buffer, 0].concat(vals)

    @pack_into.apply(@, args)


  pack_into: (buffer, offset, vals...) ->
    index = 0
    format = @format

    while format.length > 0
      if index > vals.length
        throw new Error("Need more values.")
      times = 1
      if val = /^[0-9]+/.exec(format)
        times = parseInt(val[0])
        format = format.substring(val[0].length)

      char = format[0]
      format = format.substring(1)

      if char is "s" or char is "p"
        buffer.write(vals[index], offset, times)
        offset += times
      else if char is "x"
        offset += times
      else
        op = @ops[char]
        for _ in [0...times]
          buffer["write#{ op[0] }"](vals[index], offset)
          offset += op[1]
      index += 1

    buffer

exports = module.exports = Packer
