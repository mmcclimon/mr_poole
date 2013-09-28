module MrPoole
  class Helper

    def initialize
      # nothing to do here
    end

    # Check for a _posts directory in current directory
    # If we don't find one, puke an error message and die
    def ensure_jekyll_dir
      unless File.exists?('./_posts')
        puts 'ERROR: Cannot locate _posts directory. Double check to make sure'
        puts '       that you are in a jekyll directory.'
        exit
      end
    end

    def ensure_open_struct(opts)
      return opts.instance_of?(Hash) ?  OpenStruct.new(opts) : opts
    end

    # Get a layout as a string. If layout_path is non-nil,  will open that
    # file and read it, otherwise will return a default one, and a file
    # extension to use
    def get_layout(layout_path)

      if layout_path.nil?
        contents  = "---\n"
        contents << "title:\n"
        contents << "layout: post\n"
        contents << "date:\n"
        contents << "---\n"
        ext = nil
      else
        begin
          contents = File.open(layout_path, "r").read()
          ext = layout_path.match(/\.(.*?)$/)[1]
        rescue Errno::ENOENT
          bad_path(layout_path)
        end
      end

      return contents, ext
    end

    # Given a post title (mixed case, spaces, etc.), generates a slug for
    # This clobbers any non-ASCII text (TODO don't do that)
    def get_slug_for(title)
      title.downcase.gsub(/[^a-z0-9_\s-]/, '').gsub(/\s+/, '_')
    end

    def get_date_stamp
      Time.now.strftime("%Y-%m-%d")
    end

    def get_time_stamp
      Time.now.strftime("%H:%M")
    end

    def bad_path(path)
      puts "Error: could not open #{path}"
      exit
    end

    def version_statement
      puts ''
      puts "This is Mr. Poole, version #{MrPoole::VERSION}, running on ruby version #{RUBY_VERSION}"
      puts ''
      puts 'Copyright 2013, Michael McClimon'
      puts 'https://github.com/mmcclimon/mr_poole'
      puts ''
      exit
    end

    # Print a usage message and exit
    def gen_usage
      puts 'Usage:'
      puts '  poole [ACTION] [ARG]'
      puts ''
      puts 'Actions:'
      puts '  draft      Create a new draft in _drafts with title SLUG'
      puts '  post       Create a new timestamped post in _posts with title SLUG'
      puts '  publish    Publish the draft with SLUG, timestamping appropriately'
      puts '  unpublish  Move a post to _drafts, untimestamping appropriately'
      exit
    end

    def post_usage
      puts 'Usage:'
      puts '  poole post [OPTION] [ARG] TITLE'
      creation_options_usage
      exit
    end

    def draft_usage
      puts 'Usage:'
      puts '  poole draft [OPTION] [ARG] TITLE'
      creation_options_usage
      exit
    end

    def creation_options_usage
      puts ''
      puts 'Options:'
      puts '  -s, --slug    Define a custom slug for post, used for generated file name'
      puts '  -t, --title   Define a title for post This option may be omitted provided'
      puts '                that TITLE is given as the last argument to poole'
      puts '  -l, --layout  Path to a custom layout file to use'
    end

    def publish_usage
      puts 'Usage:'
      puts '  poole publish [OPTIONS] PATH_TO_DRAFT'
      puts ''
      puts 'Options:'
      puts '  -d, --keep-draft      Do not delete the draft post'
      puts '  -t, --keep-timestamp  Do not update the draft timestamp'
      exit
    end

    def unpublish_usage
      puts 'Usage:'
      puts '  poole unpublish PATH_TO_POST'
      puts ''
      puts 'Options:'
      puts '  -p, --keep-post       Do not delete the existing post'
      puts '  -t, --keep-timestamp  Do not update the existing timestamp'
      exit
    end

  end
end
