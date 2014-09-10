# encoding: UTF-8
require 'rspec/autorun'
require File.expand_path('../spec_helper', __FILE__)
require File.expand_path('../../lib/mr_poole', __FILE__)

module MrPoole
  describe Commands do

    let(:date_regex) { %r{\d{4}-\d{2}-\d{2}} }
    let(:c) { Commands.new }
    before(:each) { @olddir, @tmpdir = make_jekyll_dir }
    after(:each) { clean_tmp_files(@tmpdir, @olddir) }

    describe "#post" do
      context 'title only' do
        it "creates a new post in the _posts directory" do
          fn = c.post({:title => "test_post"})
          expect(File.exists?(fn)).to be true
        end

        it "returns path to the newly created post" do
          returned = c.post({:title => "test_post"})
          determined = Dir.glob("_posts/*.md").first
          expect(returned).to eq(determined)
        end

        it "creates a timestamped post in the _posts directory" do
          fn = c.post({:title => "test_post" })
          expect(fn).to match(/#{date_regex}-test_post[.]md$/)
        end

        it "downcases a title" do
          fn = c.post({:title => "Test_Post_With_Uppercase"})
          expect(fn).to match(/#{date_regex}-test_post_with_uppercase[.]md/)
        end

        it "subs underscores for spaces in title" do
          fn = c.post({:title => "Test Post with Spaces"})
          expect(fn).to match(/#{date_regex}-test_post_with_spaces[.]md/)
        end

        it "removes non-word characters for slug" do
          fn = c.post({:title => "On (function() {}()) in JavaScript"})
          expect(fn).to match(/#{date_regex}-on_function_in_javascript[.]md/)
        end

        it "updates the title in the file itself" do
          fn = c.post({:title => "Testing Post {}"})
          content = File.open(fn, 'r').read
          expect(content).to match(/title: Testing Post \{\}/)
        end

        it "updates the date in the file itself" do
          fn = c.post({:title => "Date test post"})

          # date in filename should match date in file itself
          date = fn.match(/(#{date_regex})-date_test_post[.]md/)[1]
          content = File.open(fn, 'r').read
          expect(content).to match(/date: #{date}/)
        end
      end   # end context title only

      context 'title and slug' do
        it "creates a post named for slug" do
          fn = c.post({:title => "Test Post", :slug => 'unique_slug'})
          expect(fn).to match(/#{date_regex}-unique_slug[.]md$/)
        end

        it "subs any weird characters in slug" do
          fn = c.post({:title => "Test Post with Spaces", :slug => "(stupid] {slüg/"})
          expect(fn).to match(/#{date_regex}-stupid_slg[.]md/)
        end

        it "updates the title in the file itself" do
          fn = c.post({:title => "Testing Post {}", :slug => 'shouldnt_be_in_title'})
          content = File.open(fn, 'r').read
          expect(content).to match(/title: Testing Post \{\}/)
        end
      end   # end context title & slug

      context 'with custom layout' do
        let(:layout_path) { write_custom_layout }

        it "exits if layout path doesn't exist" do
          expect {
            capture_stdout do
              c.post({:title => 'test_post', :layout => 'bogus_path.md'})
            end
          }.to raise_error(SystemExit)
        end

        it 'does not use the default layout' do
          fn = c.post({:title => 'test_post', :layout => layout_path})
          content = File.open(fn, 'r').read
          expect(content).not_to match(/layout: post/)
        end

        it 'uses the custom layout' do
          fn = c.post({:title => 'test_post', :layout => layout_path})
          content = File.open(fn, 'r').read
          expect(content).to match(/tags: testing/)
        end
      end   # context custom layout
    end   # end describe post

    describe "#draft" do
      context 'title only' do
        it "creates a _drafts directory" do
          c.draft({:title => 'draft post'})
          expect(File.exists?('_drafts')).to be true
        end

        it "returns path to the newly created draft" do
          returned = c.draft({:title => "test_draft"})
          determined = Dir.glob("_drafts/*.md").first
          expect(returned).to eq(determined)
        end

        it "creates a new draft in the _drafts directory" do
          fn = c.draft({:title => 'draft post'})
          expect(File.exists?(fn)).to be true
        end

        it "creates a non-timestamped draft" do
          fn = c.draft({:title => 'draft post'})
          expect(fn).not_to match(/#{date_regex}/)
        end

        it "downcases and underscore title for slug" do
          fn = c.draft({:title => "Test Post with Spaces"})
          expect(fn).to match(/test_post_with_spaces[.]md/)
        end

        it "removes non-word characters for slug" do
          fn = c.draft({:title => "On (function() {}()) in JavaScript"})
          expect(fn).to match(/on_function_in_javascript[.]md/)
        end

        it "updates the title in the file itself" do
          fn = c.draft({:title => "Testing Draft {}"})
          content = File.open(fn, 'r').read
          expect(content).to match(/title: Testing Draft \{\}/)
        end

        it "does not update the date in the file itself" do
          fn = c.draft({:title => "Date test post"})
          content = File.open(fn, 'r').read
          expect(content).to match(/date: #{date_regex}/)
        end
      end   # end context title only

      context 'title and slug' do
        it "creates a draft named for slug" do
          fn = c.draft({:title => "Test Draft", :slug => 'unique_slug'})
          expect(fn).to match(/unique_slug[.]md$/)
        end

        it "subs any weird characters in slug" do
          fn = c.draft({:title => "Test Post with Spaces", :slug => "(stupid] {slüg/"})
          expect(fn).to match(/stupid_slg[.]md/)
        end

        it "updates the title in the file itself" do
          fn = c.draft({:title => "Testing Post {}", :slug => 'shouldnt_be_in_title'})
          content = File.open(fn, 'r').read
          expect(content).to match(/title: Testing Post \{\}/)
        end
      end   # context title & slug

      context 'with custom layout' do
        let(:layout_path) { write_custom_layout }

        it "exits if layout path doesn't exist" do
          expect {
            capture_stdout do
              c.draft({:title => 'test_post', :layout => 'bogus_path.md'})
            end
          }.to raise_error(SystemExit)
        end

        it 'does not use the default layout' do
          fn = c.draft({:title => 'test_post', :layout => layout_path})
          content = File.open(fn, 'r').read
          expect(content).not_to match(/layout: post/)
        end

        it 'uses the custom layout' do
          fn = c.draft({:title => 'test_post', :layout => layout_path})
          content = File.open(fn, 'r').read
          expect(content).to match(/tags: testing/)
        end
      end   # context custom layout
    end   # end describe draft

    describe "#publish" do
      let(:d_path) { c.draft({:title => 'test_draft'}) }

      it 'returns path to newly created post' do
        returned = c.publish(d_path)
        determined = Dir.glob("_posts/*.md").first
        expect(returned).to eq(determined)
      end

      it 'creates a timestamped post in the _posts folder' do
        fn = c.publish(d_path)
        expect(fn).to match(/#{date_regex}-test_draft[.]md$/)
      end

      it 'removes file in the _drafts folder' do
        c.publish(d_path)
        expect(File.exist?(d_path)).to be false
      end

      it 'creates post with matching slug' do
        post = c.publish(d_path)
        draft_slug = File.basename(d_path, '.md')
        post_slug = post.match(/#{date_regex}-(.*)[.]md/)[1]
        expect(post_slug).to eq(draft_slug)
      end

      it 'updates timestamp in actual file' do
        post = c.publish(d_path)
        content = File.open(post, 'r').read
        expect(content).to match(/date: #{date_regex} \d{2}:\d{2}\n/)
      end

      it 'copies contents of draft into post' do
        # first add some content to the draft
        f = File.open(d_path, 'a')
        f.write("Some new content for my blog\n")
        f.close

        post = c.publish(d_path)
        content = File.open(post, 'r').read
        expect(content).to match(/Some new content for my blog/)
      end
    end   # end describe publish

    describe "#unpublish" do
      let(:p_path) { c.post({:title => 'test_post'}) }

      it 'returns path to newly created draft' do
        returned = c.unpublish(p_path)
        determined = Dir.glob("_drafts/*.md").first
        expect(returned).to eq(determined)
      end

      it 'creates a _drafts directory' do
        c.unpublish(p_path)
        expect(File.exists?('_drafts')).to be true
      end

      it 'creates an untimestamped draft in the _drafts folder' do
        fn = c.unpublish(p_path)
        expect(fn).not_to match(/#{date_regex}/)
      end

      it 'removes file in the _posts folder' do
        c.unpublish(p_path)
        expect(File.exist?(p_path)).to be false
      end

      it 'creates draft with matching slug' do
        draft = c.unpublish(p_path)
        post_slug = p_path.match(/#{date_regex}-(.*)[.]md$/)[1]
        draft_slug = File.basename(draft, '.md')
        expect(draft_slug).to eq(post_slug)
      end

      it 'deletes timestamp in actual file' do
        draft = c.unpublish(p_path)
        content = File.open(draft, 'r').read
        expect(content).to match(/date:\s*\n/)
      end

      it 'copies contents of post into draft' do
        # first add some content to the draft
        f = File.open(p_path, 'a')
        f.write("Some new content for my blog\n")
        f.close

        draft = c.unpublish(p_path)
        content = File.open(draft, 'r').read
        expect(content).to match(/Some new content for my blog/)
      end

    end   # end describe unpublish

    context 'with custom extension' do
      let(:commands) { Commands.new('textile') }

      it 'uses custom extension for post' do
        fn = commands.post({:title => 'post title'})
        expect(fn).to match(/textile$/)
      end

      it 'uses custom extension for draft' do
        fn = commands.draft({:title => 'post title'})
        expect(fn).to match(/textile$/)
      end

      it 'uses custom extension for publish' do
        draft_path = commands.draft({:title => 'post title'})
        fn = commands.publish(draft_path)
        expect(fn).to match(/textile$/)
      end

      it 'uses custom extension for unpublish' do
        post_path = commands.post({:title => 'post title'})
        fn = commands.unpublish(post_path)
        expect(fn).to match(/textile$/)
      end
    end   # end context custom extension

    context 'with layout override' do
      it "inherit layout's file extension for post" do
        layout_path = write_custom_layout_textile
        fn = c.post({:title => 'post title', :layout => layout_path})
        expect(fn).not_to match(/md/)
        expect(fn).to match(/textile$/)
      end

      it "inherits layout's file extension for draft" do
        layout_path = write_custom_layout_textile
        fn = c.draft({:title => 'post title', :layout => layout_path})
        expect(fn).not_to match(/md/)
        expect(fn).to match(/textile$/)
      end

      it "inherits draft's extension for pubilsh" do
        layout_path = write_custom_layout_textile
        draft_path = c.draft({:title => 'post title', :layout => layout_path})
        fn = c.publish(draft_path)
        expect(fn).not_to match(/md/)
        expect(fn).to match(/textile$/)
      end

      it "inherits post's extension for unpublish" do
        layout_path = write_custom_layout_textile
        post_path = c.post({:title => 'post title', :layout => layout_path})
        fn = c.publish(post_path)
        expect(fn).not_to match(/md/)
        expect(fn).to match(/textile$/)
      end
    end   # end context layout override

    context 'with custom word_separator' do
      before(:each) { write_config_file_custom_word_sep }

      it "uses hyphens for post" do
        fn = c.post({:title => "Test Post with Spaces"})
        expect(fn).to match(/test-post-with-spaces[.]md/)
      end

      it "uses hyphens for draft" do
        fn = c.draft({:title => "On (function() {}()) in JavaScript"})
        expect(fn).to match(/on-function-in-javascript[.]md/)
      end

      it "is overidden by explicit slug" do
        fn = c.post({:title => "Test Post", :slug => 'unique_slug'})
        expect(fn).to match(/unique_slug[.]md$/)
      end

    end   # end context custom word separator
  end
end
