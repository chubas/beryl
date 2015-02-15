require './beryl'

module MODES
  STANDARD = 'Standard'
  TRIXEL = 'Trixel'
  SHARDS = 'Shards'
  PIXEL = 'Pixel'
  CUBES = 'Cubes'
  STARBURST = 'Starburst'
  BEVEL = 'Bevel'
  PLUS = 'Plus'
  VORONOI = 'Voronoi'
  CUSTOM = 'Custom'
  X_EL = 'X-el'
end

# TODO: Probably rename this to Hexels and the other class to HexelsData
# or something
class HexelsCanvas

  def initialize(settings)
    @width = settings[:width]
    @height = settings[:height]
    @mode = settings[:mode] || MODES::STANDARD
    raise "Width and height required" unless @width and @height
    @hexels = Hexels.new
    initialize_defaults
  end

  def[]=(x, y, rgba)
    index = y * @width + x
    @hexels.cells[index].color = RGBA.new(rgba)
  end

  def write(filename)
    File.open(filename, 'wb+') do |file|
      @hexels.write(file)
    end
  end

  private

  def initialize_defaults
    @hexels.header = "HEXELS!"
    @hexels.version = 10.chr
    @hexels.width = @width
    @hexels.height = @height

    defaults = YAML.load_file('defaults.yml')


    d = DocumentData.new(:length => 1024)
    @hexels.document_data = d

    d.crop_x0 = 0
    d.crop_x1 = @width
    d.crop_y0 = 0
    d.crop_y1 = @height
    d.grid_color = RGBA.new(:r => 0, :g => 0, :b => 0, :a => 255)
    d.glow = 0.03500000014901161
    d.glow_radius = 7.0
    d.glow_invert = 0
    d.canvas_color = RGBA.new(:r => 0, :g => 0, :b => 0, :a => 255)
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
    @hexels.outline = Outline.new
    @hexels.outline.total_lines = 0
    @hexels.document_data = d

    # puts d.render_mode
    @hexels.render_mode.assign(:total_modes => 11)
    defaults[:modes].each_with_index do |mode, index|
      @hexels.render_mode.modes[index].assign(
        :name_length => mode[:name_length],
        :name => mode[:name],
        :data_length => mode[:data_length],
        :data => mode[:data],
        :is_current_mode => @mode == mode[:name] ? 1 : 0
      )
    end

    defaults[:data_bundles].each_with_index do |bundle, index|
      @hexels.data_bundles[index].assign(
        :name => bundle[:name],
        :data_length => bundle[:data_length],
        :data => bundle[:data]
      )
    end

  end

end