class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

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
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end
end
