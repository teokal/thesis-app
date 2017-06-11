class  Api::V1::CourseController <  Api::V1::ApiController

  def get
    controller = ApplicationController::CourseController.new
    response = controller.show(params[:id])
    response = response.as_json(only: [:id, :coursecategory, :fullname, :shortname, :idnumber, :summary, :timecreated])
    data = response.nil? ? 'Course not found' : response
    success_response(data: data)
  end

end