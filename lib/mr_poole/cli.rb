require 'optparse'
require 'ostruct'

module MrPoole
  class CLI

    def initialize(args)
      @helper = Helper.new
      @src_dir = @helper.ensure_jekyll_dir

      @params = args
      @config = @helper.config

      ext = @config.default_extension || 'md'
      @commands = Commands.new(ext)
    end

    def execute(action)
      case action
      when 'post' then handle_post
      when 'draft' then handle_draft
      when 'publish' then handle_publish
      when 'unpublish' then handle_unpublish
      when '--version' then @helper.version_statement
      when '-v' then @helper.version_statement
      else @helper.gen_usage
      end

      @helper.restore_orig_directory
    end

    def handle_post
      do_create('post')
    end

    def handle_draft
      do_create('draft')
    end

    def handle_publish
      do_move('publish')
    end

    def handle_unpublish
      do_move('unpublish')
    end

    private

    # action is a string, either 'post' or 'draft'
    def do_create(action)
      options = do_creation_options
      options.title ||= @params.first

      @helper.send("#{action}_usage") unless options.title
      fn = @commands.send(action, options)
      puts "#{@src_dir}/#{fn}"
    end

    # action is a string, either 'publish' or 'unpublish'
    def do_move(action)
      options = do_move_options(action)
      path = @params.first

      @helper.send("#{action}_usage") unless path
      fn = @commands.send(action, path, options)
      puts "#{@src_dir}/#{fn}"
    end

    def do_creation_options
      options = OpenStruct.new
      options.slug = nil
      options.title = nil
      options.layout = nil

      opt_parser = OptionParser.new do |opts|
        opts.on('-s', '--slug SLUG', "Use custom slug") do |s|
          options.slug = s
        end

        opts.on('-t', '--title TITLE', "Specifiy title") do |t|
          options.title = t
        end

        opts.on('-l', '--layout PATH', "Specify a custom layout file") do |l|
          options.layout = l
        end
      end

      options.layout ||= @config.default_layout

      opt_parser.parse! @params
      options
    end

    # pass a string, either publish or unpublish
    def do_move_options(type)
      options = OpenStruct.new
      opt_parser = OptionParser.new do |opts|
        if type == 'publish'
          opts.on('-d', '--keep-draft', "Keep draft post") do |d|
            options.keep_draft = d
          end
        else
          opts.on('-p', '--keep-post', "Do not delete post") do |p|
            options.keep_post = p
          end
        end

        opts.on('-t', '--keep-timestamp', "Keep existing timestamp") do |t|
          options.keep_timestamp = t
        end
      end

      opt_parser.parse! @params
      options
    end

  end
end
