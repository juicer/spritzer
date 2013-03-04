module Spritzer
  # Allows accessing config variables from spritzer.yml like so:
  # Spritzer[:qa][:password] => Swe3tp@55weRd

  RAILS_ROOT = "/home/abutcher/rhat/spritzer"

  def self.[](key)
    unless @config
      raw_config = File.read(RAILS_ROOT + "/config/spritzer.yml")
      @config = HashWithIndifferentAccess.new(YAML.load(raw_config))
    end
    @config[key]
  end
  
  def self.[]=(key, value)
    @config[key.to_sym] = value
  end
end
