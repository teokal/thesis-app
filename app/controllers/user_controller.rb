class UserController < ApplicationController

  def info(user = nil, user_ids = nil)
    if user_ids.nil?
      array_user_ids = Array(user.moodle_user_id)
    else
      # [1,2,3,4]
      if user_ids.class != String && user_ids.all? {|i| i.is_a?(Integer)}
        array_user_ids = user_ids
      else # "1" -> [1]|| "1,2,3,4" -> [1,2,3,4]
        array_user_ids = user_ids.split(',').map(&:to_i)
      end
    end

    user = Moodle::Api.core_user_get_users_by_field(field: 'id', values: array_user_ids)
    user.blank? ? {type: :error, message: 'User not found'} : user
  end

  def courses(user)
    courses = Moodle::Api.core_enrol_get_users_courses(userid: user.moodle_user_id)
    courses.blank? ? {type: :error, message: 'No courses found'} : courses
  end

  def statistics(user)
    courses = Moodle::Api.core_enrol_get_users_courses(userid: user.moodle_user_id)

    total_students = 0
    statistics = []
    key = 'viewed'

    from_date = params[:from_date].blank? ? DateTime.now.prev_year.strftime("%d-%m-%Y") : params[:from_date]
    to_date = params[:to_date].blank? ? DateTime.now.strftime("%d-%m-%Y") : params[:to_date]
    view = params[:view].blank? ? 'month' : params[:view]

    total_students = courses.map{|course| course['enrolledusercount']}.inject(0){|sum,x| sum + x }
    
    es_stats = ES_CONTROLLER.query_es({from_date: from_date, to_date: to_date,
                                        query: key, view: view, module: 'course',
                                        course_id: courses.map{|course| course['id']}})
    
    statistics << Hash[key, es_stats]
    {
        enrolledusercount: total_students,
        viewed: ES_CONTROLLER.transform_response(statistics, [key])
    }
  end

  def logs
    queries = params[:query].split(',')
    data_table = []
    keys = ((params[:query] == 'all') ? %w(update logout login view add) : queries)
    keys.each do |query|
      data_table << Hash[query, es_controller.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                        query: query, view: params[:view], module: 'user'})]
    end

    {data: ES_CONTROLLER.transform_response(data_table, keys)}
  end

  def logout
    begin
      @user.logout({destroy: true, token: params[:token]})
      success_response
    rescue => error
      Rails.logger.error('[ERROR] API | Users | logout: ' + error.message)
      error_response
    end
  end

end