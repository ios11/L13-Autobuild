#!/usr/bin/env ruby
#
#  project_builder.rb
#  HansCI
#
#  Created by Pavel Osipov on 28.11.14.
#  Copyright (c) 2014 Mail.Ru Group. All rights reserved.
#

require 'rake'

module CI

  class ProjectBuilder
    def initialize(project_name)
      @project_workspace = "#{project_name}.xcworkspace"
      @build_dir = 'build/'
    end

    def pods_installed?
      File.exist?('Podfile.lock') && Dir.exist?('Pods') && Dir.exist?(@project_workspace)
    end

    def install_pods
      Rake.sh "pod install --no-ansi" unless pods_installed?
    end

    def uninstall_pods
      FileUtils.rm_rf [
        @project_workspace,
        'Podfile.lock',
        'Pods',
      ]
    end

    def clean_build_artifacts
      Rake.sh 'xcodebuild -alltargets clean'
      FileUtils.rm_rf @build_dir
    end

    def run_tests(scheme_name)
      Rake.sh "xcodebuild -workspace #{@project_workspace} -scheme '#{scheme_name}' -sdk iphonesimulator9.1 -destination \"name=iPhone 6\" test | xcpretty -t -r junit -o \"build/reports/#{scheme_name}.junit.xml\" ; exit ${PIPESTATUS[0]}"
      puts "\n\n"
    end

    def build_archive(scheme_name)
      archive_dir = @build_dir
      FileUtils.rm_rf archive_dir
      FileUtils.mkdir_p archive_dir
      archive_path = "#{File.join archive_dir, scheme_name}.xcarchive"
      build(scheme_name, "clean build archive -archivePath #{archive_path} CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO")
    end

    private

    def build(scheme_name, actions)
      Rake.sh "xcodebuild -workspace #{@project_workspace} -scheme '#{scheme_name}' -destination generic/platform=iOS -configuration Release #{actions} | xcpretty -c --no-utf ; exit ${PIPESTATUS[0]}"
    end

  end

end
