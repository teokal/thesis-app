class UserController < ApplicationController

  def courses
    user = Moodle::Api.core_enrol_get_users_courses({userid: params[:id]})
    user.blank ? {type: :error, message: 'User not found'} : user
  end

  def logs
    es_controller = EsController.new

    queries = params[:query].split(',')
    data_table = []
    keys = ((params[:query] == 'all') ? %w(update logout login view add) : queries)
    keys.each do |query|
      data_table << Hash[query, es_controller.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                     query: query, view: params[:view], module: 'user'})]
    end

    data_t = es_controller.transform_response(data_table, keys)
    {data: data_t}
  end

end
