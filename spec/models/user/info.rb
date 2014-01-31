class User::Info < ActiveRecord::Base
  has_one :avatar,  :source => :viewable,
                    :class_name => "Image"

  model_cache do
    with_association :avatar
  end
end