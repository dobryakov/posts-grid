class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  has_many :posts

  def self.find_for_facebook_oauth auth

    Rails.logger.debug auth.to_json

    User.where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email            = auth.uid + '@facebook.com'
        user.username         = auth.info.name
        user.image            = auth.info.image
        user.token            = auth.credentials.token
        user.token_expires_at = Time.at(auth.credentials.expires_at.to_i)
        user.password         = Devise.friendly_token[0,20]
    end

  end

  def fetch_public_posts
    @graph = Koala::Facebook::API.new(User.last.token)
    @graph.get_connections("me", "posts", {fields: ['message', 'privacy']} ).select{|post| post['privacy']['value'] == 'EVERYONE' && post['message'].present? }
  end

  def parse_hashtags(message)
    message.scan(/#\S+/).map{|tag| tag.tr('#', '') }
  end

  def update_posts
    self.fetch_public_posts.each{|post|

      content = post['message']
      uid     = post['id']

      post = Post.where(:uid => uid).first_or_create do |post|
        post.content = content
        post.user    = self
      end

      parse_hashtags(content).each{|hashtag|
        tag = Tag.find_or_create_by(:content => hashtag)
        PostTag.find_or_create_by(:tag => tag, :post => post)
      }

    }
  end

end
