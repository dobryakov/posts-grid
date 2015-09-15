class Tag < ActiveRecord::Base
  has_many :post_tags
  has_many :posts, :through => :post_tags, :source => :post
  validates_uniqueness_of :content
  validates_presence_of :content
end
