module MrPoole
  class Helper

    def initialize
      # nothing to do here
    end

    # Check for a _posts directory in current directory
    # If we don't find one, puke an error message and die
    def ensure_jekyll_dir
      unless Dir.exists?('./_posts')
        puts 'ERROR: Cannot locate _posts directory. Double check to make sure'
        puts '       that you are in a jekyll directory.'
        exit
      end
    end

    # Configure the default layout.
    #
    # If a user has $HOME/.poole_default_layout, will use the contents of
    # that file, otherwise will use a simple template
    def get_default_layout
      config_path = File.join(Dir.home, '.poole_default_layout')

      if File.exists?(config_path)
        return File.open(config_path, 'r').read
      else
        s  = "---\n"
        s << "title:\n"
        s << "layout: post\n"
        s << "date:\n"
        s << "---\n"
      end
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
      puts ''
      puts 'Options:'
      puts '  --slug    Define a custom slug for post, used for generated file name'
      puts '            (also available with -s)'
      puts '  --title   Define a title for post (also available with -t)'
      puts '            This option may be omitted provided that TITLE is given as'
      puts '            the last argument to poole'
      exit
    end

  end
end
