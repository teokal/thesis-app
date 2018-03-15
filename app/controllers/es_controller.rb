require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'time'
require 'hashie'
require 'typhoeus'
require 'typhoeus/adapters/faraday'
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

    if options[:from_date].length == 3        #now
      from_date_tmp = DateTime.now
    elsif options[:from_date].length == 4     #year
      from_date_tmp = DateTime.new(options[:from_date].to_i)
    else                                      #full-date
      from_date_tmp = DateTime.strptime(options[:from_date], "%d-%m-%Y")
    end

    if options[:to_date].length == 3          #now
      to_date_tmp = DateTime.now
    elsif options[:to_date].length == 4       #year
      to_date_tmp = DateTime.new(options[:to_date].to_i)
    else                                      #full-date
      to_date_tmp = DateTime.strptime(options[:to_date], "%d-%m-%Y")
    end
    
    from_date = from_date_tmp.beginning_of_day.strftime('%Q').to_i
    to_date = to_date_tmp.end_of_day.strftime('%Q').to_i
    
    search_body = {
      size: 0,
      query: {bool: {}},
      aggregations: {
        sums: {date_histogram: {field: 'timecreated',
          interval: options[:view],
          time_zone: 'Europe/Athens',
          min_doc_count: 1,
          format: 'strict_date_hour_minute_second'}}
      },
      sort: {'timecreated' => {order: 'desc', unmapped_type: 'boolean'}}
    }

    search_body[:query][:bool][:must] = [
      {query_string: {analyze_wildcard: true, query: '*'}},
      {range: {'timecreated' => {gte: from_date, lte: to_date, format: 'epoch_millis'}}},
      {match: {target: {query: 'course'}}},
      {match: {action: {query: options[:query]}}}
    ]
    
    search_body[:query][:bool][:must_not] = {match: {component: {query: 'report_*'}}}

    search_body[:query][:bool][:should] = Array(options[:course_id])
                                                .map{|id| {match: {courseid: id.to_i}}}

    response = ES_CLIENT.search({index: ENV['ES_INDEX'], body: search_body})

    if options[:module] == 'resource' && options[:get_resources]
      response['aggregations']['sums']['buckets'].each do |row|
        data << row['by_cmid']['buckets'].map {|k| k['key']}
      end
    else
      response['aggregations']['sums']['buckets'].each do |row|
        data << {date: row['key_as_string'], value: row['doc_count']}
      end
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