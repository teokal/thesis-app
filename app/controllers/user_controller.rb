class UserController < ApplicationController

  def index
    User.all
  end

  def show(id)
    User.find_by(id: id)
  end

end
