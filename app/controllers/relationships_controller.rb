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

end
