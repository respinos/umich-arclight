require 'net/http'

class BuildSuggestJob < ApplicationJob

  queue_as :index

  def perform
    # Not using Blacklight.default_index.connection for greater control
    uri = URI("#{ENV['SOLR_URL']}/suggest?suggest.build=true")

    ::Net::HTTP.start(uri.host, uri.port) do |http|
      http.read_timeout = 600
      res = http.request_get(uri.path, {'Accept'=>'application/json'})
      res.value # raises exception if not 2XX status
      puts res.body
    end
  end

end
