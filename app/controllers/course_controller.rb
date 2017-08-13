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

end
