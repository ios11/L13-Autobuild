#!/usr/bin/env ruby
#
#  Rakefile
#  HelloWorld
#
#  Non default gems you should install to run tasks:
#  - cocoapods
#  - xcpretty
#  - rubyzip
#  - json
#  - plist
#  To install them use this commans pattern:
#  $ sudo gem install <gem_name>
#
#  Created by Pavel Osipov on 24.12.15.
#  Copyright (c) 2015 Pavel Osipov. All rights reserved.
#

require_relative 'Autobuild/project_builder'

include CI

def project_builder
  unless $builder
    $builder = CI::ProjectBuilder.new 'HelloWorld'
  end
  return $builder
end

task :clean, [:scheme_name] do |t, args|
  project_builder.uninstall_pods
  project_builder.clean_build_artifacts
end

task :install_profiles, [:scheme_name] => [:clean] do |t, args|
  # puts 'TODO: install_profiles'
end

task :install_pods, [:scheme_name] => [:clean] do |t, args|
  project_builder.install_pods
end

task :test_app, [:scheme_name] => [:install_profiles, :install_pods] do |t, args|
  project_builder.run_tests 'HelloWorldTests'
end

task :build_app, [:scheme_name] => [:test_app] do |t, args|
  project_builder.build_archive 'HelloWorld'
end
