class Relationship < ActiveRecord::Base
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end


=begin

The relationships in Listing 12.2 and Listing 12.3 give rise to methods
analogous to the ones we saw in Table 11.1, as shown in Table 12.1.

Method	Purpose
active_relationship.follower	                                        Returns the follower
active_relationship.followed	                                        Returns the followed user
user.active_relationships.create(followed_id: other_user.id)	        Creates an active relationship associated with user
user.active_relationships.create!(followed_id: other_user.id)	        Creates an active relationship associated with user (exception on failure)
user.active_relationships.build(followed_id: other_user.id)	          Returns a new Relationship object associated with user

Table 12.1: A summary of user/active relationship association methods.

=end
