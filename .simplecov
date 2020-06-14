require 'simplecov'
SimpleCov.profiles.define 'scripts-common' do
  add_filter %r{^/.git/}
  add_filter %r{^/_.*/}
end

SimpleCov.start 'scripts-common'
