require 'spec_helper'

require 'mr_poole'
require 'fileutils'
require 'tmpdir'
require 'stringio'

module MrPoole
  describe CLI do

    context 'should determine jekyll dir correctly' do

      it 'should exit with no _posts directory' do
        olddir, tmpdir = make_no_jekyll_dir

        argv = []
        output = capture_stdout do
          lambda { cli = CLI.new(argv) }.should raise_error SystemExit
        end

        clean_tmp_files(tmpdir, olddir)
      end

      it 'should not exit with _posts directory' do
        olddir, tmpdir = make_jekyll_dir

        argv = []
        lambda {
          cli = CLI.new(argv)
        }.should_not raise_error

        clean_tmp_files(tmpdir, olddir)
      end

    end   # end context

  end
end
