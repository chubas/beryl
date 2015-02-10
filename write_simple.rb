require './beryl'

defaults = YAML.load_file('defaults.yml')
h = Hexels.new
h.header = "HEXELS!"
h.version = 10.chr
h.width = 2
h.height = 2
c = RGBA.new
c.r = 126
c.g = 215
c.b = 90
c.a = 200
h.cells[0].color = RGBA.new(:r => 126, :g => 215, :b => 90, :a => 255)
h.cells[1].color.assign(:r => 126, :g => 215, :b => 90, :a => 255)
h.cells[2].color.assign(:r => 126, :g => 215, :b => 90, :a => 255)
h.cells[3].color.assign(:r => 126, :g => 215, :b => 90, :a => 255)
d = DocumentData.new(:length => 1024)
d.crop_x0 = 0
d.crop_x1 = 2
d.crop_y0 = 0
d.crop_y1 = 2
d.grid_color.assign(:r => 100, :g => 50, :b => 35, :a => 200)
d.glow = 0.03500000014901161
d.glow_radius = 7.0
d.glow_invert = 0
d.canvas_color = RGBA.new(:r => 100, :g => 20, :b => 65, :a => 255)
d.canvas_mode = 0
d.glow_off = 0
d.outline_width = -107479040.0
d.glow_pattern_width = 0
d.glow_pattern_height = 0
d.has_custom_glow = 0
d.grid_disabled = 1
d.export_borders = 0
d.canvas_image_buffer = 281474976776192 # ??
d.canvas_image_width = 0
d.canvas_image_height = 0
d.hide_empty_grid = 0
d.hexel_transparency = 0
d.image_buffer_compressed_size = 0
d.image_buffer_compressed = 0
h.outline = Outline.new
h.outline.total_lines = 0
h.document_data = d

# puts d.render_mode
h.render_mode.assign(:total_modes => 11)
defaults[:modes].each_with_index do |mode, index|
  h.render_mode.modes[index].assign(
    :name_length => mode[:name_length],
    :name => mode[:name],
    :data_length => mode[:data_length],
    :data => mode[:data],
    :is_current_mode => index == 0 ? 1 : 0
  )
end

# h.data_bundles.initial_length = defaults[:data_bundles].length
defaults[:data_bundles].each_with_index do |bundle, index|
  h.data_bundles[index].assign(
    :name => bundle[:name],
    :data_length => bundle[:data_length],
    :data => bundle[:data]
  )
end

File.open(ARGV[0], 'wb+') do |file|
  h.write(file)
end
