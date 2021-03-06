require 'spec_helper'

describe Group do
	it 'is valid with a name and email and password' do
		expect(build(:page)).to be_valid
	end
	it 'is not valid without name' do
		expect(build(:page, :title => nil)).to have(1).errors_on(:title)
	end
	it 'is not valid without email' do 
		expect(build(:page, :content => nil)).to have(1).errors_on(:content)
	end

	it 'has at least one group on creation' do
		page1 = create(:page)
		expect(page1.group).to be_valid
	end

	it 'is valid with profanity in content' do
		expect(build(:page, :content => "ass")).to be_valid
	end

	it 'is returning valid search results' do
		page1 = create(:page, :title => "Taco Time")

		expect(Page.search("co")).to include(page1)
	end

	describe 'groups recieving votes' do 

		before :each do 
			@voter = create(:user)
			@page = create(:page)
			@group = @page.group
		end

		it 'is incrementing vote count when groups page is voted for ' do
			expect { @page.add_or_update_evaluation(:votes, 2, @voter) }.to change{@group.votes}.by(2)
		end
	end
end