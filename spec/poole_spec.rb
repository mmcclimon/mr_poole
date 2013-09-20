require 'spec_helper'

require 'mr_poole'
require 'fileutils'
require 'tmpdir'
require 'stringio'

module MrPoole
  describe CLI do
    context 'no jekyll directory' do
      before :all do
        # make a directory to work in
        @olddir = Dir.pwd()
        @dir = Dir.mktmpdir('nojekyll')
        Dir.chdir(@dir)
      end

      after :all do
        Dir.chdir(@olddir)
        FileUtils.rm_rf(@dir)
      end

      it 'should exit with no _posts directory' do
        argv = []
        lambda {
          cli = CLI.new(argv)
        }.should raise_error SystemExit
      end
    end   # end context 'no jekyll'

    context 'in jekyll directory' do
      before :each do
        # make a directory to work in
        @olddir = Dir.pwd()
        @dir = Dir.mktmpdir('jekyll')
        posts = File.join(@dir, '_posts')
        Dir.mkdir(posts)
        Dir.chdir(@dir)
      end

      after :each do
        Dir.chdir(@olddir)
        FileUtils.rm_rf(@dir)
      end

      it "should not exit with _posts directory" do
        argv = []
        lambda {
          cli = CLI.new(argv)
        }.should_not raise_error
      end

    end   # end context 'in jekyll'

  end
end
