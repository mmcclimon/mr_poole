require 'rspec/autorun'
require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/mr_poole', __FILE__)

module MrPoole
  describe CLI do

    context 'should determine jekyll dir correctly' do
      it 'should exit with no _posts directory' do
        olddir, tmpdir = make_no_jekyll_dir
        expect {capture_stdout { cli = CLI.new([]) }}.to raise_error(SystemExit)
        clean_tmp_files(tmpdir, olddir)
      end

      it 'should not exit with _posts directory' do
        olddir, tmpdir = make_jekyll_dir
        expect { cli = CLI.new([]) }.not_to raise_error
        clean_tmp_files(tmpdir, olddir)
      end

      context 'with _config.yml' do

        it "should not exit if _config.yml has 'source' key" do
          olddir, tmpdir = make_irregular_jekyll_dir
          expect { cli = CLI.new([]) }.not_to raise_error
          clean_tmp_files(tmpdir, olddir)
        end

        it "should exit if custom src dir doesn't have _posts dir" do
          olddir, tmpdir = make_bad_irregular_jekyll_dir
          expect {
            capture_stdout { cli = CLI.new([]) }
          }.to raise_error(SystemExit)
          clean_tmp_files(tmpdir, olddir)
        end
      end
    end   # context determine jekyll dir

    context 'no correct action' do
      before(:each) { @olddir, @tmpdir = make_jekyll_dir }
      after(:each) { clean_tmp_files(@tmpdir, @olddir) }

      it 'prints help message with no action' do
        argv = []
        output = aborted_poole_output(argv).call
        expect(output).to match(/poole \[ACTION\] \[ARG\]/)
      end

      it 'prints help message with unknown action' do
        argv = ['bogusify']
        output = aborted_poole_output(argv).call
        expect(output).to match(/poole \[ACTION\] \[ARG\]/)
      end

    end

    context 'version switch' do
      before(:each) { @olddir, @tmpdir = make_jekyll_dir }
      after(:each) { clean_tmp_files(@tmpdir, @olddir) }

      it 'prints version and exits with --version' do
        argv = ['--version']
        output = aborted_poole_output(argv).call
        expect(output).to match(/Mr[.] Poole, version /)
      end

      it 'prints version and exits with -v' do
        argv = ['-v']
        output = aborted_poole_output(argv).call
        expect(output).to match(/Mr[.] Poole, version /)
      end

    end
    describe "action 'post'" do
      before(:each) { @olddir, @tmpdir = make_jekyll_dir }
      after(:each) { clean_tmp_files(@tmpdir, @olddir) }

      context 'error handling' do
        it 'should fail with no arguments' do
          argv = ['post']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end

        it 'should fail with no title (with slug)' do
          argv = ['post', '-s', 'post_slug']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end

        it 'should not fail with a title (no switch)' do
          argv = ['post', 'Here is a title']
          expect { poole_no_stdout(argv).call }.not_to raise_error
        end

        it 'should not fail with a title (long switch)' do
          argv = ['post', '--title', 'Here is a title']
          expect { poole_no_stdout(argv).call }.not_to raise_error
        end

        it 'should not fail with a title (short switch)' do
          argv = ['post', '-t', 'Here is a title']
          expect { poole_no_stdout(argv).call }.not_to raise_error
        end
      end   # context error handling

      context 'exit message' do
        it 'exits with a usage message on fail' do
          argv = ['post']
          output = aborted_poole_output(argv).call
          expect(output).to match(/Usage:\s+poole post/)
        end

        it 'echoes path to newly created post on success' do
          argv = ['post', 'post title']
          output = poole_no_stdout(argv).call.chomp
          determined = Dir.glob("./_posts/*.md").first
          expect(output).to eq(determined)
        end

      end   # context exit message

      context 'custom layout' do
        let(:layout_path) { write_custom_layout }

        it 'should use custom layout with --layout' do
          argv = ['post', '--layout', layout_path, '--title', 'title']
          new_file = poole_no_stdout(argv).call.chomp
          content = File.open(new_file, 'r').read
          expect(content).to match(/tags: testing/)
        end

        it 'should exit with bad layout path' do
          argv = ['post', '--layout', 'bogus_path.md', 'title']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end
      end   # context custom layout

      context 'default_layout in config file' do
        before(:each) { write_config_file_custom_layout }

        it 'overrides default layout' do
          argv = ['post', 'post title']
          new_file = poole_no_stdout(argv).call.chomp
          content = File.open(new_file, 'r').read
          expect(content).to match(/tags: from_config/)
        end

        it 'is overridden by command-line layout switch' do
          custom_path = write_custom_layout

          argv = ['post', '--layout', custom_path, '--title', 'title']
          new_file = poole_no_stdout(argv).call.chomp
          content = File.open(new_file, 'r').read
          expect(content).not_to match(/tags: from_config/)
          expect(content).to match(/tags: testing/)
        end
      end   # default layout in config

    end   # end describe post

    describe "action 'draft'" do
      before(:each) { @olddir, @tmpdir = make_jekyll_dir }
      after(:each) { clean_tmp_files(@tmpdir, @olddir) }

      context 'error handling' do
        it 'should fail with no arguments' do
          argv = ['draft']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end

        it 'should fail with no title (with slug)' do
          argv = ['draft', '-s', 'draft_slug']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end

        it 'should not fail with a title (no switch)' do
          argv = ['draft', 'Here is a title']
          expect { poole_no_stdout(argv).call }.not_to raise_error
        end

        it 'should not fail with a title (long switch)' do
          argv = ['draft', '--title', 'Here is a title']
          expect { poole_no_stdout(argv).call }.not_to raise_error
        end

        it 'should not fail with a title (short switch)' do
          argv = ['draft', '-t', 'Here is a title']
          expect { poole_no_stdout(argv).call }.not_to raise_error
        end
      end   # context error handling

      context 'exit message' do
        it 'exits with a usage message' do
          argv = ['draft']
          output = aborted_poole_output(argv).call
          expect(output).to match(/Usage:\s+poole draft/)
        end

        it 'echoes path to newly created post on success' do
          argv = ['draft', 'post title']
          output = poole_no_stdout(argv).call.chomp
          determined = Dir.glob("./_drafts/*.md").first
          expect(output).to eq(determined)
        end
      end   # context exit message

      context 'custom layout' do
        let(:layout_path) { write_custom_layout }

        it 'should use custom layout with --layout' do
          argv = ['draft', '--layout', layout_path, '--title', 'title']
          poole_no_stdout(argv).call
          content = File.open(layout_path, 'r').read
          expect(content).to match(/tags: testing/)
        end

        it 'should exit with bad layout path' do
          argv = ['draft', '--layout', 'bogus_path.md', 'title']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end
      end   # end custom layout

      context 'default_layout in config file' do
        before(:each) { write_config_file_custom_layout }

        it 'overrides default layout' do
          argv = ['draft', 'post title']
          new_file = poole_no_stdout(argv).call.chomp
          content = File.open(new_file, 'r').read
          expect(content).to match(/tags: from_config/)
        end

        it 'is overridden by command-line layout switch' do
          custom_path = write_custom_layout

          argv = ['draft', '--layout', custom_path, '--title', 'title']
          new_file = poole_no_stdout(argv).call.chomp
          content = File.open(new_file, 'r').read
          expect(content).not_to match(/tags: from_config/)
          expect(content).to match(/tags: testing/)
        end
      end   # default layout in config

    end   # describe draft

    describe "action 'publish'" do
      let(:d_path) { Commands.new.draft({:title => 'test_draft'}) }
      before(:each) { @olddir, @tmpdir = make_jekyll_dir }
      after(:each) { clean_tmp_files(@tmpdir, @olddir) }

      context 'error handling' do
        it 'should fail with no arguments' do
          argv = ['publish']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end

        it 'should fail with a bad path' do
          argv = ['publish', '_drafts/does_not_exist.md']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end

        it 'should not fail with a good path' do
          argv = ['publish', d_path]
          expect { poole_no_stdout(argv).call }.not_to raise_error
        end
      end   # context error handling

      context 'exit message' do
        it 'should exit with usage with no arguments' do
          argv = ['publish']
          output = aborted_poole_output(argv).call
          expect(output).to match(/Usage:\s+poole publish/)
        end

        it 'should exit with a description of bad path' do
          argv = ['publish', '_drafts/does_not_exist.md']
          output = aborted_poole_output(argv).call
          expect(output).to match(/Error:\s+could not open/)
        end

        it 'echoes path to newly created post on success' do
          argv = ['publish', d_path]
          output = poole_no_stdout(argv).call.chomp
          determined = Dir.glob("./_posts/*.md").first
          expect(output).to eq(determined)
        end
      end   # context exit message

      context 'keep draft post' do
        it 'should keep draft post if called with --keep-draft' do
          argv = ['publish', '--keep-draft', d_path]
          poole_no_stdout(argv).call
          expect(File.exists?(d_path)).to be_true
        end
      end

      context 'keep timestamp' do
        it 'should keep the timestamp if called with --keep-timestamp' do
          argv = ['publish', '--keep-timestamp', d_path]
          new_file = poole_no_stdout(argv).call.chomp
          content = File.open(new_file, "r").read
          expect(content).to match(/^date: \d{4}-\d{2}-\d{2}$/)
        end
      end
    end   # describe publish

    describe "action 'unpublish'" do
      let(:p_path) { Commands.new.post({:title => 'test_post'}) }
      before(:each) { @olddir, @tmpdir = make_jekyll_dir }
      after(:each) { clean_tmp_files(@tmpdir, @olddir) }

      context 'error handling' do
        it 'should fail with no arguments' do
          argv = ['unpublish']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end

        it 'should fail with a bad path' do
          argv = ['unpublish', '_posts/does_not_exist.md']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end

        it 'should not fail with a good path' do
          argv = ['unpublish', p_path]
          expect { poole_no_stdout(argv).call }.not_to raise_error
        end
      end   # context error handling

      context 'exit message' do
        it 'should exit with usage with no arguments' do
          argv = ['unpublish']
          output = aborted_poole_output(argv).call
          expect(output).to match(/Usage:\s+poole unpublish/)
        end

        it 'should exit with a description of bad path' do
          argv = ['unpublish', '_posts/does_not_exist.md']
          output = aborted_poole_output(argv).call
          expect(output).to match(/Error:\s+could not open/)
        end

        it 'echoes path to newly created post on success' do
          argv = ['unpublish', p_path]
          output = poole_no_stdout(argv).call.chomp
          determined = Dir.glob("./_drafts/*.md").first
          expect(output).to eq(determined)
        end
      end   # context exit message

      context 'keep post' do
        it 'should not delete the post if called with --keep-post' do
          argv = ['unpublish', '--keep-post', p_path]
          poole_no_stdout(argv).call
          expect(File.exists?(p_path)).to be_true
        end

        it 'should not delete the post if called with -p' do
          argv = ['unpublish', '-p', p_path]
          poole_no_stdout(argv).call
          expect(File.exists?(p_path)).to be_true
        end
      end

      context 'keep timestamp' do
        it 'should not change timestamp if called with --keep-timestamp' do
          argv = ['unpublish', '--keep-timestamp', p_path]
          fn = poole_no_stdout(argv).call.chomp
          content = File.open(fn, 'r').read
          expect(content).to match(/^date: \d{4}-\d{2}-\d{2}/)
        end

        it 'should not change timestamp if called with -t' do
          argv = ['unpublish', '-t', p_path]
          fn = poole_no_stdout(argv).call.chomp
          content = File.open(fn, 'r').read
          expect(content).to match(/^date: \d{4}-\d{2}-\d{2}/)
        end
      end

    end   # context action unpublish

    context 'with default extension in config file' do
      before(:each) { @olddir, @tmpdir = make_jekyll_dir }
      before(:each) { write_config_file_custom_extension }
      after(:each) { clean_tmp_files(@tmpdir, @olddir) }

      it 'should override default extension for post' do
        argv = ['post', 'post title']
        fn = poole_no_stdout(argv).call
        expect(fn).to match(/textile$/)
      end

      it 'should not override if command-line layout given' do
        layout_path = write_custom_layout
        argv = ['post', '--layout', layout_path, '-t', 'title']
        fn = poole_no_stdout(argv).call
        expect(fn).to match(/md$/)
      end

      it 'should override default extension for draft' do
        argv = ['draft', 'post title']
        fn = poole_no_stdout(argv).call.chomp
        expect(fn).to match(/textile$/)
      end

    end

    context 'with custom source directory' do
      before(:each) do
        @olddir, @tmpdir = make_irregular_jekyll_dir
      end

      after(:each) { clean_tmp_files(@tmpdir, @olddir) }

      it "'post' echoes correct path with custom source directory" do
        argv = ['post', 'post_title']
        output = poole_no_stdout(argv).call.chomp
        determined = Dir.glob("src/_posts/*.md").first
        expect(output).to eq(determined)
      end

      it "'draft' echoes correct path with custom source directory" do
        argv = ['draft', 'post_title']
        output = poole_no_stdout(argv).call.chomp
        determined = Dir.glob("src/_drafts/*.md").first
        expect(output).to eq(determined)
      end

      it "'publish' echoes correct path with custom source directory" do
        # make a draft first
        Dir.chdir('src')
        draft_path = Commands.new.draft({:title => 'test_draft'})
        Dir.chdir('..')

        argv = ['publish', draft_path]
        output = poole_no_stdout(argv).call.chomp

        determined = Dir.glob("src/_posts/*.md").first
        expect(output).to eq(determined)
      end

      it "'unpublish' echoes correct path with custom source directory" do
        olddir, tmpdir = make_irregular_jekyll_dir

        # make a post in the src directory
        Dir.chdir('src')
        post_path = Commands.new.post({:title => 'touch_post'})
        Dir.chdir('..')

        argv = ['unpublish', post_path]
        output = poole_no_stdout(argv).call.chomp

        determined = Dir.glob("src/_drafts/*.md").first
        expect(output).to eq(determined)

        clean_tmp_files(tmpdir, olddir)
      end

    end
  end
end
