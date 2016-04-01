class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order(created_at: :desc) } #order('created_at DESC') Here DESC is SQL for “descending”, i.e., in descending order from newest to oldest.5 In older versions of Rails, using this raw SQL used to be the only option to get the desired behavior, but as of Rails 4.0 we can use a more natural pure-Ruby syntax as well: order(created_at: :desc)
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size

  private

     # Validates the size of an uploaded picture.
     def picture_size
       if picture.size > 5.megabytes
         errors.add(:picture, "should be less than 5MB")
       end
     end

end


# In contrast to previous model validations, file size validation doesn’t
# correspond to a built-in Rails validator. As a result, validating images
# requires defining a custom validation, which we’ll call picture_size and define
# as shown in Listing 11.61. Note the use of validate (as opposed to validates)
# to call a custom validation.


=begin

Method	                            Purpose

micropost.user	                    Returns the User object associated with the micropost
user.microposts	                    Returns a collection of the user’s microposts
user.microposts.create(arg)	        Creates a micropost associated with user
user.microposts.create!(arg)        Creates a micropost associated with user (exception on failure)
user.microposts.build(arg)	        Returns a new Micropost object associated with user
user.microposts.find_by(id: 1)	    Finds the micropost with id 1 and user_id equal to user.id

Table 11.1: A summary of user/micropost association methods.

=end
