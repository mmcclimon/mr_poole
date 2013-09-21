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

def poole_with_args(argv)
  return Proc.new do
    action = argv.shift
    cli = MrPoole::CLI.new(argv)
    cli.execute(action)
  end
end

def poole_with_args_no_stdout(argv)
  return Proc.new do
    capture_stdout do
      action = argv.shift
      cli = MrPoole::CLI.new(argv)
      cli.execute(action)
    end
  end
end

def write_custom_layout
  filename = 'custom_layout.md'
  f = File.open(filename, 'w')
  f.puts '---'
  f.puts 'title:'
  f.puts 'date:'
  f.puts 'tags: testing'
  f.puts '---'
  f.puts ''
  f.close

  filename
end
