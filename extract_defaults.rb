require './beryl'

def extract_defaults(in_file, out_file)
  defaults = {}
  io = File.open(in_file, 'r')
  hexels = Hexels.read(io)
  defaults[:data_bundles] = []

  defaults[:modes] = hexels.render_mode.modes.map do |mode|
    {
      :name_length => mode.name_length.snapshot,
      :name => mode.name.snapshot,
      :data_length => mode.data_length.snapshot,
      :data => mode.data.snapshot
    }
  end

  hexels.data_bundles.each do |bundle|
    if ['ExportSettings', 'HextureData', 'VersionData'].include?(bundle.name)
      defaults[:data_bundles] << {
        :name => bundle.name.snapshot,
        :length => bundle.data_length.snapshot,
        :data => bundle.data.snapshot
      }
    end
  end

  File.open(out_file, 'w+') do |file|
    file.puts defaults.to_yaml
  end
end

extract_defaults(ARGV[0], ARGV[1])