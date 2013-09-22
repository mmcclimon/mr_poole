require 'spec_helper'
require 'mr_poole'

def write_config_file
  f = File.open('_config.yml', 'w')
  f.puts 'poole:'
  f.puts '  default_layout: _layouts/poole.md'
  f.puts '  default_extension: md'
  f.close
end

def write_config_file_no_poole
  f = File.open('_config.yml', 'w')
  f.puts 'name: Douglas N. Adams'
  f.puts 'description: Life, the universe, and everything'
  f.close
end

module MrPoole
  describe Config do
    before(:each) { @olddir, @tmpdir = make_jekyll_dir }
    after(:each) { clean_tmp_files(@tmpdir, @olddir) }

    describe '::initialize' do
      it 'is empty with no config file' do
        config = Config.new
        expect(config).to be_empty
      end

      it "is empty with no 'poole' key in config file" do
        write_config_file_no_poole
        config = Config.new
        expect(config).to be_empty
      end

      it "is not empty with 'poole' key in config file" do
        write_config_file
        config = Config.new
        expect(config).not_to be_empty
      end

    end

    describe '#method_missing' do
      before(:each) { write_config_file }
      let(:config) { Config.new }

      it 'allows access to defined members' do
        expect(config.default_extension).to eq('md')
      end

      it 'returns nil for unknown key' do
        expect(config.bogus_key).to be_nil
      end
    end

  end
end
