require 'bindata'

class Hexels < BinData::Record
  endian :little
  string :header, :length => 7
  string :version, :length => 1
  int32 :width
  int32 :height
  # array :cells, :length => (lambda { width * height }) do
  array :cells, :length => 16, :initial_length => 16 do
    endian :little
    uint8 :r
    uint8 :g
    uint8 :b
    uint8 :a
    int64 :filler
  end
end

def parse(file)
  io = File.open(file, 'r')
  hexels = Hexels.read(io)
  puts "Header: #{hexels.header}"
  puts "Version: #{hexels.version.ord}"
  puts "Dimensions: #{hexels.width} x #{hexels.height}"
  hexels.cells.each do |cell|
    puts " Cell #{cell.r} #{cell.g} #{cell.b} #{cell.a}"
    # puts " #{cell.filler}"
  end
end

parse(ARGV[0] || '/Users/chubas/Dropbox/Hexel/script/simple.hxl')