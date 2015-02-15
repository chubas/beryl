require './hexel_canvas'

class Snowflake

  def initialize(config)
    raise "Need radius" unless config[:radius]
    @radius = config[:radius]
    @canvas = HexelsCanvas.new(
      :width => @radius * 2 + 1,
      :height => @radius * 2 + 1,
      :mode => MODES::STANDARD
    )
    puts "RADIUS: #{@radius}"
    @grid = Array.new(@radius * 2 + 1) do
      Array.new(@radius * 2 + 1) { nil }
    end
    seed
    @radius.times do |iter|
      paint(iter)
      transform(iter)
    end
  end

  def seed
    x, y = hex_to_sq(0, 0)
    @grid[y][x] = { :r => 50, :g => 108, :b => 217, :a => 255 }
  end

  def paint(iter)
    @grid.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if cell == nil
          @canvas[x, y] = { :r => 0, :g => 0, :b => 0, :a => 0 }
        else
          @canvas[x, y] = cell
        end
      end
    end
    @canvas.write("snowflake_#{iter}.hxl")
  end

  def transform(iter)
    # neighbors = []
    # neighbors += get_neighbors_hex(0, 0)
    # neighbors += get_neighbors_hex(1, 1)
    # neighbors.each do |nx_hex, ny_hex|
    #   if exists_sq?(nx_hex, ny_hex)
    #     nx, ny = *hex_to_sq(nx_hex, ny_hex)
    #     @grid[ny][nx] = { :r => 209, :g => 27, :b => 151, :a => 255 }
    #   end
    # end

    puts "===== TRANSFORMING #{iter}"
    clone = Marshal.load(Marshal.dump(@grid))
    clone.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        if @grid[y][x] != nil
          # puts "CELL! #{x}, #{y}"
          get_neighbors_hex(*sq_to_hex(x, y)).each do |nx_hex, ny_hex|
            nx, ny = *hex_to_sq(nx_hex, ny_hex)
            # puts "Neighbor: #{nx}, #{ny} (#{nx_hex}, #{ny_hex})"
            clone[ny][nx] = {
              :r => (256 / (@radius + 1)) * ny_hex.abs,
              :g => (256 / (@radius + 1)) * nx_hex.abs,
              :b => (256 / (@radius + 1)) * (nx_hex + ny_hex).abs,
              :a => 255
            }
            # puts " - Colors:"
            # puts "  #{(256 / (@radius + 1)) * ny_hex.abs}"
            # puts "  #{(256 / (@radius + 1)) * nx_hex.abs}"
            # puts "  #{(256 / (@radius + 1)) * (ny_hex + nx_hex).abs}"
            # puts " -"
          end
        end
      end
    end
    @grid = clone
  end

  # Utility methods
  def hex_to_sq(hx, hy)
    y = hy + @radius
    x = hx + ((@radius + 1) / 2) + (y / 2)
    puts "HEX(#{hx}, #{hy}) => #{x}, #{y}"
    [x, y]
  end

  def sq_to_hex(x, y)
    hx = x - (y / 2) - ((@radius + 1) / 2)
    hy = y - @radius
    puts "SQ(#{x}, #{y}) => HEX(#{hx}, #{hy})"
    [hx, hy]
  end

  # Return if the coordinate is inside the square coordinate system grid,
  # this is, if it fits inside the map
  def exists_sq?(hx, hy)
    x, y = *hex_to_sq(hx, hy)
    x_is_inside = x >= 0 && x < @radius * 2 + 1 # Refactor this into constant SQ_LENGTH
  end

  def get_neighbors_hex(hx, hy)
    deltas_hex = [
      [0, -1], [1, -1],
      [-1, 0], [1, 0],
      [-1, 1], [0, 1]
    ]
    neighbors = []
    deltas_hex.each do |deltax, deltay|
      neighbors << [deltax + hx, deltay + hy]
    end
    neighbors
  end

end

snowflake = Snowflake.new(:radius => (ARGV[0] || 2).to_i)

# snowflake.hex_to_sq(0, 0)
# snowflake.hex_to_sq(0, 1)
# snowflake.hex_to_sq(0, 2)
# snowflake.hex_to_sq(1, 0)
# snowflake.hex_to_sq(1, 1)
# snowflake.hex_to_sq(1, -1)

# snowflake.hex_to_sq(0, 0)
# snowflake.hex_to_sq(0, 1)
# snowflake.hex_to_sq(0, 2)
# snowflake.hex_to_sq(1, 0)
# snowflake.hex_to_sq(1, 1)
# snowflake.hex_to_sq(1, -1)
