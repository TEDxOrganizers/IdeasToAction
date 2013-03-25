require 'pathname'
require 'erb'

namespace :phonegap do

  namespace :iphone do
    task :set_www_directory do
      @www_directory = "iphone/www"
    end
  end

  namespace :android do
    task :set_www_directory do
      @www_directory = "mobile/assets/www"
    end

    desc "Clean the Phonegap build artefacts"
    task :clean => :clean_www_directory do
      FileUtils.rm_rf 'mobile/bin' if File.exists?('mobile/bin')
      FileUtils.rm_rf 'mobile/gen' if File.exists?('mobile/gen')
      FileUtils.rm 'mobile/AndroidManifest.xml' if File.exists?('mobile/AndroidManifest.xml')
    end

    task :precompiled_assets do
      raise "Couldn't precompile assets" unless Kernel.system("rake RAILS_ENV=#{@assets_env || 'android'} assets:precompile")
    end

    file 'public/assets/cordova-2.3.0.js' do
      FileUtils.cp 'app/assets/javascripts/cordova-2.3.0.js', 'public/assets/cordova-2.3.0.js'
    end

    task :cordova_in_assets => 'public/assets/cordova-2.3.0.js'

    task :clean_www_directory do
      FileUtils.rm_rf(@www_directory, verbose: true) if File.exists?(@www_directory)
    end

    task :create_www_directory => :clean_www_directory do
      FileUtils.mkdir_p @www_directory
    end

    desc "Builds the Android manifest"
    task :android_manifest do
      android_manifest_template = Pathname.new('mobile/AndroidManifest.xml.erb')
      android_manifest = Pathname.new('mobile/AndroidManifest.xml')

      android_manifest.open("w") { | manifest | manifest.puts ERB.new(android_manifest_template.read).result }
    end

    task :assets_in_www_directory => [ :create_www_directory, :android_manifest ] do
      FileUtils.mv('public/assets', "#{@www_directory}/.")
      FileUtils.mv("#{@www_directory}/assets/index.html", @www_directory, verbose: true)
      FileUtils.rm_rf("#{@www_directory}/assets/active_admin", verbose: true)
      FileUtils.rm_rf("#{@www_directory}/assets/active_admin.css", verbose: true)
      FileUtils.rm_rf("#{@www_directory}/assets/active_admin.js", verbose: true)
      FileUtils.rm_rf(Dir.glob("#{@www_directory}/assets/*.gz"), verbose: true)
      FileUtils.rm(Dir.glob("#{@www_directory}/**/*").select { | fn | fn =~ /.*-([\w\d]{32})\.[\w]+/ }, verbose: true)

      application_css = Pathname.new("#{@www_directory}/assets/application.css")
      content = application_css.read.gsub(/\.\/assets\//, "")
      application_css.open("w") {|file| file.write content }
    end

    namespace :build do
      desc "Build Android Application (production)"
      task :default => [ :set_www_directory, :clean, :precompiled_assets, :cordova_in_assets, :assets_in_www_directory ] do
        raise "Couldn't build Phonegap package" unless Kernel.system('mobile/cordova/build')
      end

      desc "Build Android Application (qa)"
      task :qa => [ :set_qa_assets, :default ]

      task :set_qa_assets do
        @assets_env = "qa_mobile_assets"
      end
    end
  end
end
