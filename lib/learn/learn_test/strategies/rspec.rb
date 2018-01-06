module LearnTest
  module Strategies
    class Rspec < LearnTest::Strategy


      def directory
        "./labs/#{self.runner.repo}"
      end
      def service_endpoint
        '/logs'
      end

      def detect

        runner.files.include?('spec') && (spec_files.include?('spec_helper.rb') || spec_files.include?('rails_helper.rb'))
      end

      def configure

        if argv

          if format_option_present?
            if dot_rspec.any? {|dot_opt| dot_opt.match(/--format|-f/)}
              argv << dot_rspec.reject {|dot_opt| dot_opt.match(/--format|-f/)}
            else
              argv << dot_rspec
            end
            argv.flatten!
          else
            argv.unshift('--format documentation')
          end

          if fail_fast_option_present?
            argv << '--fail-fast'
          end

          # Don't pass the test/local flag from learn binary to rspec runner.
          argv.delete("--test")
          argv.delete("-t")
          argv.delete("-l")
          argv.delete("--local")
        else
        end
      end

      def run

        if argv
          system("cd labs/#{self.runner.repo} && #{bundle_command} rspec #{argv.join(' ')} --format j --out .results.json")
        else
          # byebug
          # system("cd labs/#{self.runner.repo} && #{bundle_command} rspec --format j --out .results.json")
          Bundler.with_clean_env {`cd ./labs/"#{self.runner.repo}" && rspec --format j --out .results.json`}
        end


      end

      def output
        File.exists?("#{directory}/.results.json") ? Oj.load(File.read("#{directory}/.results.json"), symbol_keys: true) : nil
      end

      def save_log

        lab = Lab.find_by(title: runner.repo)
        if !lab
          lab = Lab.create(title: runner.repo, test_suite: "rspec")
        end
        log = lab.logs.build(log_results)
        log.save
        log.update_lab
        log

        # field :examples, type: Integer
        # field :pending_count, type: Integer
        # field :failure_count, type: Integer
        # field :passing_count, type: Integer
        # field :test_ran, type: Boolean
        # field :failure_descriptions, type: String

        # field :passing_count, type: Integer
        # field :failing_count, type: Integer
        # field :test_ran, type: Boolean

        # runner.repo
        # examples
        # passing_count
        # pending_count
        # failure_count
        # failure_descriptions
      end

      def log_results
        {
          result: output && output[:messages] ? output[:messages].join(" ") : nil,
          duration: output ? output[:summary][:duration] : nil,
          examples: output ? output[:summary][:example_count] : 1,
          passing_count: output ? output[:summary][:example_count] - output[:summary][:failure_count] - output[:summary][:pending_count] : 0,
          pending_count: output ? output[:summary][:pending_count] : 0,
          failure_count: output ? output[:summary][:failure_count] : 1,
          failure_descriptions: failures
        }
      end

      def results
        {
          username: username,
          github_user_id: user_id,
          learn_oauth_token: learn_oauth_token,
          repo_name: runner.repo,
          build: {
            test_suite: [{
              framework: 'rspec',
              formatted_output: output,
              duration: output ? output[:summary][:duration] : nil
            }]
          },
          examples: output ? output[:summary][:example_count] : 1,
          passing_count: output ? output[:summary][:example_count] - output[:summary][:failure_count] - output[:summary][:pending_count] : 0,
          pending_count: output ? output[:summary][:pending_count] : 0,
          failure_count: output ? output[:summary][:failure_count] : 1,
          failure_descriptions: failures
        }
      end

      def cleanup
        # FileUtils.rm('.results.json') if File.exist?('.results.json')
      end

      private

      def bundle_command
        File.exist?("#{directory}/Gemfile") && !!File.read("#{directory}/Gemfile").match(/^\s*gem\s*('|")rspec(-[^'"]+)?('|").*$/) ? 'bundle exec' : ''
      end

      def spec_files
        @spec_files ||= Dir.entries("#{directory}/spec")
      end

      def format_option_present?
        options[:format]
      end

      def fail_fast_option_present?
        options[:fail_fast]
      end

      def dot_rspec
        @dot_rspec ||= File.readlines("#{directory}/.rspec").map(&:strip) if File.exist?("#{directory}/.rspec")
      end

      def failures
        if output
          output[:examples].select do |example|
            example[:status] == "failed"
          end.map { |ex| ex[:full_description] }.join(";")
        else
          'A syntax error prevented RSpec from running.'
        end
      end

    end
  end
end
