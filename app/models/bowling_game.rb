class BowlingGame < ActiveRecord::Base
  has_many :throws

  def frames
    binding.pry
    throws.each_slice(2) 
  end
end
