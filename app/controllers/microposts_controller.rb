class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy


  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

# At this point, creating a new micropost works as expected, as seen in
# Figure 11.15. There is one subtlety, though: on failed micropost submission,
# the Home page expects an @feed_items instance variable, so failed submissions
# currently break. The easiest solution is to suppress the feed entirely by
# assigning it an empty array, as shown in Listing 11.48. (Unfortunately,
# returning a paginated feed doesn’t work in this case. Implement it and click
# on a pagination link to see why.)


 def destroy
   @micropost.destroy
   flash[:success] = "Micropost deleted"
   redirect_to request.referrer || root_url
 end

# This uses the request.referrer method,11 which is closely related to the
# request.url variable used in friendly forwarding (Section 9.2.3), and is just
# the previous URL (in this case, the Home page).12 This is convenient because
# microposts appear on both the Home page and on the user’s profile page, so by
# using request.referrer we arrange to redirect back to the page issuing the
# delete request in both cases. If the referring URL is nil (as is the case inside
# some tests), Listing 11.50 sets the root_url as the default using the || operator.


  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id]) #this is a way to check that the current user is the owner of that micropost that will be deleted
      redirect_to root_url if @micropost.nil?
    end

    # We’ll find the micropost through the association, which will automatically fail
    # if a user tries to delete another user’s micropost. We’ll put the resulting find
    # inside a correct_user before filter, which checks that the current user actually
    # has a micropost with the given id.
end
