class TestRunner

  attr_accessor :shell, :lab

  def initialize(lab)
    @lab = lab
    @shell = TTY::Command.new
  end

  def self.get_labs
#     client = Octokit::Client.new(:login => ENV["git_user"], :password => ENV["git_password"])
# # Fetch the current user
#     client.user
#     client
    client_id = ENV["git_client_id"]
    client_secret = ENV["git_client_secret"]
    labs = []
    for i in 1..37
      response = RestClient.get("https://api.github.com/orgs/learn-co-curriculum/repos?per_page=100&page=#{i}&client_id=#{client_id}&client_secret=#{client_secret}", headers={})
      repos = JSON.parse(response)
      labs += repos
    end
    labs.collect { |lab| lab["name"] }.select { |l| l.include?("rails") && l.include?("lab") }
    labs.each { |lab| Lab.create(title: lab["name"]) }
  end

  def run
    clean
    clone
  end

  def clone
    shell.run!("git clone -b solution git@github.com:learn-co-curriculum/#{lab}.git", chdir: "./labs")
  end


  def clean
    shell.run("rm -rf #{lab}", chdir: "./labs")
  end

  def self.evaluate(lab)
    cmd = TTY::Command.new
    cmd.run!("rm -rf #{lab}")
    cmd.run!("git clone -b solution git@github.com:learn-co-curriculum/#{lab}.git")
    #yarn_out, yarn_err = cmd.run("yarn", chdir:"./#{lab}")
    out,err = cmd.run!('learn test', chdir:"./#{lab}")


    outputArray = out.split(" ")
    warningArray = err.split("\n")
    #warningArray = err.split("\n") + yarn_err.split("\n")
    log_obj = { warnings: err }
    if passing_index = outputArray.index("passing")
      passcount = outputArray[passing_index-1]
      log_obj["passing_count"] = passcount
      log_obj["test_ran"] = true
    else
      log_obj["passing_count"] = 0
      log_obj["test_ran"] = false
    end
    if failing_index = outputArray.index("failing")
      failcount = outputArray[failing_index-1]
      log_obj["failing_count"] = failcount
    else
      log_obj["failing_count"] = 0
    end
    log_obj["name"] = lab
    cmd.run!("rm -rf #{lab}")
    log_obj
  end

  def self.run
    start = Time.now
    if labs = get_labs

      react_labs = labs.select do |lab|
        return lab["name"].include?("react")
      end
      puts labs.count
      labs.each do |testlab|
        msg_obj = evaluate testlab["name"]
        lab = Lab.find_or_create_by(title: msg_obj["name"])
        lab.logs.create(test_ran: msg_obj["test_ran"], warnings: msg_obj[:warnings], passing_count: msg_obj["passcount"], failing_count: msg_obj["failcount"])
      end
    else
      "No Labs Tested"
    end
    complete = Time.now
    elapsed_time = (complete - start) * 1000.0

  end
end
