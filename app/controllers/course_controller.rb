class CourseController < ApplicationController

  def get_logs
    queries = params[:query].split(',')
    data_table = []
    keys = params[:query] == 'all' ? %w(view quiz enrol unenrol) : queries
    keys.each do |query|
      data_table << Hash[query, ES_CONTROLLER.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                        query: query, view: params[:view], module: 'course', course_id: params[:course]})]
    end

    data_t = ES_CONTROLLER.transform_response(data_table, keys)
    {data: data_t}
  end

  def get_course_contents
    contents = Moodle::Api.core_course_get_contents(courseid: params[:courseid], options: [{:name => 'excludemodules', :value => 'false'}])
    if contents.blank?
      {type: :error, message: 'Course not found or has no content'}
    else
      {data: contents}
    end
  end

  def get_course_contents_logs
    queries = params[:query].split(',')
    data_table = []
    keys = params[:query] == 'all' ? %w(view) : queries
    keys.each do |query|
      data_table << Hash[query, ES_CONTROLLER.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                        query: query, view: params[:view], module: 'course', course_id: params[:course]})]
    end

    data_t = ES_CONTROLLER.transform_response(data_table, keys)
    {data: data_t}
  end

  def get_course_modules
    modules = Moodle::Api.core_course_get_course_module(cmid: params[:cmid])
    modules.blank? ? {type: :error, message: 'Course not found'} : modules
    {data: modules}
  end

  def get_course_modules_logs
    module_resource = params[:resource]
    queries = params[:query].split(',')
    data_table = []
    keys = params[:query] == 'all' ? %w(view) : queries
    keys.each do |query|
      data_table << Hash[query, ES_CONTROLLER.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                        query: query, view: params[:view], module: 'resource', course_id: params[:course],
                                                        module_resource: module_resource})]
    end

    data_t = ES_CONTROLLER.transform_response(data_table, keys)
    {data: data_t}
  end

  def enrolled_users
    enrolled_users = Moodle::Api.core_enrol_get_enrolled_users(courseid: params[:courseid], options: [{:name => 'userfields', :value => 'fullname'}])
    if enrolled_users.blank?
      {type: :error, message: 'Course not found or does not have enrolled users'}
    else
      {data: enrolled_users}
    end
  end

  def user_groups(course_id = nil)
    user_groups = Moodle::Api.core_group_get_course_groups(courseid: params[:courseid] || course_id)
    if user_groups.blank?
      {type: :error, message: 'Course not found or does not have user groups'}
    else
      {data: user_groups}
    end
  end

  def group_members(group_ids = nil)
    group_members = Moodle::Api.core_group_get_group_members(groupids: [params[:groupid]] || Array(group_ids))
    if group_members.blank?
      {type: :error, message: 'Group member not found or does not have members'}
    else
      controller = ApplicationController::UserController.new
      users = controller.info(group_members.first['userids'])
      {data: users}
    end
  end

end
