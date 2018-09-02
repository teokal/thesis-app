class ChangeDefaultCategoryFromNoneToUncategorized < ActiveRecord::Migration
  def change
    CourseCategory.where(name: "None").update_all(name: "Uncategorized")
  end
end
