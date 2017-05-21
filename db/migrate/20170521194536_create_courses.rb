class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.integer 'coursecategory', limit: 8, default: 0, null: false
      t.integer 'sortorder', limit: 8, default: 0, null: false
      t.string 'fullname', limit: 254, default: '', null: false
      t.string 'shortname', default: '', null: false
      t.string 'idnumber', limit: 100, default: '', null: false
      t.text 'summary', limit: 2147483647
      t.integer 'summaryformat', limit: 1, default: 0, null: false
      t.string 'format', limit: 21, default: 'topics', null: false
      t.integer 'showgrades', limit: 1, default: 1, null: false
      t.integer 'newsitems', limit: 3, default: 1, null: false
      t.integer 'startdate', limit: 8, default: 0, null: false
      t.integer 'marker', limit: 8, default: 0, null: false
      t.integer 'maxbytes', limit: 8, default: 0, null: false
      t.integer 'legacyfiles', limit: 2, default: 0, null: false
      t.integer 'showreports', limit: 2, default: 0, null: false
      t.boolean 'visible', default: true, null: false
      t.boolean 'visibleold', default: true, null: false
      t.integer 'groupmode', limit: 2, default: 0, null: false
      t.integer 'groupmodeforce', limit: 2, default: 0, null: false
      t.integer 'defaultgroupingid', limit: 8, default: 0, null: false
      t.string 'lang', limit: 30, default: '', null: false
      t.string 'theme', limit: 50, default: '', null: false
      t.integer 'timecreated', limit: 8, default: 0, null: false
      t.integer 'timemodified', limit: 8, default: 0, null: false
      t.boolean 'requested', default: false, null: false
      t.boolean 'enablecompletion', default: false, null: false
      t.boolean 'completionnotify', default: false, null: false
      t.integer 'cacherev', limit: 8, default: 0, null: false
      t.string 'calendartype', limit: 30, default: '', null: false
      t.integer 'moodle_id', limit: 8, default: 0, null: false

      t.timestamps
    end
  end
end
