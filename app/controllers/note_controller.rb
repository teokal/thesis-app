class NoteController < ApplicationController

  def notes
    notifications = Moodle::Api.core_notes_get_course_notes(courseid: params[:courseid], userid: params[:userid])
    if notifications.blank?
      {type: :error, message: 'No notes.'}
    else
      {data: notifications}
    end
  end

end
