ES_CLIENT =  Elasticsearch::Client.new(
    url: ENV['ES_HOST_URL'],
    log: true
)