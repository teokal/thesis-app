task import_moodle_courses: :environment do
  begin
    moodle_courses = MoodleCourse.all
    moodle_courses.each do |moodle_course|
      begin
        Course.where(moodle_id: moodle_course.id).first_or_create do |course|
          course.coursecategory = moodle_course.category
          course.sortorder = moodle_course.sortorder
          course.fullname = moodle_course.fullname
          course.shortname = moodle_course.shortname
          course.idnumber = moodle_course.idnumber
          course.summary = ActionView::Base.full_sanitizer.sanitize(moodle_course.summary)
          course.summaryformat = moodle_course.summaryformat
          course.format = moodle_course.format
          course.showgrades = moodle_course.showgrades
          course.newsitems = moodle_course.newsitems
          course.startdate = moodle_course.startdate
          course.maxbytes = moodle_course.maxbytes
          course.lang = moodle_course.lang
          course.theme = moodle_course.theme
          course.timecreated = moodle_course.timecreated
          course.timemodified = moodle_course.timemodified
        end
      rescue
        Rails.logger.debugger("Couldn't save #{moodle_course.id}")
        next
      end
    end
  rescue
    Rails.logger.debugger("Couldn't get courses from Moodle Database.")
  end
end