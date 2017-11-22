class UserController < ApplicationController

  def info(userids = nil)
    user = Moodle::Api.core_user_get_users_by_field(field: 'id', values: userids.nil? ? [params[:userid].to_i] : Array(userids))
    user.blank? ? {type: :error, message: 'User not found'} : user
  end

  def courses
    courses = Moodle::Api.core_enrol_get_users_courses(userid: @user.moodle_user_id)
    courses.blank? ? {type: :error, message: 'No courses found'} : courses
  end

  def statistics
    courses = Moodle::Api.core_enrol_get_users_courses(userid: @user.moodle_user_id)
    events = Moodle::Api.core_calendar_get_calendar_events({})

    total_students = 0
    statistics = []
    key = 'view'

    courses.each do |course|
      total_students += course['enrolledusercount']
      statistics << Hash[key, ES_CONTROLLER.query_es({from_date: '2015', to_date: Date.today.year,
                                                      query: key, view: 'day', module: 'course',
                                                      course_id: course['id']})]
    end

    {
        enrolledusercount: total_students,
        viewed: ES_CONTROLLER.transform_response(statistics, [key]),
        events: events['events']
    }
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
