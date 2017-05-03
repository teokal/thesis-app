require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'time'

class EsController < ApplicationController

  def index

  end

  def show
    @time_values = [['1 month', 1], ['2 months', 2], ['6 months', 6], ['1 year', 12], ['2 years', 24], ['since 2007', 120]]
    @from_date = params['from_date'] ||= 5.years.ago.to_time.to_i
    @to_date = params['to_date'] ||= 2.years.ago.to_time.to_i
  end

  def logins
    actions(params['from_date'],
            params['to_date'],
            'login')
  end

  def logouts
    actions(params['from_date'],
            params['to_date'],
            'logout')
  end

  def writes
    actions(params['from_date'],
            params['to_date'],
            'write')
  end

  def actions(from_date, to_date, query)

    from_date = 5 * 12 if from_date.nil?
    to_date = 2 * 12 if to_date.nil?

    from_date = (Time.now.to_datetime - from_date.to_i.months).to_time.to_i
    to_date = (Time.now.to_datetime - to_date.to_i.months).to_time.to_i

    uri = URI.parse('http://83.212.100.184:9200/moodle-*/_search?scroll=1m')
    request = Net::HTTP::Get.new(uri)
    request.body = "{\"from\":0,\"size\":100000,
                    \"sort\":[{\"@timestamp\":
                              {\"order\": \"desc\",
                              \"unmapped_type\": \"boolean\"}}],
                    \"slice\":{\"id\":0,\"max\":10},
                    \"query\":{\"bool\":{\"must\":[
                          {\"match\":{\"action\":
                               {\"query\":\"#{query}\",\"type\":\"phrase\"}}},
                    {\"range\":{\"time\":
                               {\"gte\":#{from_date},\"lte\":#{to_date}}}}
                     ]}}}"

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    data = []
    JSON.parse(response.body)['hits']['hits'].each do |ea|
      data << ea['_source'].as_json(only: %w[id ip userid time])
                  .merge!({date: (ea['_source']['@timestamp']).to_date,
                           index: ea['_index'],
                           id: ea['_id']
                          })
    end

    render json: Hash[data.group_by_month {|u| u[:date]}.map {|k, v| [k, v.size]}]
  end
end
