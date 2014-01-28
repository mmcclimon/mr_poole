require 'optparse'
require 'ostruct'

module MrPoole
  class CLI

    def initialize(args)
      @helper = Helper.new
      @src_dir = @helper.ensure_jekyll_dir

      @params = args
      @config = Config.new

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
      options = do_creation_options
      options.title ||= @params.first

      @helper.post_usage unless options.title
      fn = @commands.post(options)
      puts "#{@src_dir}/#{fn}"
    end

    def handle_draft
      options = do_creation_options
      options.title ||= @params.first

      @helper.draft_usage unless options.title
      fn = @commands.draft(options)
      puts "#{@src_dir}/#{fn}"
    end

    def handle_publish
      options = OpenStruct.new
      opt_parser = OptionParser.new do |opts|
        opts.on('-d', '--keep-draft', "Keep the draft post") do |d|
          options.keep_draft = d
        end
        opts.on('-t', '--keep-timestamp', "Keep the existing timestamp") do |t|
          options.keep_timestamp = t
        end
      end
      opt_parser.parse! @params

      path = @params.first
      @helper.publish_usage unless path
      fn = @commands.publish(path, options)
      puts "#{@src_dir}/#{fn}"
    end

    def handle_unpublish
      options = OpenStruct.new
      opt_parser = OptionParser.new do |opts|
        opts.on('-p', '--keep-post', "Do not delete post") do |p|
          options.keep_post = p
        end
        opts.on('-t', '--keep-timestamp', "Keep the existing timestamp") do |t|
          options.keep_timestamp = t
        end
      end
      opt_parser.parse! @params

      path = @params.first
      @helper.unpublish_usage unless path
      fn = @commands.unpublish(path, options)
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

  end
end
