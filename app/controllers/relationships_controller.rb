class RelationshipsController < ApplicationController
  before_action :logged_in_user

# for using standard way
  # def create
  #   user = User.find(params[:followed_id])
  #   current_user.follow(user)
  #   redirect_to user
  # end
  #
  # def destroy
  #   user = Relationship.find(params[:id]).followed
  #   current_user.unfollow(user)
  #   redirect_to user
  # end

# for using AJAX
  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  # The actions above degrade gracefully, which means that they work
  # fine in browsers that have JavaScript disabled (although a small amount of
  # configuration is necessary, as shown in last line of config/application.rb

  # In the case of an Ajax request, Rails automatically calls a JavaScript 
  # embedded Ruby (.js.erb) file with the same name as the action, i.e., create.js.erb
  # or destroy.js.erb. As you might guess, such files allow us to mix JavaScript
  # and embedded Ruby to perform actions on the current page. It is these files
  # that we need to create and edit in order to update the user profile page upon
  # being followed or unfollowed.

end
