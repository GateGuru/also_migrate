require 'rubygems'
gem 'require'
require 'require'

Require do
  gem(:active_wrapper, '=0.2.3') { require 'active_wrapper' }
  gem :require, '=0.2.6'
  gem(:rake, '=0.8.7') { require 'rake' }
  gem :rspec, '=1.3.0'
  
  gemspec do
    author 'Winton Welsh'
    dependencies do
      gem :require
    end
    email 'mail@wintoni.us'
    name 'gem_template'
    homepage "http://github.com/winton/#{name}"
    summary ""
    version '0.1.0'
  end
  
  bin { require 'lib/gem_template' }
  lib { require 'lib/gem_template/gem_template' }
  rails_init { require 'lib/gem_template' }
  
  rakefile do
    gem(:active_wrapper)
    gem(:rake) { require 'rake/gempackagetask' }
    gem(:rspec) { require 'spec/rake/spectask' }
    require 'require/tasks'
  end
  
  spec_helper do
    gem(:active_wrapper)
    require 'require/spec_helper'
    require 'rails/init'
    require 'pp'
  end
  
  spec_rakefile do
    gem(:rake)
    gem(:active_wrapper) { require 'active_wrapper/tasks' }
  end
end