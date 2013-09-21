require 'spec_helper'

require 'mr_poole'

module MrPoole
  describe Tasks do

    before :each do
      @olddir, @tmpdir = make_jekyll_dir
      @t = Tasks.new
      @date_regex = %r{\d{4}-\d{2}-\d{2}}
    end

    after :each do
      clean_tmp_files(@tmpdir, @olddir)
    end

    describe "#post" do
      context 'title only' do

        it "should create a new post in the _posts directory" do
          @t.post("test_post")
          Dir.glob("_posts/*.md").length.should == 1
        end

        it "should create a timestamped post in the _posts directory" do
          @t.post("test_post")
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-test_post[.]md$/)
        end

        it "should downcase a title" do
          @t.post("Test_Post_With_Uppercase")
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-test_post_with_uppercase[.]md/)
        end

        it "should sub underscores for spaces in title" do
          @t.post("Test Post with Spaces")
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-test_post_with_spaces[.]md/)
        end

        it "should remove non-word characters for slug" do
          @t.post("On (function() {}()) in JavaScript")
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-on_function_in_javascript[.]md/)
        end

        it "should update the title in the file itself" do
          @t.post("Testing Post {}")
          fn = Dir.glob("_posts/*.md").first
          content = File.open(fn, 'r').read
          content.should match(/title: Testing Post {}/)
        end

        it "should update the date in the file itself" do
          @t.post("Date test post")
          fn = Dir.glob("_posts/*.md").first

          # date in filename should match date in file itself
          date = fn.match(/(#{@date_regex})-date_test_post[.]md/)[1]
          content = File.open(fn, 'r').read
          content.should match(/date: #{date}/)
        end

      end   # end context title only

      context 'title and slug' do

        it "should create a post named for slug" do
          @t.post("Test Post", 'unique_slug')
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-unique_slug[.]md$/)
        end

        it "should sub any weird characters in slug" do
          @t.post("Test Post with Spaces", "(stupid] {slüg/")
          fn = Dir.glob("_posts/*.md").first
          fn.should match(/#{@date_regex}-stupid_slg[.]md/)
        end

        it "should update the title in the file itself" do
          @t.post("Testing Post {}", 'shouldnt_be_in_title')
          fn = Dir.glob("_posts/*.md").first
          content = File.open(fn, 'r').read
          content.should match(/title: Testing Post {}/)
        end

      end   # end context title & slug

    end   # end describe post


  end
end
