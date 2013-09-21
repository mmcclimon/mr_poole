require 'spec_helper'

require 'mr_poole'
require 'fileutils'
require 'stringio'

module MrPoole
  describe CLI do

    context 'should determine jekyll dir correctly' do

      it 'should exit with no _posts directory' do
        olddir, tmpdir = make_no_jekyll_dir

        argv = []
        output = capture_stdout do
          begin
            cli = CLI.new(argv)
          rescue SystemExit => e
            e.should be_instance_of(SystemExit)
          end
        end

        clean_tmp_files(tmpdir, olddir)
      end

      it 'should not exit with _posts directory' do
        olddir, tmpdir = make_jekyll_dir

        argv = []
        lambda { cli = CLI.new(argv) }.should_not raise_error

        clean_tmp_files(tmpdir, olddir)
      end

    end   # end context determine jekyll dir

    describe "action 'post'" do

      before :each do
        @olddir, @tmpdir = make_jekyll_dir
      end

      after :each do
        clean_tmp_files(@tmpdir, @olddir)
      end

      context 'error handling' do

        it 'should fail with no arguments' do
          argv = ['post']

          expect {
            poole_with_args_no_stdout(argv).call
          }.to raise_error(SystemExit)
        end

        it 'should fail with no title (with slug)' do
          argv = ['post', '-s', 'post_slug']

          expect {
            poole_with_args_no_stdout(argv).call
          }.to raise_error(SystemExit)
        end

        it 'should not fail with a title (no switch)' do
          argv = ['post', 'Here is a title']

          expect {
            poole_with_args_no_stdout(argv).call
          }.not_to raise_error
        end

        it 'should not fail with a title (long switch)' do
          argv = ['post', '--title', 'Here is a title']

          expect {
            poole_with_args_no_stdout(argv).call
          }.not_to raise_error
        end

        it 'should not fail with a title (short switch)' do
          argv = ['post', '-t', 'Here is a title']

          expect {
            poole_with_args_no_stdout(argv).call
          }.not_to raise_error
        end

      end   # context error handling

      context 'exit message' do

        it 'should exit with a usage message' do
          argv = ['post']

          output = capture_stdout do
            begin
              poole_with_args(argv).call
            rescue SystemExit => e
              # this will fail, but we want the exit message
            end
          end

          output.should match(/Usage:\s+poole post/)
        end

      end   # context exit message

    end   # end describe post

    describe "action 'draft'" do

      before :each do
        @olddir, @tmpdir = make_jekyll_dir
      end

      after :each do
        clean_tmp_files(@tmpdir, @olddir)
      end

      context 'error handling' do

        it 'should fail with no arguments' do
          argv = ['draft']

          expect {
            poole_with_args_no_stdout(argv).call
          }.to raise_error(SystemExit)
        end

        it 'should fail with no title (with slug)' do
          argv = ['draft', '-s', 'draft_slug']

          expect {
            poole_with_args_no_stdout(argv).call
          }.to raise_error(SystemExit)
        end

        it 'should not fail with a title (no switch)' do
          argv = ['draft', 'Here is a title']

          expect {
            poole_with_args_no_stdout(argv).call
          }.not_to raise_error
        end

        it 'should not fail with a title (long switch)' do
          argv = ['draft', '--title', 'Here is a title']

          expect {
            poole_with_args_no_stdout(argv).call
          }.not_to raise_error
        end

        it 'should not fail with a title (short switch)' do
          argv = ['draft', '-t', 'Here is a title']

          expect {
            poole_with_args_no_stdout(argv).call
          }.not_to raise_error
        end

      end   # context error handling

      context 'exit message' do

        it 'should exit with a usage message' do
          argv = ['draft']

          output = capture_stdout do
            begin
              poole_with_args(argv).call
            rescue SystemExit
              # this will fail, but we want the exit message
            end
          end

          output.should match(/Usage:\s+poole draft/)
        end

      end   # context exit message

    end   # end describe draft

    describe "action 'publish'" do
      before :each do
        @olddir, @tmpdir = make_jekyll_dir
        @c = Commands.new
        @d_path = @c.draft({title: 'test_draft'})
      end

      after :each do
        clean_tmp_files(@tmpdir, @olddir)
      end

      context 'error handling' do

        it 'should fail with no arguments' do
          argv = ['publish']

          expect {
            poole_with_args_no_stdout(argv).call
          }.to raise_error(SystemExit)
        end

        it 'should fail with a bad path' do
          argv = ['publish', '_drafts/does_not_exist.md']

          expect {
            poole_with_args_no_stdout(argv).call
          }.to raise_error(SystemExit)
        end

        it 'should not fail with a good path' do
          argv = ['publish', @d_path]

          expect {
            poole_with_args_no_stdout(argv).call
          }.not_to raise_error
        end

      end   # context error handling

      context 'exit message' do

        it 'should exit with usage with no arguments' do
          argv = ['publish']

          output = capture_stdout do
            begin
              poole_with_args(argv).call
            rescue SystemExit
            end
          end

          output.should match(/Usage:\s+poole publish/)
        end

        it 'should exit with a description of bad path' do
          argv = ['publish', '_drafts/does_not_exist.md']

          output = capture_stdout do
            begin
              poole_with_args(argv).call
            rescue SystemExit
            end
          end

          output.should match(/Error:\s+could not open/)
        end
      end   # context exit message

    end

    describe "action 'unpublish'" do
      before :each do
        @olddir, @tmpdir = make_jekyll_dir
        @c = Commands.new
        @p_path = @c.post({title: 'test_post'})
      end

      after :each do
        clean_tmp_files(@tmpdir, @olddir)
      end

      context 'error handling' do

        it 'should fail with no arguments' do
          argv = ['unpublish']

          expect {
            poole_with_args_no_stdout(argv).call
          }.to raise_error(SystemExit)
        end

        it 'should fail with a bad path' do
          argv = ['unpublish', '_posts/does_not_exist.md']

          expect {
            poole_with_args_no_stdout(argv).call
          }.to raise_error(SystemExit)
        end

        it 'should not fail with a good path' do
          argv = ['unpublish', @p_path]

          expect {
            poole_with_args_no_stdout(argv).call
          }.not_to raise_error
        end

      end   # context error handling

      context 'exit message' do

        it 'should exit with usage with no arguments' do
          argv = ['unpublish']

          output = capture_stdout do
            begin
              poole_with_args(argv).call
            rescue SystemExit
            end
          end

          output.should match(/Usage:\s+poole unpublish/)
        end

        it 'should exit with a description of bad path' do
          argv = ['unpublish', '_posts/does_not_exist.md']

          output = capture_stdout do
            begin
              poole_with_args(argv).call
            rescue SystemExit
            end
          end

          output.should match(/Error:\s+could not open/)
        end
      end   # context exit message


    end   # action unpublish

  end
end
