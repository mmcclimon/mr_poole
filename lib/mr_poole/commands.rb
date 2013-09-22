require 'fileutils'

module MrPoole
  class Commands

    POSTS_FOLDER = '_posts'
    DRAFTS_FOLDER = '_drafts'

    def initialize(extension='md')
      @helper = Helper.new
      @ext = extension
    end

    # Generate a timestamped post
    def post(opts)
      date = @helper.get_date_stamp

      # still want to escape any garbage in the slug
      slug = if opts[:slug].nil? || opts[:slug].empty?
               opts[:title]
             else
               opts[:slug]
             end
      slug = @helper.get_slug_for(slug)

      # put the metadata into the layout header
      head, ext = @helper.get_layout(opts[:layout])
      head.sub!(/^title:\s*$/, "title: #{opts[:title]}")
      head.sub!(/^date:\s*$/, "date: #{date}")
      ext ||= @ext

      path = File.join(POSTS_FOLDER, "#{date}-#{slug}.#{ext}")
      f = File.open(path, "w")
      f.write(head)
      f.close

      path    # return the path, in case we want to do anything useful
    end

    # Generate a non-timestamped draft
    def draft(opts)
      # the drafts folder might not exist yet...create it just in case
      FileUtils.mkdir_p(DRAFTS_FOLDER)

      slug = if opts[:slug].nil? || opts[:slug].empty?
               opts[:title]
             else
               opts[:slug]
             end
      slug = @helper.get_slug_for(slug)

      # put the metadata into the layout header
      head, ext = @helper.get_layout(opts[:layout])
      head.sub!(/^title:\s*$/, "title: #{opts[:title]}")
      ext ||= @ext

      path = File.join(DRAFTS_FOLDER, "#{slug}.#{ext}")
      f = File.open(path, "w")
      f.write(head)
      f.close

      path    # return the path, in case we want to do anything useful
    end

    # Todo make this take a path instead?
    def publish(draftpath)
      tail = File.basename(draftpath)

      begin
        infile = File.open(draftpath, "r")
      rescue Errno::ENOENT
        @helper.bad_path(draftpath)
      end

      date = @helper.get_date_stamp
      time = @helper.get_time_stamp

      outpath = File.join(POSTS_FOLDER, "#{date}-#{tail}")
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

      begin
        infile = File.open(inpath, "r")
      rescue Errno::ENOENT
        @helper.bad_path(inpath)
      end

      slug = inpath.sub(/.*?\d{4}-\d{2}-\d{2}-(.*)/, '\1')
      outpath = File.join(DRAFTS_FOLDER, slug)
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
