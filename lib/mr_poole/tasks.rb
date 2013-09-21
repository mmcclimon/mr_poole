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
    def post(title, slug='')
      date = @helper.get_date_stamp

      # still want to escape any garbage in the slug
      slug = title if slug.nil? || slug.empty?
      slug = @helper.get_slug_for(slug)

      # put the metadata into the layout header
      head = @default_layout
      head.sub!(/^title:\s*$/, "title: #{title}")
      head.sub!(/^date:\s*$/, "date: #{date}")

      path = File.join(POSTS_FOLDER, "#{date}-#{slug}.md")
      f = File.open(path, "w")
      f.write(head)
      f.close

      path    # return the path, in case we want to do anything useful
    end

    # Generate a non-timestamped draft
    def draft(title, slug='')
      # the drafts folder might not exist yet...create it just in case
      FileUtils.mkdir_p(DRAFTS_FOLDER)

      slug = title if slug.nil? || slug.empty?
      slug = @helper.get_slug_for(slug)

      head = @default_layout
      head.sub!(/^title:\s*$/, "title: #{title}")

      path = File.join(DRAFTS_FOLDER, "#{slug}.md")
      f = File.open(path, "w")
      f.write(head)
      f.close

      path    # return the path, in case we want to do anything useful
    end

    # Todo make this take a path instead?
    def publish(draftpath)
      slug = File.basename(draftpath, '.md')
      infile = File.open(draftpath, "r")

      date = @helper.get_date_stamp
      time = @helper.get_time_stamp

      outpath = File.join(POSTS_FOLDER, "#{date}-#{slug}.md")
      outfile = File.open(outpath, "w")

      infile.each_line do |line|
        l = line.sub(/^date:\s*$/, "date: #{date} #{time}\n")
        outfile.write(l)
      end

      infile.close
      outfile.close
      FileUtils.rm(draftpath)

      outpath
    end

    def unpublish(inpath)
      # the drafts folder might not exist yet...create it just in case
      FileUtils.mkdir_p(DRAFTS_FOLDER)

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

      outpath
    end

  end
end
