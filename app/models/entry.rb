class Entry < ApplicationRecord
  belongs_to :user, foreign_key: 'author_id'
  has_paper_trail

  validates :heslo, presence: true, uniqueness: true
end
