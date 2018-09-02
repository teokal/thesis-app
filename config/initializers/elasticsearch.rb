ES_CLIENT =  Elasticsearch::Client.new(
    url: ENV['ES_HOST_URL'],
    port: 9200,
    log: true
)