require "guard"
require "guard/plugin"

module Guard
  class Teaspoon < Plugin
    require "guard/teaspoon/resolver"
    require "guard/teaspoon/runner"

    attr_accessor :runner, :failed_paths, :last_failed

    def initialize(options = {})
      super
      @options = {
        focus_on_failed:      false,
        all_after_pass:       true,
        all_on_start:         true,
        keep_failed:          true,
        formatters:           'clean',
        run_all:              {},
        run_on_modifications: {}
      }.merge(options)
    end

    def start
      reload
      @resolver = Resolver.new(@options)
      @runner = Runner.new(@options)
      UI.info "Guard::Teaspoon is running"
      run_all if @options[:all_on_start]
    end

    def reload
      @last_failed = false
      @failed_paths = []
    end

    def run_all
      pass = @runner.run(@options[:run_all])

      if pass
        Notifier.notify("Success", title: "Teaspoon Guard", image: :success)
      else
        Notifier.notify("Failed", title: "Teaspoon Guard", image: :failed)
      end
      @last_failed = !pass
    end

    def run_on_modifications(original_paths)
      pass = @runner.run(@options[:run_on_modifications].merge(files: original_paths))

      if pass
        Notifier.notify("Success", title: "Teaspoon Guard", image: :success)
        run_all if @last_failed
      else
        Notifier.notify("Failed", title: "Teaspoon Guard", image: :failed)
        @last_failed = true
      end
    end
  end
end
