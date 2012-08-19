Packer = require 'pypacker'
chai = require 'chai'
chai.should()

describe "Packer", ->
  it "should exist", ->
    Packer.should.exist

  it "should be creatable", ->
    (-> pack = new Packer('>HH')).should.not.throw(Error)

  it "should correctly calculate the size", ->
    packer = new Packer('>bBhHiIlLfd10s100p')
    packer.size.should.equal(144)

  describe ".unpack", ->
    it "should work", ->
      packer = new Packer('>b')
      buffer = new Buffer([0x01])
      [one] = packer.unpack(buffer)
      one.should.equal(1)

    it "should not accept a buffer with a length not equal to Packer.size", ->
      packer = new Packer('>b')
      buffer = new Buffer([0x10, 0xFF, 0xAB, 0x12])
      (-> packer.unpack(buffer)).should.throw(Error)

  describe ".unpack_from", ->
    it "should accept a buffer", ->
      buffer = new Buffer([0x00, 0x01])
      (-> new Packer('>BB').unpack_from(buffer)).should.not.throw(Error)

    it "should handle endianness correctly", ->
      buffer = new Buffer([0x00, 0x01])
      [first] = new Packer('<H').unpack_from(buffer)
      first.should.equal(256)

    it "should handle pad bytes correctly", ->
      buffer = new Buffer([0x00, 0x01, 0x00])
      [first] = new Packer('xH').unpack_from(buffer)
      first.should.equal(256)

    it "should handle bytes correctly", ->
      buffer = new Buffer([0xFF])
      [byte] = new Packer('b').unpack_from(buffer)
      byte.should.equal(-1)

    it "should handle unsigned bytes correctly", ->
      buffer = new Buffer([0xFF])
      [byte] = new Packer('B').unpack_from(buffer)
      byte.should.equal(255)

    it "should handle short ints correctly", ->
      buffer = new Buffer([0xAF, 0x01])
      [number] = new Packer('h').unpack_from(buffer)
      number.should.equal(-20735)

    it "should handle unsigned short ints correctly", ->
      buffer = new Buffer([0xAF, 0x01])
      [number] = new Packer('H').unpack_from(buffer)
      number.should.equal(44801)

    it "should handle ints correctly", ->
      buffer = new Buffer([0xAF, 0x01, 0x01, 0x01])
      [number] = new Packer('i').unpack_from(buffer)
      number.should.equal(-1358888703)

    it "should handle unsigned ints correctly", ->
      buffer = new Buffer([0xAF, 0x01, 0x01, 0x01])
      [number] = new Packer('I').unpack_from(buffer)
      number.should.equal(2936078593)

    it "should handle long ints correctly", ->
      buffer = new Buffer([0xAF, 0x01, 0x01, 0x01])
      [number] = new Packer('l').unpack_from(buffer)
      number.should.equal(-1358888703)

    it "should handle unsigned long ints correctly", ->
      buffer = new Buffer([0xAF, 0x01, 0x01, 0x01])
      [number] = new Packer('L').unpack_from(buffer)
      number.should.equal(2936078593)

    it "should handle floats correctly", ->
      buffer = new Buffer([0xCA, 0xFE, 0xBA, 0xBE])
      [number] = new Packer('f').unpack_from(buffer)
      number.should.equal(-8346975)

    it "should handle doubles correctly", ->
      buffer = new Buffer([0x3F, 0xF1, 0xC2, 0x8F, 0x5C, 0x28, 0xF5, 0xC3])
      [number] = new Packer('d').unpack_from(buffer)
      number.should.equal(1.11)

    it "should handle strings correctly", ->
      buffer = new Buffer([0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68])
      [string] = new Packer('>8s').unpack_from(buffer)
      string.should.equal('abcdefgh')

    it "should handle combos correctly", ->
      buffer = new Buffer([0x01, 0xFF])
      [first, second] = new Packer('2B').unpack_from(buffer)
      first.should.equal(1)
      second.should.equal(255)

  describe ".pack", ->
    it "should pack a string correctly", ->
      string = "abcdef"
      buffer = new Packer('6s').pack(string)
      [cmp_string] = new Packer('6s').unpack_from(buffer)
      cmp_string.should.equal(string)

    it "should pack numbers correctly", ->
      num = 100
      buffer = new Packer('bBhHiIlL').pack(num, num, num, num, num, num, num, num)
      nums = new Packer('bBhHiIlL').unpack_from(buffer)
      for x in nums
        x.should.equal(num)

    it "should throw an error when there aren't enough values", ->
      string = "abcde"
      packer = new Packer('6sH')
      (-> buffer = packer.pack(string)).should.throw(Error)

