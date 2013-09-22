require 'fileutils'

%w{ commands helper cli config }.each do |lib|
  require File.expand_path("../mr_poole/#{lib}", __FILE__)
end

module MrPoole
end
