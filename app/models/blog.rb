# encoding: UTF-8

class Blog < ActiveRecord::Base
  # relationships
  has_many              :blog_images
  has_many              :posts, :order => 'published_at DESC'
  belongs_to            :category
  belongs_to            :user
  validates_presence_of :name
  # permalink based on :name
  # has_permalink         :name, :update => true, :if => Proc.new { |blog| blog.permalink.blank? }
  before_save :update_permalink

  def update_permalink
    self.permalink ||= self.name.parameterize
  end


  # attached :banner config
  has_attached_file     :banner, :styles => {:thumbnail =>"270x50", :large => "741x120>#"}, :storage => :s3,
                    :s3_credentials => { :access_key_id => "1B7JJ1RZXMZP7VQADY02" , :secret_access_key =>"8UvZq1RtsyE72t0vq2U1FaaZStGXm9fj87uFub2b" },
                    :path => "system/:attachment/:id/:style/:basename.:extension",
                    :bucket => lambda { |attachment| i = attachment.instance.id;  i = (i ? i % 4 : 0) ;"assets#{i}.votencamotes.com"}
  #named scopes
  scope :active,
              :conditions => {:active => true}
  scope :inactive,
              :conditions => {:active => false}
  scope :from_named_category,
                lambda { |category_name|
                  { :conditions =>
                    {:blog => {:categories => {:permalink => category_name}}},
                  :joins => :category
                  }
                }
  scope :most_visited,
              lambda {|limit| limit = 5 if limit.nil?
                      {:order =>  'visits_count DESC',
                       :limit => limit
                     }
               }

  # methods
  def owned?
    return false unless user
  end

  def self.list
    Blog.all
  end

  def last_updated
    return self.posts.published.empty? ? nil : self.posts.published.first.published_at
  end

  def profile
    return self.user_id.nil? ? nil : Profile.find_by_user_id(self.user_id)
  end

  def last_post
    return self.posts.published.empty? ? nil : self.posts.published.first
  end

  def tag_list
    Tag.find(:all, :select => "tags.name, count(taggins.tag_id) as tag_count",
              :joins => "INNER JOIN taggins ON taggins.tag_id = tags.id
                         INNER JOIN posts ON taggins.taggable_id = posts.id",
              :conditions => ["posts.blog_id = ?", self.id],
              :group => "taggings.tag_id",
              :order => "tag_count DESC",
              :limit => 8)
  end

  def months
    self.posts.find(:all,
                    :select => "count(*) as post_count, published_at",
                    :group  => "year(published_at), month(published_at)",
                    :order  => "published_at DESC")
  end

  def posts_categories
    self.user.categories.with_fields("name")
  end

  def category_name
    self.category.nil? ? '' : self.category.name
  end



  def update_posts_count
    self.posts_count = self.posts.empty? ? 0 : self.posts.count
  end
  
  def to_param
    "#{id}-#{try(:name).try(:parameterize)}"
  end
end




# == Schema Information
#
# Table name: blogs
#
#  id                  :integer(4)      not null, primary key
#  name                :string(255)
#  permalink           :string(255)
#  banner_file_name    :string(255)
#  banner_content_type :string(255)
#  banner_file_size    :integer(4)
#  banner_updated_at   :datetime
#  banner              :string(255)
#  category_id         :integer(4)
#  active              :boolean(1)
#  posts_count         :integer(4)
#  visits_count        :integer(4)
#  created_at          :datetime
#  updated_at          :datetime
#  user_id             :integer(4)
#  description         :text
#

