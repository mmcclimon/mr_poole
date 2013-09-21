require 'spec_helper'

require 'mr_poole'

module MrPoole
  describe Commands do

    before :all do
      @date_regex = %r{\d{4}-\d{2}-\d{2}}
    end

    before :each do
      @c = Commands.new
      @olddir, @tmpdir = make_jekyll_dir
    end

    after :each do
      clean_tmp_files(@tmpdir, @olddir)
    end

    describe "#post" do
      context 'title only' do

        it "should create a new post in the _posts directory" do
          @c.post({title: "test_post"})
          Dir.glob("_posts/*.md").length.should == 1
        end

        it "should create a timestamped post in the _posts directory" do
          @c.post({title: "test_post" })
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-test_post[.]md$/)
        end

        it "should return path to the newly created post" do
          returned = @c.post({title: "test_post"})
          determined = Dir.glob("_posts/*.md").first
          returned.should == determined
        end

        it "should downcase a title" do
          @c.post({title: "Test_Post_With_Uppercase"})
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-test_post_with_uppercase[.]md/)
        end

        it "should sub underscores for spaces in title" do
          @c.post({title: "Test Post with Spaces"})
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-test_post_with_spaces[.]md/)
        end

        it "should remove non-word characters for slug" do
          @c.post({title: "On (function() {}()) in JavaScript"})
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-on_function_in_javascript[.]md/)
        end

        it "should update the title in the file itself" do
          @c.post({title: "Testing Post {}"})
          fn = Dir.glob("_posts/*.md").first
          content = File.open(fn, 'r').read
          content.should match(/title: Testing Post {}/)
        end

        it "should update the date in the file itself" do
          @c.post({title: "Date test post"})
          fn = Dir.glob("_posts/*.md").first

          # date in filename should match date in file itself
          date = fn.match(/(#{@date_regex})-date_test_post[.]md/)[1]
          content = File.open(fn, 'r').read
          content.should match(/date: #{date}/)
        end

      end   # end context title only

      context 'title and slug' do

        it "should create a post named for slug" do
          @c.post({title: "Test Post", slug: 'unique_slug'})
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-unique_slug[.]md$/)
        end

        it "should sub any weird characters in slug" do
          @c.post({title: "Test Post with Spaces", slug: "(stupid] {slüg/"})
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-stupid_slg[.]md/)
        end

        it "should update the title in the file itself" do
          @c.post({title: "Testing Post {}", slug: 'shouldnt_be_in_title'})
          fn = Dir.glob("_posts/*.md").first
          content = File.open(fn, 'r').read
          content.should match(/title: Testing Post {}/)
        end

      end   # end context title & slug

    end   # end describe post

    describe "#draft" do
      context 'title only' do

        it "should create a _drafts directory" do
          @c.draft({title: 'draft post'})
          Dir.exists?('_drafts').should be_true
        end

        it "should create a new draft in the _drafts directory" do
          @c.draft({title: 'draft post'})
          Dir.glob("_drafts/*.md").length.should == 1
        end

        it "should return path to the newly created draft" do
          returned = @c.draft({title: "test_draft"})
          determined = Dir.glob("_drafts/*.md").first
          returned.should == determined
        end

        it "should create a non-timestamped draft" do
          @c.draft({title: 'draft post'})
          fn = Dir.glob("_drafts/*.md").first
          fn.should_not match(/#{@date_regex}/)
        end

        it "should downcase and underscore title for slug" do
          @c.draft({title: "Test Post with Spaces"})
          fn = Dir.glob("_drafts/*.md").first
          fn.should match(/test_post_with_spaces[.]md/)
        end

        it "should remove non-word characters for slug" do
          @c.draft({title: "On (function() {}()) in JavaScript"})
          fn = Dir.glob("_drafts/*.md").first
          fn.should match(/on_function_in_javascript[.]md/)
        end

        it "should update the title in the file itself" do
          @c.draft({title: "Testing Draft {}"})
          fn = Dir.glob("_drafts/*.md").first
          content = File.open(fn, 'r').read
          content.should match(/title: Testing Draft {}/)
        end

        it "should not update the date in the file itself" do
          @c.draft({title: "Date test post"})
          fn = Dir.glob("_drafts/*.md").first

          # date in filename should match date in file itself
          content = File.open(fn, 'r').read
          content.should match(/date:\s*\n/)
        end

      end   # end context title only

      context 'title and slug' do

        it "should create a draft named for slug" do
          @c.draft({title: "Test Draft", slug: 'unique_slug'})
          fn = Dir.glob("_drafts/*.md").first
          fn.should match(/unique_slug[.]md$/)
        end

        it "should sub any weird characters in slug" do
          @c.draft({title: "Test Post with Spaces", slug: "(stupid] {slüg/"})
          fn = Dir.glob("_drafts/*.md").first
          fn.should match(/stupid_slg[.]md/)
        end

        it "should update the title in the file itself" do
          @c.draft({title: "Testing Post {}", slug: 'shouldnt_be_in_title'})
          fn = Dir.glob("_drafts/*.md").first
          content = File.open(fn, 'r').read
          content.should match(/title: Testing Post {}/)
        end

      end   # end context title & slug

    end   # end describe draft

    describe "#publish" do

      before :each do
        @d_path = @c.draft({title: 'test_draft'})
      end

      it 'should create a timestamped post in the _posts folder' do
        @c.publish(@d_path)
        fn = Dir.glob("_posts/*.md").first
        fn.should match(/#{@date_regex}-test_draft[.]md$/)
      end

      it 'should remove file in the _drafts folder' do
        @c.publish(@d_path)
        File.exist?(@d_path).should be_false
      end

      it 'should return path to newly created post' do
        returned = @c.publish(@d_path)
        determined = Dir.glob("_posts/*.md").first
        returned.should == determined
      end

      it 'should create post with matching slug' do
        post = @c.publish(@d_path)

        draft_slug = File.basename(@d_path, '.md')
        post_slug = post.match(/#{@date_regex}-(.*)[.]md/)[1]

        post_slug.should == draft_slug
      end

      it 'should update timestamp in actual file' do
        post = @c.publish(@d_path)
        content = File.open(post, 'r').read
        content.should match(/date: #{@date_regex} \d{2}:\d{2}\n/)
      end

      it 'should copy contents of draft into post' do
        # first add some content to the draft
        f = File.open(@d_path, 'a')
        f.write("Some new content for my blog\n")
        f.close

        post = @c.publish(@d_path)
        content = File.open(post, 'r').read
        content.should match(/Some new content for my blog/)
      end

    end   # end describe publish

    describe "#unpublish" do

      before :each do
        @p_path = @c.post({title: 'test_post'})
      end

      it 'should create a _drafts directory' do
        @c.unpublish(@p_path)
        Dir.exists?('_drafts').should be_true
      end

      it 'should create an untimestamped draft in the _drafts folder' do
        @c.unpublish(@p_path)
        fn = Dir.glob("_drafts/*.md").first
        fn.should_not match(/#{@date_regex}/)
      end

      it 'should remove file in the _posts folder' do
        @c.unpublish(@p_path)
        File.exist?(@p_path).should be_false
      end

      it 'should return path to newly created draft' do
        returned = @c.unpublish(@p_path)
        determined = Dir.glob("_drafts/*.md").first
        returned.should == determined
      end

      it 'should create draft with matching slug' do
        draft = @c.unpublish(@p_path)

        post_slug = @p_path.match(/#{@date_regex}-(.*)[.]md$/)[1]
        draft_slug = File.basename(draft, '.md')

        draft_slug.should == post_slug
      end

      it 'should delete timestamp in actual file' do
        draft = @c.unpublish(@p_path)
        content = File.open(draft, 'r').read
        content.should match(/date:\s*\n/)
      end

      it 'should copy contents of post into draft' do
        # first add some content to the draft
        f = File.open(@p_path, 'a')
        f.write("Some new content for my blog\n")
        f.close

        draft = @c.unpublish(@p_path)
        content = File.open(draft, 'r').read
        content.should match(/Some new content for my blog/)
      end

    end   # end describe unpublish
  end
end
