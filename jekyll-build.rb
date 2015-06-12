require 'fileutils'

desc "Builds specified jekyll site and environment"
task :default, [:path, :site_url, :publish_path, :publish_owner, :publish_group] do |t, args|
  args.with_defaults(:path => Dir.pwd)
  args.with_defaults(:site_url => "http://localhost:4000")
  #args.with_defaults(:publish_owner => fu_get_uid())
  #args.with_defaults(:publish_group => fu_get_gid())
  
  Rake::Task['jekyll:build'].invoke(args.path, args.site_url)
  Rake::Task['jekyll:filedeploy'].invoke(args.path, args.publish_path, args.publish_owner, args.publish_group)
end


namespace :jekyll do

  desc "Deletes the _site folder"
  task :clean, [:path] do |t, args|
  	puts "Removing _site folder"

    #if File.directory?(args.path)
      remove_dir File.join(args.path, '_site'), force: true
    #end
  end

  desc "Runs the jekyll build command"
  task :build, [:path, :site_url] => :clean do |t, args|

  	puts "Building _site folder"

    Rake::Task['jekyll:config:rewrite_url'].invoke(args.path, args.site_url)

  	sh "cd #{args.path}; jekyll build" do |ok ,res|
  		if ! ok
  			puts "Failed to build site (status = #{res.exitstatus})"
  		else
  			puts "Successfully built site"
  		end
  	end

  end

  namespace :config do

    desc "Updates the url parameter of the _config.yml file"
    task :rewrite_url, [:path, :site_url] do |t, args|

      puts "Rewriting configuration site url"

      config = File.join(args.path, '_config.yml')
      contents  = File.read(config)
      new_contents = contents.gsub(/^url\:.*/,"url:\t#{args.site_url}")
      File.open(config, "w") {|file| file.puts new_contents }

    end

  end

  desc "File copies the _site folder contents to a destination folder"
  task :filedeploy, [:path, :publish_path, :publish_owner, :publish_group] do |t, args|

    puts "File deploying"
    FileUtils.copy_entry File.join(args.path, "_site"), args.publish_path
    
    if args.publish_owner? && args.publish_group?
      FileUtils.chown_R args.publish_owner, args.publish_group, args.publish_path, :verbose => true
    end
  end

end