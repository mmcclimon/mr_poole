require 'getoptlong'

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
      opts = GetoptLong.new(
        ['--slug', '-s', GetoptLong::REQUIRED_ARGUMENT],
        ['--title', '-t', GetoptLong::REQUIRED_ARGUMENT],
      )

      slug = nil
      title = nil

      opts.each do |opt, arg|
        case opt
        when '--slug' then slug = arg
        when '--title' then title = arg
        end
      end

      title ||= @params.first

      @helper.post_usage unless title
      @tasks.post(title, slug)
    end

    def handle_draft

    end

    def handle_publish

    end

    def handle_unpublish

    end

  end
end
