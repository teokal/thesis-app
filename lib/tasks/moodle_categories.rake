task import_moodle_categories: :environment do
  begin
    moodle_categories = MoodleCourseCategory.all
    moodle_categories.each do |moodle_category|
      begin
        CourseCategory.where(moodle_id: moodle_category.id).first_or_create do |category|
          category.name = moodle_category.name
          category.idnumber = moodle_category.idnumber
          category.description = moodle_category.description
          category.descriptionformat = moodle_category.descriptionformat
          category.parent = moodle_category.parent
          category.sortorder = moodle_category.sortorder
          category.coursecount = moodle_category.coursecount
          category.visible = moodle_category.visible
          category.visibleold = moodle_category.visibleold
          category.timemodified = moodle_category.timemodified
          category.depth = moodle_category.depth
          category.path = moodle_category.path
          category.theme = moodle_category.theme
        end
      rescue
        Rails.logger.debugger("Couldn't save #{moodle_category.id}")
        next
      end
    end
  rescue
    Rails.logger.debugger("Couldn't get categories from Moodle Database.")
  end
end