require './hexel_canvas'

palette = HexelsCanvas.new(:width => 32, :height => 32, :mode => MODES::PIXEL)
0.step(255, 8).each_with_index do |r, row|
  0.step(255, 8).each_with_index do |c, col|
    palette[col, row] = { :r => r, :g => c, :b => 0, :a => 255 }
  end
end

palette.write('palette.hxl')