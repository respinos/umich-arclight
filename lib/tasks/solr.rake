namespace :solr do
  desc 'SOLR Environment'
  task solr_environment: :environment do
    # raise 'Please specify ENV SOLR_HOST=<host>' unless ENV['SOLR_HOST']
    # raise 'Please specify ENV SOLR_PORT=<port>' unless ENV['SOLR_PORT']
    raise 'Please specify ENV SOLR_USER=<user>' unless ENV['SOLR_USER']
    raise 'Please specify ENV SOLR_PASSWORD=<password>' unless ENV['SOLR_PASSWORD']
  end

  solr_curl = proc do |arg|
    env = {}
    cmd = "curl -v -u #{ENV["SOLR_USER"]}:#{ENV["SOLR_PASSWORD"]} #{arg}"
    puts cmd
    stdout_and_stderr, process_status = Open3.capture2e(env, cmd)
    if process_status.success?
      puts stdout_and_stderr
    else
      raise StandardError, stdout_and_stderr
    end
  end

  namespace :configset do
    desc 'LIST Solr Configuration Sets'
    task list: :solr_environment do
      solr_curl.call("'http://solr:80/api/cluster/configs?omitHeader=true'")
    end

    desc 'UPLOAD Solr Configuration Set'
    task upload: :solr_environment do
      require 'zip'

      raise 'Please specify ENV SOLR_CONFIGSET=<configset>' unless ENV['SOLR_CONFIGSET']

      configset = ENV["SOLR_CONFIGSET"].to_s
      configset_zip = Rails.root.join("tmp/#{configset}.zip")
      File.delete(configset_zip) if File.exist?(configset_zip)
      arclight_conf_dir = Rails.root.join("solr/arclight/conf")
      puts "Zipping #{arclight_conf_dir} into #{configset_zip} ..."
      Dir.chdir(arclight_conf_dir)
      Zip::File.open(configset_zip, create: true) do |zipfile|
        Dir.glob("**/*").each do |entry|
          puts entry.to_s
          zipfile.add(entry, File.join(arclight_conf_dir, entry))
        end
      end

      solr_curl.call("-X PUT --header 'Content-Type:application/octet-stream' --data-binary @#{configset_zip} 'http://solr:80/api/cluster/configs/#{configset}?omitHeader=true'")
    end

    desc 'DELETE Solr Configuration Set'
    task delete: :solr_environment do
      raise 'Please specify ENV SOLR_CONFIGSET=<configset>' unless ENV['SOLR_CONFIGSET']

      solr_curl.call("-X DELETE 'http://solr:80/api/cluster/configs/#{ENV["SOLR_CONFIGSET"]}?omitHeader=true'")
    end
  end

  namespace :collection do
    desc 'LIST Solr Collection'
    task list: :solr_environment do
      solr_curl.call("'http://solr:80/solr/admin/collections?action=LIST&omitHeader=true'")
    end

    desc 'CREATE Solr Collection'
    task create: :solr_environment do
      raise 'Please specify ENV SOLR_COLLECTION=<collection>' unless ENV['SOLR_COLLECTION']
      # raise 'Please specify ENV SOLR_NUM_SHARDS=<number>' unless ENV['SOLR_NUM_SHARDS']
      # raise 'Please specify ENV SOLR_REPLICATION_FACTOR=<number>' unless ENV['SOLR_REPLICATION_FACTOR']
      raise 'Please specify ENV SOLR_CONFIGSET=<configset>' unless ENV['SOLR_CONFIGSET']

      solr_curl.call("'http://solr:80/solr/admin/collections?action=CREATE&name=#{ENV["SOLR_COLLECTION"]}&numShards=1&replicationFactor=0&collection.configName=#{ENV["SOLR_CONFIGSET"]}&wt=xml&omitHeader=true'")
    end

    desc 'RELOAD Solr Collection'
    task reload: :solr_environment do
      raise 'Please specify ENV SOLR_COLLECTION=<collection>' unless ENV['SOLR_COLLECTION']

      solr_curl.call("'http://solr:80/solr/admin/collections?action=RELOAD&name=#{ENV["SOLR_COLLECTION"]}&wt=xml&omitHeader=true'")
    end

    desc 'DELETE Solr Collection'
    task delete: :solr_environment do
      raise 'Please specify ENV SOLR_COLLECTION=<collection>' unless ENV['SOLR_COLLECTION']

      solr_curl.call("'http://solr:80/solr/admin/collections?action=DELETE&name=#{ENV["SOLR_COLLECTION"]}&wt=xml&omitHeader=true'")
    end
  end
end
