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

  def show_action
    actions(params[:from_date],
            params[:to_date],
            params[:query])
  end

  def actions(from_date, to_date, query)
    data = []
    client = Elasticsearch::Client.new url: ENV['ES_HOST_URL']

    response = client.search index: ENV['ES_INDEX'],
                             body: {
                               size: 0,
                               query: {
                                 bool: { must: [
                                   { match: { action: { query: query, type: 'phrase' }}
                                   },
                                   { query_string: { analyze_wildcard: true,
                                                   query: '*'}
                                   },
                                   { range: {
                                     '@timestamp' => { gte: "now-#{from_date}M/d",
                                                       lte: "now-#{to_date}M/d"
                                   }}}
                                 ]}},
                               aggregations: {
                                 sums: { date_histogram: { field: '@timestamp',
                                                           interval: 'month',
                                                           time_zone: 'Europe/Athens',
                                                           min_doc_count: 1,
                                                           format: 'yyyy-MM-dd'}}
                               },
                               sort: {'@timestamp' => {
                                   order: 'desc', unmapped_type: 'boolean'}
                               }
                             }

    response['aggregations']['sums']['buckets'].each do |row|
      data << [row['key_as_string'], row['doc_count']]
    end
    render json: data

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