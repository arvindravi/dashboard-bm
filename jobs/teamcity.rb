require 'httparty'
require 'ostruct'

class TeamCity
  include HTTParty
  
	# Constants
	TC_CONSTANTS = { 
					agents: '/agents/'.freeze,
					builds: '/builds/'.freeze,
					running_builds: '/builds?locator=running:true'.freeze
	}
	private_constant :TC_CONSTANTS

  def initialize
    @baseURL = 'http://10.10.0.80:8111/app/rest/'
    @endpoints = {
			:builds => { all: 'builds/', running: 'builds?locator=running:true' },
			:agents => 'agents/'
		}
		@options = { 
						auth: { :username => 'arvindravi', :password => '>zC*gep}=*v+,7m' },
						content_type: { 'Accept' => 'application/json'  }
		}
  end

  def builds
	  url = @baseURL + @endpoints[:builds][:all]
		parse url
		@builds
  end

	def running_builds
		url = @baseURL + @endpoints[:builds][:running]
		parse url
		running_builds = JSON.parse(@running_builds.parsed_response, object_class: OpenStruct)
	end

  def agents
    url = @baseURL + @endpoints[:agents]
		parse url
		@agents
  end

	private
	def get url
		self.class.get(url, :basic_auth => @options[:auth], headers: @options[:content_type])
	end

	def parse url
			patterns = [
					/.+(\/.*\/)$/,
					/.+(\/.*\?.*)/
			]
			re = Regexp.union(patterns)
			matched = url.match re if url.match? re
			case matched[1]
			when "/agents/" then @agents = get(url)
			when "/builds/" then @builds = get(url)
			when TC_CONSTANTS[:running_builds] then @running_builds = get(url)
			else "It matched #{matched}. What would I do with that?"
			end

			case matched[2]
			when TC_CONSTANTS[:running_builds] then @running_builds = get(url)
			else "It matched #{matched}. Wat do?"
			end
	end

end

teamcity= TeamCity.new
# teamcity.agents
puts teamcity.running_builds