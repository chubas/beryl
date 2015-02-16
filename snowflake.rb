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
    (@radius + 1 + 10).times do |iter|
      transform(iter)
    end
    paint('big')
  end

  def seed
    # Simplest seed
    # x, y = hex_to_sq(0, 0)
    # @grid[y][x] = { :r => 50, :g => 108, :b => 217, :a => 255 }

    # Arms
    (0..@radius).each do |n|
      next unless n.even?
      [
        [0, -n], [n, -n], [n, 0],
        [0, n], [-n, n], [-n, 0]
      ].uniq.each do |hx, hy|
        x, y = hex_to_sq(hx, hy)
        @grid[y][x] = { :r => 50, :g => 108, :b => 217, :a => 255 }
      end
    end

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
    @canvas.write(ARGV[1] || "snowflake_#{iter}.hxl")
  end

  def transform(iter)
    #== Find pattern index
    patterns = [
      '000001', '000011', '000101', '000111',
      '001001', '001011', '001101', '001111',
      '010101', '010111', '011011', '011111', '111111'
    ]
    p_freeze = [1, 0.2, 0.1, 0, 0.2, 0.1, 0.1, 0, 0.1, 0.1, 1, 1, 0]
    p_melt = [0, 0.7, 0.5, 0.5, 0, 0, 0, 0.3, 0.5, 0, 0.2, 0.1, 0]
    should_freeze = p_freeze.map { |p| rand < p }
    should_melt = p_melt.map { |p| rand > p }
    # If we consider rotational symmetry as well, then patterns 001011 and 001011 are the same
    should_freeze[patterns.index('001011')] = should_freeze[patterns.index('001101')]
    should_melt[patterns.index('001011')] = should_melt[patterns.index('001101')]

    # puts "===== TRANSFORMING #{iter}"
    clone = Marshal.load(Marshal.dump(@grid))
    clone.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        # puts "CELL! #{x}, #{y} => #{cell}" if cell
        neighbor_pattern = ""
        get_neighbors_hex(*sq_to_hex(x, y)).each do |nx_hex, ny_hex|
          nx, ny = *hex_to_sq(nx_hex, ny_hex)
          # puts "Neighbor: #{nx}, #{ny} (#{nx_hex}, #{ny_hex})"
          # clone[ny][nx] = {
          #   :r => (256 / (@radius + 1)) * ny_hex.abs,
          #   :g => (256 / (@radius + 1)) * nx_hex.abs,
          #   :b => (256 / (@radius + 1)) * (nx_hex + ny_hex).abs,
          #   :a => 255
          # }
          # puts "#{nx}, #{ny} (#{nx_hex}, #{ny_hex}) => #{exists_sq?(ny_hex, nx_hex)}"
          neighbor_pattern << ((exists_sq?(nx_hex, ny_hex) && is_inside_hexagon?(nx_hex, ny_hex) && @grid[ny][nx]) ? '1' : '0')

          # puts " - Colors:"
          # puts "  #{(256 / (@radius + 1)) * ny_hex.abs}"
          # puts "  #{(256 / (@radius + 1)) * nx_hex.abs}"
          # puts "  #{(256 / (@radius + 1)) * (ny_hex + nx_hex).abs}"
          # puts " -"
        end

        if neighbor_pattern == '000000'
          next
        end

        s = neighbor_pattern
        m = patterns.find do |ring|
          # puts s
          [*0..5].any? do |cut|
            # puts "Checking (#{cut}) " + s[cut..-1] + s[0, cut]
            s[cut..-1] + s[0, cut] == ring
          end
        end

        n = patterns.index(m)
        # puts "Neighbor pattern for #{x}, #{y} => #{neighbor_pattern}, index: #{n}"
        if is_inside_hexagon?(*sq_to_hex(x, y))
          if @grid[y][x] == nil
            if should_freeze[n]
              # puts "FREEZING #{x}, #{y}"
              clone[y][x] = { :r => 255, :g => 255, :b => 255, :a => 255 }
            end
          else
            if should_melt[n]
              # puts "MELTING #{x}, #{y}"
              clone[y][x] = nil
            end
          end
        end

        # puts " #{n} => #{s} => #{m}"

      end
    end
    @grid = clone
  end

  def is_inside_hexagon?(hx, hy)
    return hx.abs <= @radius && hy.abs <= @radius && (hx + hy).abs <= @radius
  end

  # Utility methods
  def hex_to_sq(hx, hy)
    y = hy + @radius
    x = hx + ((@radius + 1) / 2) + (y / 2)
    # puts "HEX(#{hx}, #{hy}) => #{x}, #{y}"
    [x, y]
  end

  def sq_to_hex(x, y)
    hx = x - (y / 2) - ((@radius + 1) / 2)
    hy = y - @radius
    # puts "SQ(#{x}, #{y}) => HEX(#{hx}, #{hy})"
    [hx, hy]
  end

  # Return if the coordinate is inside the square coordinate system grid,
  # this is, if it fits inside the map
  def exists_sq?(hx, hy)
    x, y = *hex_to_sq(hx, hy)
    x_is_inside = x >= 0 && x < @radius * 2 + 1 # Refactor this into constant SQ_LENGTH
    y_is_inside = y >= 0 && y < @radius * 2 + 1
    x_is_inside && y_is_inside
  end

  def get_neighbors_hex(hx, hy)
    # Ordered clockwise from topleft
    deltas_hex = [
      [0, -1], [1, -1], [1, 0],
      [0, 1], [-1, 1], [-1, 0]
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
