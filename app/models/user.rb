class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  # It’s worth noting that we could actually omit the :source key for followers
  # This is because, in the case of a :followers attribute, Rails will singularize
  # “followers” and automatically look for the foreign key follower_id in this
  # case. Listing 12.8 keeps the :source key to emphasize the parallel structure
  # with the has_many :following association.
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email   # before_save { self.email = email.downcase }  # we created a method for this now
  before_create :create_activation_digest
  validates :name, presence: true, length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: {case_sensitive: false}
  # validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  # In case you’re worried that Listing 9.10 might allow new users to sign up
  # with empty passwords, recall from Section 6.3.3 that has_secure_password
  # includes a separate presence validation that specifically catches nil
  # passwords. (Because nil passwords now bypass the main presence validation but
  # are still caught by has_secure_password , this also fixes the duplicate error
  # message mentioned in Section 7.3.3.).
  # Basically what this is doing is that when updating/editing the user attributes, if
  # the user does not update the password and confirmation fields (leaves it nil)
  # then it will keep its password as the original password that they
  # used when they signed up.


  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # $ rails console
  #   >> a = [1, 2, 3]
  #   >> a.length
  #   => 3
  #   >> a.send(:length)
  #   => 3
  #   >> a.send('length')
  #   => 3

    # >> user = User.first
    # >> user.activation_digest
    # => "$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKRM6N9Ae"
    # >> user.send(:activation_digest)
    # => "$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKRM6N9Ae"
    # >> user.send('activation_digest')
    # => "$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKRM6N9Ae"
    # >> attribute = :activation
    # >> user.send("#{attribute}_digest")
    # => "$2a$10$4e6TFzEJAVNyjLv8Q5u22ensMt28qEkx0roaZvtRcp6UZKRM6N9Ae"

  # Returns true if the given token matches the digest.
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end

  # Defines a proto-feed.
  # See "Following users" for the full implementation.
  # Since each user should have a feed, we are led naturally to a feed method in
  # the User model, which will initially just select all the microposts belonging
  # to the current user.
  
# def feed
#   # microposts
#   Micropost.where("user_id = ?", id) #this is just a list of all the microposts
# end

  # The question mark ensures that id is properly escaped before being included
  # in the underlying SQL query, thereby avoiding a serious security hole called
  # SQL injection. The id attribute here is just an integer (i.e., self.id, the
  # unique ID of the user), so there is no danger of SQL injection in this case,
  # but always escaping variables injected into SQL statements is a good habit to
  # cultivate.

  # Returns a user's status feed.
  def feed
    Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired. “Password reset sent earlier than thirty minutes ago.”
  def password_reset_expired?
    reset_sent_at < 30.minutes.ago
  end

  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private

  # Converts email to all lower-case.
  def downcase_email
    self.email = email.downcase
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end





=begin

Expression	Meaning

/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i	full regex

/	start of regex

\A	match start of a string

[\w+\-.]+	at least one word character, plus, hyphen, or dot

@	literal “at sign”

[a-z\d\-.]+	at least one letter, digit, hyphen, or dot

\.	literal dot

[a-z]+	at least one letter

\z	match end of a string

/	end of regex

i	case-insensitive

Table 6.1: Breaking down the valid email regex.

=end


=begin

Recall from the proto-feed in Section 11.3.3 that Active Record uses the where
method to accomplish the kind of select shown above, as illustrated in Listing
11.44. There, our select was very simple; we just picked out all the microposts
with user id corresponding to the current user:

Micropost.where("user_id = ?", id)

Here, we expect it to be more complicated, something like this:

Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)

We see from these conditions that we’ll need an array of ids corresponding to
the users being followed. One way to do this is to use Ruby’s map method,
available on any “enumerable” object, i.e., any object (such as an Array or
a Hash) that consists of a collection of elements.9 We saw an example of this
method in Section 4.3.2; as another example, we’ll use map to convert an
array of integers to an array of strings:

$ rails console
>> [1, 2, 3, 4].map { |i| i.to_s }
=> ["1", "2", "3", "4"]
Situations like the one illustrated above, where the same method gets called on
each element in the collection, are common enough that there’s a shorthand
notation for it (seen briefly in Section 4.3.2) that uses an ampersand & and a
symbol corresponding to the method:

>> [1, 2, 3, 4].map(&:to_s)
=> ["1", "2", "3", "4"]
Using the join method (Section 4.3.1), we can create a string composed of the
ids by joining them on comma-space :

>> [1, 2, 3, 4].map(&:to_s).join(', ')
=> "1, 2, 3, 4"
We can use the above method to construct the necessary array of followed user
ids by calling id on each element in user.following. For example, for the first
user in the database this array appears as follows:

>> User.first.following.map(&:id)
=> [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
43, 44, 45, 46, 47, 48, 49, 50, 51]
In fact, because this sort of construction is so useful, Active Record provides
it by default:

>> User.first.following_ids
=> [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
43, 44, 45, 46, 47, 48, 49, 50, 51]
Here the following_ids method is synthesized by Active Record based on the
has_many :following association (Listing 12.8); the result is that we need only
append _ids to the association name to get the ids corresponding to the
user.following collection. A string of followed user ids then appears as follows:

>> User.first.following_ids.join(', ')
=> "4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23,
24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
43, 44, 45, 46, 47, 48, 49, 50, 51"
When inserting into an SQL string, though, you don’t need to do this;
the ? interpolation takes care of it for you (and in fact eliminates some
database-dependent incompatibilities). This means we can use following_ids by itself.

As a result, the initial guess of

Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
actually works!

=end
