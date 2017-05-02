require 'net/http'
require 'uri'
require 'json'
require 'date'

class EsController < ApplicationController

  def index

    # response = Log.search'action:'+ params['query_string'],
    #                       {index: 'moodle-*', type: 'logs', from: 0, size: params[:size]}

    # response = Log.search(query: {match: {action: params['query_string']}},
    # 	index: 'moodle-*', type: 'logs', from: 0, size: params[:size])

    # @response = response.page(params[:page]).results

    uri = URI.parse('http://83.212.100.184:9200/moodle-*/_search?scroll=1m')
    request = Net::HTTP::Get.new(uri)
    request.body = JSON.dump(from: 0,
                             size: 10000,
                             sort: {
                               time: {
                                 order: 'asc'
                               }
                             },
                             slice: {
                               id: 0,
                               max: 10
                             },
                             query: {
                               bool: {
                                 must: [
                                   {
                                     match: {
                                       action: {
                                         query: params['query_string'],
                                         type: 'phrase'
                                       }
                                     }
                                   },
                                   {
                                     range: {
                                       time: {
                                         gte: 1194173788,
                                         lte: 1421146999
                                       }
                                     }
                                   }
                                 ]
                               }
                             }
    )


    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end
    json_response = JSON.parse(response.body)
    @total = json_response['hits']['total']

    @responses = []
    @responses << JSON.parse(response.body)['hits']['hits']

    (1..10).each do |page|
      request.body = JSON.dump(from: 0,
                               size: 10000,
                               sort: {
                                   time: {
                                       order: 'asc'
                                   }
                               },
                               slice: {
                                   id: page,
                                   max: 14
                               },
                               query: {
                                   bool: {
                                       must: [
                                           {
                                               match: {
                                                   action: {
                                                       query: params['query_string'],
                                                       type: 'phrase'
                                                   }
                                               }
                                           },
                                           {
                                               range: {
                                                   time: {
                                                       gte: 1194173788,
                                                       lte: 1421146999
                                                   }
                                               }
                                           }
                                       ]
                                   }
                               }
      )
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end
      @responses << JSON.parse(response.body)['hits']['hits']
    end

    @response = []
    @responses.flatten!.each do |ea|
      @response << ea['_source'].as_json( only: ['id', 'ip', 'userid', 'time'])
                       .merge!({date: (ea['_source']['@timestamp']).to_date,
                                index: ea['_index'],
                                id: ea['_id']
                               })
    end

    @response = @response.group_by { |h| h[:date] }
    @total = @responses.count

  end
end
