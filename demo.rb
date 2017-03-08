require_relative 'hyperactive.rb'
DBConnection::reset

class Human < Hyperactive
  has_many :cats,
    foreign_key: :owner_id

  belongs_to :house
end

class Cat < Hyperactive
  belongs_to :owner,
    foreign_key: :owner_id,
    class_name: "Human"

  has_one_through :house, :owner, :house
end

class House < Hyperactive
  has_many :humans,
    foreign_key: :house_id,
    class_name: "Human"
end

Human.finalize!
Cat.finalize!
House.finalize!
