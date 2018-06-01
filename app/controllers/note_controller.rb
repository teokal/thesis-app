class NoteController < ApplicationController
  def notes(user)
    course_id = params[:course_id].to_i
    notifications = Moodle::Api.core_notes_get_course_notes(courseid: course_id, userid: user.moodle_user_id)
    if notifications.blank?
      {type: :error, message: "No notes."}
    else
      {data: notifications}
    end
  end
end
