#--
# Copyright (c) 2010 Engine Yard, Inc.
# Copyright (c) 2007-2009 Sun Microsystems, Inc.
# This source code is available under the MIT license.
# See the file LICENSE.txt for details.
#++

require File.dirname(__FILE__) + '/../spec_helper'

describe Warbler::Application do
  before :each do
    verbose(false)
    @pwd = Dir.getwd
    Dir.chdir("spec/sample")
    @argv = ARGV.dup
    ARGV.clear
    @app = Rake.application
    rm_f "config/warble.rb"
    @detection = Warbler.framework_detection
    Warbler.framework_detection = false
  end

  after :each do
    Rake.application = @app
    Warbler.project_application = nil
    Warbler.application = nil
    Warbler.framework_detection = @detection
    @argv.reverse.each {|a| ARGV.unshift a}
    rm_rf FileList['vendor/plugins/warbler']
    Dir.chdir(@pwd)
  end

  it "should be able to list its tasks" do
    ARGV.unshift "-T"
    output = capture do
      Warbler::Application.new.run
    end
    output.should =~ /warble war\s/
    output.should =~ /warble war:clean/
    output.should =~ /warble war:debug/
  end

  it "should display the version" do
    ARGV.unshift "version"
    capture { Warbler::Application.new.run }.should =~ /#{Warbler::VERSION}/
  end

  it "should copy a fresh config file into place" do
    File.exists?("config/warble.rb").should_not be_true
    ARGV.unshift "config"
    silence { Warbler::Application.new.run }
    File.exists?("config/warble.rb").should be_true
  end

  it "should refuse to copy over an existing config file" do
    touch "config/warble.rb"
    ARGV.unshift "config"
    capture { Warbler::Application.new.run }.should =~ /already exists/
  end

  it "should complain if the config directory is missing" do
    begin
      mv "config", "config-tmp"
      ARGV.unshift "config"
      capture { Warbler::Application.new.run }.should =~ /missing/
    ensure
      mv "config-tmp", "config"
    end
  end

  it "should refuse to pluginize if the vendor/plugins/warbler directory exists" do
    mkdir_p "vendor/plugins/warbler"
    ARGV.unshift "pluginize"
    silence { Warbler::Application.new.run }
    File.exist?("vendor/plugins/warbler/tasks/warbler.rake").should_not be_true
  end

  it "should define a pluginize task for adding the tasks to a Rails application" do
    ARGV.unshift "pluginize"
    Warbler::Application.new.run
    File.exist?("vendor/plugins/warbler/tasks/warbler.rake").should be_true
  end

  it "should provide a means to load the project Rakefile" do
    Warbler::Application.new.load_project_rakefile
  end

  it "should define a gemjar task for setting up gem packaging inside a jar" do
    ARGV.unshift "gemjar"
    Warbler::Application.new.run
    Rake::Task['war:jar'].prerequisites.should include('war:make_gemjar')
  end
end
