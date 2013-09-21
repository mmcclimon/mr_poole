require 'optparse'
require 'ostruct'

module MrPoole
  class CLI

    def initialize(args)
      @helper = Helper.new
      @helper.ensure_jekyll_dir

      @params = args
      @tasks = Tasks.new
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
      options = OpenStruct.new
      options.slug = nil
      options.title = nil

      opt_parser = OptionParser.new do |opts|
        opts.banner = 'Usage:  poole post [options]'
        opts.separator ''
        opts.separator "Options: "

        opts.on('-s', '--slug [SLUG]', "Use custom slug") do |s|
          options.slug = s
        end

        opts.on('-t', '--title [TITLE]', "Specifiy title") do |t|
          options.title = t
        end
      end

      opt_parser.parse! @params

      options.title ||= @params.first

      @helper.post_usage unless options.title
      @tasks.post(options.title, options.slug)
    end

    def handle_draft

    end

    def handle_publish

    end

    def handle_unpublish

    end

  end
end
