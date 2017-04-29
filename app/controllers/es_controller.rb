class EsController < ApplicationController

  def index

    client = Elasticsearch::Client.new log: true, host: '83.212.100.184'
    client.transport.reload_connections!
    client.cluster.health
    response = client.search(q: "action:#{params['query_string']}" )

    response = response['hits']['hits']

    @response = response

    # binding.pry

  end

end
