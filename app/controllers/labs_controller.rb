class LabsController < ApplicationController

  def index
    @labs = Lab.all.entries
    render json: @labs
  end

  def show
    @lab  = Lab.find_by(title: params[:id])
    render json: @lab
  end

  def setup
    labs = TestRunner.get_labs
    rails_labs = labs.select { |lab| lab.include?("rails") && lab.include?("lab") }
    runner = TestRunner.new(rails_labs.sample)
    runner.run
    repo = LearnTest::RepoParser.fetch_repo(runner.lab)
    LearnTest::Runner.new(repo, {}).run
    log = Log.last
    render json: log.lab
    # labs.sample.each do |lab|
    #   runner = TestRunner.new(lab)
    #   runner.run
    # end
  end

  def create
  end

  def update
  end

  def run
    @lab  = Lab.find_by(title: params[:title])
    TestRunner.test_lab(@lab.title)
    log = Log.last
    render json: log.lab
  end
end
