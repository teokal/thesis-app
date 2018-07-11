require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'elasticsearch'
require 'elasticsearch/dsl'
include Elasticsearch::DSL

task :import_logs_from_moodle => :environment do |t, args|
  begin
    LOGS_CHUNK = 500
    RETRIES = 3

    connection = ActiveRecord::Base.establish_connection(MoodleDatabase::DB_MOODLE).connection
    # find last imported log
    max_id = ES_CLIENT.search(
        {index: ENV['ES_INDEX'], body: {aggs: {max_id: {max: {field: 'id'}}}, 'size': 0}}
    )['aggregations']['max_id']['value'].to_i

    # query new logs from moodle database table
    logs = connection.execute("select * from `#{ENV["MOODLE_DB_PREFIX"]}logstore_standard_log` where `id` > #{max_id};")
    fields = logs.fields

    logs.each_slice(LOGS_CHUNK) do |logs_chunk|
      begin
        tries ||= RETRIES
        data = []

        # prepare data for importing; need key: value pairs
        logs_chunk.map {|log|
          data << {index: {_index: ENV['ES_INDEX'], _type: 'log'}}
          data << Hash[fields.zip(log)].symbolize_keys
        }
        puts "Sending ids #{logs_chunk.map(&:first).minmax.join(' - ')} to Elasticsearch."
        ES_CLIENT.bulk(body: data)
      rescue
        retry unless (tries -= 1).zero?
        Rails.logger.debug("Could not send logs chunk ids #{logs_chunk.map(&:first).minmax.join(' - ')} to Elasticsearch.")
      end
    end
  rescue
    Rails.logger.debugger('Could not complete rake task. Running the task will continue the import process.')
  end
end
