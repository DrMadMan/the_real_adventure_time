class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :create_first_group

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  has_many :memberships
  has_many :groups, :through => :memberships

  has_many :owned_groups, :class_name => :Group, :foreign_key => :user_id

  validates_presence_of :name
  validates_uniqueness_of :email, :case_sensitive => false

  def create_first_group
    @Group = Group.create(title: self.name + "'s group", description: "The default group for " + self.name)
    self.groups << @Group
  end
end