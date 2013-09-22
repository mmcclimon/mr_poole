require 'yaml'
require 'ostruct'

module MrPoole
  class Config

    def initialize
      if File.exists?('_config.yml')
        yaml = YAML.load(File.read('_config.yml'))
        @config = OpenStruct.new(yaml["poole"])
      else
        @config = OpenStruct.new
      end
    end

    def empty?
      @config == OpenStruct.new
    end

    def inspect
      @config.inspect
    end

    def method_missing(sym, *args)
      @config.send(sym)
    end

  end
end
