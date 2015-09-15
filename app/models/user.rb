class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

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

end
