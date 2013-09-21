require 'fileutils'
require 'shellwords'

module MrPoole
  class Tasks

    POSTS_FOLDER = '_posts'
    DRAFTS_FOLDER = '_drafts'

    def initialize
      @helper = Helper.new
      @default_layout = @helper.get_default_layout
    end

    # Generate a timestamped post
    def post(title, slug=nil)
      slug ||= title
      date = @helper.get_date_stamp

      # still want to escape any garbage in the slug
      slug = @helper.get_slug_for(slug)

      # put the metadata into the layout header
      head = @default_layout
      head.sub!(/^title:\s*$/, "title: #{title}")
      head.sub!(/^date:\s*$/, "date: #{date}")

      path = File.join(POSTS_FOLDER, "#{date}-#{slug}.md")
      f = File.open(path, "w")
      f.write(head)
      f.close
    end

    # Generate a non-timestamped draft
    def draft(title, slug=nil)
      # the drafts folder might not exist yet...create it just in case
      FileUtils.mkdir_p(DRAFTS_FOLDER)

      slug ||= @helper.get_slug_for(title)

      head = @default_layout
      head.sub!(/^title:\s*$/, "title: #{title}")

      path = File.join(DRAFTS_FOLDER, "#{slug}.md")
      f = File.open(path, "w")
      f.write(head)
      f.close
    end

    # Todo make this take a path instead?
    def publish(slug)
      @helper.publish_usage if slug.nil?

      inpath = File.join(DRAFTS_FOLDER, "#{slug}.md")
      infile = File.open(inpath, "r")

      date = @helper.get_date_stamp
      time = @helper.get_time_stamp

      outpath = File.join(POSTS_FOLDER, "#{date}-#{slug}.md")
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
      @helper.unpublish_usage if inpath.nil?

      slug = inpath.sub(/.*?\d{4}-\d{2}-\d{2}-(.*)/, '\1')
      outpath = File.join(DRAFTS_FOLDER, slug)

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

  end
end
