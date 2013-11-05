require 'spec_helper'

describe Cacheable do 

	let(:cache) { Rails.cache }
  let(:user)  { User.create(:login => 'flyerhzm') }

  before :all do
    @post1 = user.posts.create(:title => 'post1')
    @post2 = user.posts.create(:title => 'post2')
    user.save
  end

 	describe "singleton fetch" do

 		it "should find an object by id" do
 			key = User.instance_cache_key(1)
 			Cacheable::ModelFetch.fetch(key) do 
 				User.find(1)
 			end.should == user
 		end
 	end

 	describe "association fetch" do

 		it "should find associations by name" do
 			key = user.have_association_cache_key(:posts)
 			Cacheable::ModelFetch.fetch(key) do 
 				user.send(:posts)
 			end.should == [@post1, @post2]
 		end
 	end
end
