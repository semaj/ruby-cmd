require 'digest/sha2'

def sha256(str)
  (Digest::SHA256.new << str).digest
end

def little_endian_bytestr(*args)
  args.pack(('L' * args.size) + '<')
end

def hex_str_to_hex_bytestr(str)
  [str].pack('H*')
end

def hex_bytestr_to_hex_str(bytestr)
  bytestr.unpack('H*').first
end

def first_byte(bytes)
  bytes.to_s(16)[0..1].hex # AKA `bytes >> (4 * ((# OF BYTES) - 2))`
end

def rest_bytes(bytes)
  bytes.to_s(16)[2..-1].hex # AKA bytes >> 0xffffff (# of fs is determined by (# bytes - 2))
end

def zero_padded_256bit_str(num)
  '%064x' % num
end

version = 2
prev_block = "000000000000000117c80378b8da0e33559b5997f2ad55e2f7d18ec1975b9717"
merkle_root = "871714dcbae6c8193a2bb9b2a69fe1c0440399f38d94b3a0f1b447275a29978a"
time = 1392872245 # 2014-02-20 04:57:25
bits = 0x19015f53
 
# https://en.bitcoin.it/wiki/Difficulty
target_hexstr = zero_padded_256bit_str(
  rest_bytes(bits) * (2 ** (8 * (first_byte(bits) - 3))) # arbitrary formula
) 
target_bytestr = hex_str_to_hex_bytestr(target_hexstr)
puts target_hexstr

(0x0..0x1000).each do |nonce|
  header = little_endian_bytestr(version) +
           hex_str_to_hex_bytestr(prev_block).reverse +
           hex_str_to_hex_bytestr(merkle_root).reverse +
           little_endian_bytestr(time, bits, nonce)

  hash = sha256(sha256(header))
  reversed_hash = hash.reverse
  #puts nonce.to_s + ' ' + hex_bytestr_to_hex_str(reversed_hash)
  if reversed_hash < target_bytestr
    puts 'SUCCESS'
  end
end

