require 'spec_helper'
require 'mr_poole'

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
    end   # context determine jekyll dir

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

        it 'should exit with a usage message' do
          argv = ['post']
          output = aborted_poole_output(argv).call
          expect(output).to match(/Usage:\s+poole post/)
        end

      end   # context exit message

      context 'custom layout' do
        let(:layout_path) { write_custom_layout }

        it 'should use custom layout with --layout' do
          argv = ['post', '--layout', layout_path, '--title', 'title']
          poole_no_stdout(argv).call
          content = File.open(layout_path, 'r').read
          expect(content).to match(/tags: testing/)
        end

        it 'should exit with bad layout path' do
          argv = ['post', '--layout', 'bogus_path.md', 'title']
          expect { poole_no_stdout(argv).call }.to raise_error(SystemExit)
        end
      end   # context custom layout

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
        it 'should exit with a usage message' do
          argv = ['draft']
          output = aborted_poole_output(argv).call
          expect(output).to match(/Usage:\s+poole draft/)
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
    end   # end describe draft

    describe "action 'publish'" do
      let(:d_path) { Commands.new.draft({title: 'test_draft'}) }
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
      end   # context exit message

    end

    describe "action 'unpublish'" do
      let(:p_path) { Commands.new.post({title: 'test_post'}) }
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
      end   # context exit message


    end   # action unpublish

  end
end
