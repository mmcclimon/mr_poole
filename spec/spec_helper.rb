#!/usr/bin/env ruby

require 'stringio'
require 'tmpdir'
require 'fileutils'

def capture_stdout(&block)
  stdout = $stdout
  fake_out = StringIO.new
  $stdout = fake_out
  begin
    yield
  ensure
    $stdout = stdout
  end
  fake_out.string
end

def make_no_jekyll_dir
  olddir = Dir.pwd()
  newdir = Dir.mktmpdir('nojekyll')
  Dir.chdir(newdir)
  return olddir, newdir
end

def make_jekyll_dir
  olddir = Dir.pwd()
  newdir = Dir.mktmpdir('jekyll')
  posts = File.join(newdir, '_posts')
  Dir.mkdir(posts)
  Dir.chdir(newdir)
  return olddir, newdir

end

def clean_tmp_files(tmpdir, restoredir)
  Dir.chdir(restoredir)
  FileUtils.rm_rf(tmpdir)
end
