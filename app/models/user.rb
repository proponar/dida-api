class User < ApplicationRecord
  has_many :entries

  def self.max_user
    max = User.maximum(:db)
    max.nil? ? 0 : max
  end

  def self.find_or_create_user_by_jwt_token(token)
    begin
      decoded_token = JWT.decode(token, nil, false)
      user_data = decoded_token.find do |el|
        el['iss'] == "accounts.google.com"
      end
      email = user_data["email"]

      u = User.find_by(:name => email)
      if u.nil?
        u = User.create(
          :name => user_data["email"],
          :token => SecureRandom.hex,
          :db => max_user + 1,
        )
        u.save!
      end
      u
    rescue => e
      return nil
    end
  end
end
