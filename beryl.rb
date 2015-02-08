require 'bundler/setup'
require 'bindata'

class RGBA < BinData::Record
  endian :little
  uint8 :r
  uint8 :g
  uint8 :b
  uint8 :a
end

class DocumentData < BinData::Buffer
  endian :little

  int32 :crop_x0
  int32 :crop_x1
  int32 :crop_y0
  int32 :crop_y1
  rgba :grid_color
  int32 :render_mode
  float :glow
  float :glow_radius
  int32 :glow_invert # ??
  rgba :canvas_color
  int8 :canvas_mode
  int8 :glow_off
  float :outline_width
  int64 :glow_pattern
  int8 :glow_pattern_width
  int8 :glow_pattern_height
  int8 :has_custom_glow
  int8 :grid_disabled
  int8 :export_borders
  int64 :canvas_image_buffer
  int32 :canvas_image_width
  int32 :canvas_image_height
  int8 :hide_empty_grid
  uint8 :hexel_transparency
  int64 :image_buffer_compressed
  uint32 :image_buffer_compressed_size
end

class Outline < BinData::Record
  endian :little

  int32 :total_lines
  array :lines, :initial_length => :total_lines do
    # TODO: Move to own class
    int32 :hexel_index
    int32 :line_index
    rgba :line_color
    uint8 :line_width
  end
end

class RenderMode < BinData::Record
  endian :little

  int32 :total_modes
  array :modes, :initial_length => :total_modes do
  # array :modes, :initial_length => 1 do
    endian :little
    int32 :name_length
    string :name, :length => :name_length
    int8 :is_current_mode
    int32 :data_length
    string :data, :length => lambda { data_length - 4 }
  end
end

class Hexels < BinData::Record
  endian :little
  string :header, :length => 7
  string :version, :length => 1
  int32 :width
  int32 :height
  array :cells, :initial_length => lambda { width * height } do
    endian :little
    rgba :color
    int64 :filler
  end
  document_data :document_data, :length => 1024
  outline :outline
  render_mode :render_mode
  array :data_bundles, :read_until => :eof do
    endian :little
    stringz :name
    int32 :data_length
    string :data, :length => :data_length
  end
end

def c(color)
  "#{color.r} #{color.g} #{color.b} #{color.a}"
end

def s(struct)
  "(#{struct.abs_offset.to_s(16).rjust(3, '0')})"
end

def parse(file)
  io = File.open(file, 'r')
  hexels = Hexels.read(io)
  puts "Header: #{hexels.header} #{s(hexels.header)}"
  puts "Version: #{hexels.version.ord} #{s(hexels.version)}"
  puts "Dimensions: #{hexels.width} x #{hexels.height} [#{s(hexels.width)}, #{s(hexels.height)}]"
  hexels.cells.each do |cell|
    puts " Cell #{c(cell.color)} #{s(cell)}"
  end
  d = hexels.document_data
  puts "Document Data:"
  puts "  Crop: #{[d.crop_x0, d.crop_x1, d.crop_y0, d.crop_y1].join(',')} #{s(d.crop_x0)}"
  puts "  Grid color: #{c(d.grid_color)} #{s(d.grid_color)}"
  puts "  Glow: #{d.glow} #{d.glow_radius} #{d.glow_invert} #{s(d.glow)}"
  puts "  Canvas: #{c(d.canvas_color)} #{s(d.canvas_color)}"
  puts "  Canvas mode: #{d.canvas_mode} #{s(d.canvas_mode)}"
  puts "  Outline width: #{d.outline_width} #{s(d.outline_width)}"
  puts "  Glow pattern #{d.glow_pattern_width} #{d.glow_pattern_height} #{s(d.glow_pattern_width)}"
  puts "  Has cutsom glow: #{d.has_custom_glow} #{s(d.has_custom_glow)}"
  puts "  Grid disabled: #{d.grid_disabled} #{s(d.grid_disabled)}"
  puts "  Export borders: #{d.export_borders} #{s(d.export_borders)}"
  puts "  Canvas Image Buffer #{d.canvas_image_buffer} #{s(d.canvas_image_buffer)}"
  puts "  Hide empty grid?: #{d.hide_empty_grid} #{s(d.hide_empty_grid)}"
  puts "  Hexel transparency: #{d.hexel_transparency} #{s(d.hexel_transparency)}"
  puts "  Image buffer compressed: #{d.image_buffer_compressed} #{s(d.image_buffer_compressed)}"
  puts "  Image buffer compressed size: #{d.image_buffer_compressed_size} #{s(d.image_buffer_compressed_size)}"
  o = hexels.outline
  puts "Outilne data:"
  puts "  Lines: #{o.total_lines} #{s(o.total_lines)}"
  o.lines.each do |line|
    puts "   --"
    puts "    Hexel index: #{line.hexel_index} #{s(line.hexel_index)}"
    puts "    Line index: #{line.line_index} #{s(line.line_index)}"
    puts "    Line color: #{line.line_color} #{s(line.line_color)}"
    puts "    Line width: #{line.line_width} #{s(line.line_width)}"
  end
  r = hexels.render_mode
  puts "Render modes data:"
  puts "  Render modes: #{r.total_modes} #{s(r.total_modes)}"
  r.modes.each do |mode|
    puts "   --"
    puts "    Name length: #{mode.name_length} #{s(mode.name_length)}"
    puts "    Name: #{mode.name} #{s(mode.name)}"
    puts "    Is current mode: #{mode.is_current_mode} #{s(mode.is_current_mode)}"
    puts "    Mode data length: #{mode.data_length} #{s(mode.data_length)}"
    puts "    Mode data: #{mode.data} #{s(mode.data)}"
  end
  puts "Data bundles:"
  hexels.data_bundles.each do |bundle|
    puts "  --"
    puts "  Name: #{bundle.name} #{s(bundle.name)}"
    puts "  Length: #{bundle.data_length} #{s(bundle.data_length)}"
    puts "  Data: BIN(#{bundle.data.length}) #{s(bundle.data)}"
  end
end

parse(ARGV[0] || '/Users/chubas/Dropbox/Hexel/script/simple.hxl')