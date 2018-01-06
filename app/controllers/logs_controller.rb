
# require_relative '../lib/test_runner'
# require_relative '../lib/learn-test/lib/learn_test'

class LogsController < ApplicationController



  def index
    render json: Log.all.entries
  end


  def show
  end


  def run
    runner = TestRunner.new(params[:title])
    runner.run
    repo = LearnTest::RepoParser.fetch_repo(runner.lab)
    LearnTest::Runner.new(repo, {}).run
    log = Log.last
    render json: log
  end




  # all lab
  def create
    TestRunner.get_labs
  end

end
