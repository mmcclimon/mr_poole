require 'yaml'
require 'ostruct'

module MrPoole
  class Config

    def initialize
      begin
        if File.exists?('_config.yml')
          yaml = YAML.load(File.read('_config.yml'))
          @config = OpenStruct.new(yaml["poole"])
          @config.srcdir = yaml['source'] if yaml['source']
        else
          @config = OpenStruct.new
        end
      rescue Psych::SyntaxError
        bad_yaml_message
        exit
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

    private

    def bad_yaml_message
      puts 'Error reading YAML file _config.yml!'
      puts '  (Did you forget to escape a hyphen?)'
    end
  end
end
