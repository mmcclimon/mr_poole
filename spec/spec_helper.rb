#!/usr/bin/env ruby

require 'stringio'
require 'tmpdir'
require 'fileutils'

if RUBY_VERSION > '1.9'
  require 'coveralls'
  Coveralls.wear!
end

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

def make_irregular_jekyll_dir
  olddir = Dir.pwd()
  newdir = Dir.mktmpdir('jekyll')
  srcdir = File.join(newdir, 'src')
  posts = File.join(srcdir, '_posts')
  drafts = File.join(srcdir, '_drafts')
  Dir.mkdir(srcdir)
  Dir.mkdir(posts)
  Dir.mkdir(drafts)
  Dir.chdir(newdir)
  # ensure write custom yml file
  write_config_file_custom_src_dir
  return olddir, newdir
end

# make a dir with a custom source dir but with no _posts directory
def make_bad_irregular_jekyll_dir
  olddir = Dir.pwd()
  newdir = Dir.mktmpdir('jekyll')
  srcdir = File.join(newdir, 'src')
  Dir.mkdir(srcdir)
  Dir.chdir(newdir)
  # ensure write custom yml file
  write_config_file_custom_src_dir
  return olddir, newdir
end

def clean_tmp_files(tmpdir, restoredir)
  Dir.chdir(restoredir)
  FileUtils.rm_rf(tmpdir)
end

def poole(argv)
  return Proc.new do
    action = argv.shift
    cli = MrPoole::CLI.new(argv)
    cli.execute(action)
  end
end

def poole_no_stdout(argv)
  return Proc.new do
    capture_stdout do
      action = argv.shift
      cli = MrPoole::CLI.new(argv)
      cli.execute(action)
    end
  end
end

# This captures SystemExit exceptions and returns stdout
def aborted_poole_output(argv)
  return Proc.new do
    output = capture_stdout do
      begin
        action = argv.shift
        cli = MrPoole::CLI.new(argv)
        cli.execute(action)
      rescue SystemExit
      end
    end
    output
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

def write_custom_layout_textile
  filename = 'custom_layout.textile'
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

def write_config_file_custom_layout
  filename = 'default_layout.md'

  l = File.open(filename, 'w')
  l.puts '---'
  l.puts 'title:'
  l.puts 'date:'
  l.puts 'tags: from_config'
  l.puts '---'
  l.puts ''
  l.close

  c = File.open('_config.yml', 'w')
  c.puts 'poole:'
  c.puts "  default_layout: #{filename}"
  c.close

  filename
end

def write_config_file_custom_extension
  c = File.open('_config.yml', 'w')
  c.puts 'poole:'
  c.puts "  default_extension: textile"
  c.close
end

def write_config_file_custom_src_dir
  c = File.open('_config.yml', 'w')
  c.puts 'source: src'
  c.close
end
