class MoodleLog < MoodleDatabase
  self.pluralize_table_names = false
  self.table_name = "#{ENV['MOODLE_DB_PREFIX']}log"

end