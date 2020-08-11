class Exemp < ApplicationRecord
  belongs_to :entry
  belongs_to :user, foreign_key: 'author_id'
  # belongs_to :zdroj, foreign_key: 'zdroj_id'
end
