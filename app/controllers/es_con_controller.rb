require 'multi_json'
require 'faraday'
require 'elasticsearch/api'

class EsConController
  include Elasticsearch::API

  CONNECTION = ::Faraday::Connection.new(ENV['ES_HOST_URL'],
                                         trace: true,
                                         log: true)

  def perform_request(method, path, params, body)
    puts "--> #{method.upcase} #{path} #{params} #{body}"

    CONNECTION.run_request(method.downcase.to_sym,
                           path,
                           (body ? MultiJson.dump(body) : nil),
                           Content: { Type: 'application/json' }
                          )
  end
end
