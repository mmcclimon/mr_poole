require 'fileutils'

module MrPoole
  class Tasks

    POSTS_FOLDER = '_posts'
    DRAFTS_FOLDER = '_drafts'

    def initialize
      @helper = Helper.new
      @helper.ensure_jekyll_dir

      @default_layout = @helper.get_default_layout
    end

    # Print a usage message and exit
    def usage
      puts 'Usage:'
      puts '  poole [ACTION] [ARG]'
      puts ''
      puts 'Actions:'
      puts '  draft      [SLUG]    Create a new draft in _drafts with title SLUG'
      puts '  post       [SLUG]    Create a new timestamped post in _posts with title SLUG'
      puts '  publish    [SLUG]    Publish the draft with SLUG, timestamping appropriately'
      puts '  unpublish  [PATH]    Move a post to _drafts, untimestampinging appropriately'
      exit
    end

    # Generate a timestamped post
    def post(title, slug=nil)
      usage if title.nil?

      slug ||= @helper.get_slug_for(title)
      date = @helper.get_date_stamp

      # put the metadata into the layout header
      head = @default_layout
      head.sub!(/^title:\s*$/, "title: #{title}")
      head.sub!(/^date:\s*$/, "date: #{date}")

      path = File.join(POSTS_FOLDER, "#{date}-#{slug}.md")
      f = File.open(path, "w").write(head)
    end

    # Generate a non-timestamped draft
    def draft(title, slug=nil)
      # the drafts folder might not exist yet...create it just in case
      FileUtils.mkdir_p(DRAFTS_FOLDER)

      slug ||= @helper.get_slug_for(title)

      head = @default_layout
      head.sub!(/^title:\s*$/, "title: #{title}")

      path = File.join(DRAFTS_FOLDER, "#{slug}.md")
      f = File.open(path, "w").write(head)
    end


  end
end

=begin

# Generate a new draft

def publish(slug)
  usage if slug.nil?

  inpath = "#{DRAFTS_FOLDER}/#{slug}.md"
  infile = File.open(inpath, "r")

  date = get_date
  outpath = "#{POSTS_FOLDER}/#{date}-#{slug}.md"
  outfile = File.open(outpath, "w")

  infile.each_line do |line|
    l = line.sub(/^date:\s*$/, "date: #{date} #{get_time}\n")
    outfile.write(l)
  end

  infile.close
  outfile.close
  FileUtils.rm(inpath)
end

def unpublish(inpath)
  usage if inpath.nil?

  outpath = "#{DRAFTS_FOLDER}/" << inpath.sub(/.*?\d{4}-\d{2}-\d{2}-(.*)/, '\1')
  infile = File.open(inpath, "r")
  outfile = File.open(outpath, "w")

  infile.each_line do |line|
    l = line.sub(/^date:\s*.*$/, "date:")
    outfile.write(l)
  end

  infile.close
  outfile.close
  FileUtils.rm(inpath)
end

def usage
  exit
end

parse_opts()

=end
