require 'yaml'
require 'ostruct'

# YAML parsing in old rubies didn't use Psych, and so throws a NameError later
# when we check for one after we parse our YAML. Before we start, we'll check
# for that and create a dummy Pysch::SyntaxError constant. Older ruby YAML
# errors will be caught by check_word_separator and will throw a TypeError
# instead.
if RUBY_VERSION < '1.9'
  class Psych
    SyntaxError = nil
  end
end

module MrPoole
  class Config

    def initialize
      begin
        if File.exists?('_config.yml')
          yaml = YAML.load(File.read('_config.yml'))
          @config = OpenStruct.new(yaml["poole"])
          @config.srcdir = yaml['source'] if yaml['source']
          check_word_separator
        else
          @config = OpenStruct.new
        end
      rescue TypeError, ::Psych::SyntaxError
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

    # on old rubies, the YAML parser doesn't throw an error if you pass
    # something like 'word_separator: -', it just assumes you want an array
    # with the elment nil.  We'll check for that case and die, since it's not
    # what we want here.
    def check_word_separator
      return unless @config.word_separator
      if @config.word_separator == [nil]
        raise TypeError
      end
    end

    def bad_yaml_message
      puts 'Error reading YAML file _config.yml!'
      puts '  (Did you forget to escape a hyphen?)'
    end
  end
end
