require 'bundler/setup'
require 'bindata'
require 'yaml'

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
