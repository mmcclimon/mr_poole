require 'optparse'
require 'ostruct'

module MrPoole
  class CLI

    def initialize(args)
      @helper = Helper.new
      @helper.ensure_jekyll_dir

      @params = args
      @commands = Commands.new
    end

    def execute(action)
      case action
      when 'post' then handle_post
      when 'draft' then handle_draft
      when 'publish' then handle_publish
      when 'unpublish' then handle_unpublish
      else @helper.gen_usage
      end
    end

    def handle_post
      options = do_creation_options
      options.title ||= @params.first

      @helper.post_usage unless options.title
      @commands.post(options)
    end

    def handle_draft
      options = do_creation_options
      options.title ||= @params.first

      @helper.draft_usage unless options.title
      @commands.draft(options)
    end

    def handle_publish
      options = OpenStruct.new
      opt_parser = OptionParser.new do |opts|
        # eventually there will be options...not yet
      end
      opt_parser.parse! @params

      path = @params.first
      @helper.publish_usage unless path
      @commands.publish(path)
    end

    def handle_unpublish
      options = OpenStruct.new
      opt_parser = OptionParser.new do |opts|
        # eventually there will be options...not yet
      end
      opt_parser.parse! @params

      path = @params.first
      @helper.unpublish_usage unless path
      @commands.unpublish(path)
    end

    def do_creation_options
      options = OpenStruct.new
      options.slug = nil
      options.title = nil

      opt_parser = OptionParser.new do |opts|
        opts.on('-s', '--slug [SLUG]', "Use custom slug") do |s|
          options.slug = s
        end

        opts.on('-t', '--title [TITLE]', "Specifiy title") do |t|
          options.title = t
        end
      end

      opt_parser.parse! @params
      options
    end

  end
end
