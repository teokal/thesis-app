require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'time'
require 'hashie'
require 'elasticsearch'
require 'elasticsearch/dsl'
include Elasticsearch::DSL

class EsController < ApplicationController

  def show
    @time_values = [
      ['1 month', 1], ['2 months', 2], ['6 months', 6],
      ['1 year', 12], ['2 years', 24], ['since 2007', 120]
    ]
    @from_date = params[:from_date] ||= 12
    @to_date = params[:to_date] ||= Time.now.to_i
    @query = params[:query]
  end

  def query_es(options = {})
    data = []
    client = Elasticsearch::Client.new(url: ENV['ES_HOST_URL'])

    search_body = {
                  size: 0,
                  query: {
                    bool: { must: [
                      { query_string: { analyze_wildcard: true, query: '*'}},
                      { range: {
                        '@timestamp' => { gte: options[:from_date],
                                          lte: options[:to_date],
                                          format: 'dd-MM-yyyy||yyyy'
                      }}}
                    ]}},
                  aggregations: {
                    sums: { date_histogram: { field: '@timestamp',
                                              interval: options[:view],
                                              time_zone: 'Europe/Athens',
                                              min_doc_count: 1,
                                              format: 'strict_date_hour_minute_second'}}
                  },
                  sort: {'@timestamp' => {order: 'desc', unmapped_type: 'boolean'}}
                 }

    if options[:module] == 'course'
      search_body[:query][:bool][:must].push({match: {module: {query: 'course', type: 'phrase'}}},
                                             {match: {course: {query: options[:course].moodle_id, type: 'phrase'}}},
                                             {match: {action: {query: options[:query], type: 'phrase'}}})
    elsif options[:module] == 'user'
      search_body[:query][:bool][:must].push({match: {module: {query: 'user', type: 'phrase'}}},
                                             # {match: {course: {query: options[:user].moodle_id, type: 'phrase'}}},
                                             {match: {action: {query: options[:query], type: 'phrase'}}})
    else
      search_body[:query][:bool][:must].push({match: {action: {query: options[:query], type: 'phrase'}}})
    end

    response = client.search index: ENV['ES_INDEX'], body: search_body

    response['aggregations']['sums']['buckets'].each do |row|
      data << {date: row['key_as_string'], value: row['doc_count']}
    end

    data

  end

  def transform_response(data_table, keys)
    data_t = data_table.inject({}) do |a, e|
      action, data = e.first
      data.each do |x|
        a[x[:date]] ||= Hash[keys.product([0])]
        a[x[:date]][action] = x[:value]
      end
      a
    end
    data_t.map {|k, v| v.update(:date => k)}
  end

end

####
# ELASTICSEARCH - NOTES

## Possible aggregations
# https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-datehistogram-aggregation.html
# year, quarter, month, week, day, hour, minute, second

## Range
# https://www.elastic.co/guide/en/elasticsearch/reference/current/common-options.html#date-math
# y years
# M months
# w weeks
# d days
# h hours
# H hours
# m minutes
# s seconds