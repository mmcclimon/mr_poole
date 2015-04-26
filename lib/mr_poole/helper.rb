require 'yaml'
require 'pathname'

module MrPoole
  class Helper

    attr_accessor :config

    def initialize
      @config = Config.new
    end

    # Check for a _posts directory in current directory. If there's not one,
    # check for a _config.yml and look for a custom src directory.  If we
    # don't find one, puke an error message and die. If we do, return the name
    # of the directory
    def ensure_jekyll_dir
      @orig_dir = Dir.pwd
      start_path = Pathname.new(@orig_dir)

      ok = File.exists?('./_posts')
      new_path = nil

      # if it doesn't exist, check for a custom source dir in _config.yml
      if !ok
        check_custom_src_dir!
        ok = File.exists?('./_posts')
        new_path = Pathname.new(Dir.pwd)
      end

      if ok
        return (new_path ? new_path.relative_path_from(start_path) : '.')
      else
        puts 'ERROR: Cannot locate _posts directory. Double check to make sure'
        puts '       that you are in a jekyll directory.'
        exit
      end
    end

    def restore_orig_directory
      Dir.chdir(@orig_dir)
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
      word_sep = @config.word_separator || '_'
      title.downcase.gsub(/[^a-z0-9_\s-]/, '').gsub(/\s+/, word_sep)
    end

    def get_date_stamp
      format = @config.time_format || '%Y-%m-%d'
      Time.now.strftime(format)
    end

    def get_time_stamp
      Time.now.strftime("%H:%M %Z")
    end

    def bad_path(path)
      puts "Error: could not open #{path}"
      exit
    end

    def open_in_editor(path)
      # don't do anything if the user hasn't explicitly enabled the feature
      return unless @config.auto_open

      if editor = ENV['EDITOR']
        `#{editor} #{path}`
      else
        puts "You have enabled the auto_open feature in your config.yml,"
        puts "but have no editor configured."
        puts ''
        puts "Please set your $EDITOR environment variable to the "
        puts "editor that poole should use to open new posts/drafts."
        puts ''
      end
    end

    def version_statement
      puts ''
      puts "This is Mr. Poole, version #{MrPoole::VERSION}, running on ruby version #{RUBY_VERSION}"
      puts ''
      puts 'Copyright 2014, Michael McClimon'
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

    # Private methods
    #################
    private

    # If a user has a custom 'source' defined in their _config.yml, change
    # to that directory for everything else
    def check_custom_src_dir!
      srcdir = @config.srcdir
      Dir.chdir(srcdir) if srcdir
    end

  end
end
