class CourseController < ApplicationController

  def index
    Course.all
  end

  def show(id)
    course = Course.find_by(id: id)
    course.nil? ? {type: :error, message: 'Course not found'} : course
  end

  def show_moodle(id)
    course = Course.find_by(moodle_id: id)
    course.nil? ? {type: :error, message: 'Course not found'} : course
  end

  def logs
    controller = EsController.new
    course = Course.find_by(id: params[:course])
    queries = params[:query].split(',')
    data_table = []
    keys = params[:query] == 'all' ? %w(view quiz enrol unenrol) : queries
    keys.each do |query|
      data_table << Hash[query, controller.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                          query: query, view: params[:view], module: 'course', course: course})]
    end

    data_t = controller.transform_response(data_table, keys)
    {data: data_t}
  end

  def module_logs
    controller = EsController.new
    course = Course.find_by(id: params[:course])
    queries = params[:query].split(',')
    data_table = []
    keys = params[:query] == 'all' ? %w(view) : queries
    keys.each do |query|
      data_table << Hash[query, controller.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                     query: query, view: params[:view], module: 'course', course: course})]
    end

    data_t = controller.transform_response(data_table, keys)
    {data: data_t}
  end

  def module_resources_logs
    controller = EsController.new
    course = Course.find_by(id: params[:course])
    module_resource = params[:resource]
    queries = params[:query].split(',')
    data_table = []
    keys = params[:query] == 'all' ? %w(view) : queries
    keys.each do |query|
      data_table << Hash[query, controller.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                     query: query, view: params[:view], module: 'resource', course: course,
                                                     module_resource: module_resource})]
    end

    data_t = controller.transform_response(data_table, keys)
    {data: data_t}
  end

  def course_resources
    controller = EsController.new
    course = Course.find_by(id: params[:course])
    queries = params[:query].split(',')
    data_table = []
    keys = params[:query] == 'all' ? %w(view) : queries
    keys.each do |query|
      data_table = controller.query_es({from_date: params[:from_date], to_date: params[:to_date],
                                                     query: query, view: params[:view], module: 'resource', course: course,
                                                     get_resources: true})
    end

    data_t = data_table.flatten.uniq.map{|d| {id: d, title: "Title for module #{d.to_s}"}}.insert(0, {id: -1, title: 'All'})
    {data: data_t}
  end
end
