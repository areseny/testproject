require 'sidekiq/api'

module WaitForAsync
  def wait_for_async
    Timeout.timeout(1000) do
      loop until requests_finished?
    end
  end

  private

  def requests_finished?
    workers = Sidekiq::Workers.new
    workers.size < 1
    # workers.each do |name, work|
    #   # name is a unique identifier per Processor instance
    #   # work is a Hash which looks like:
    #   # { 'queue' => name, 'run_at' => timestamp, 'payload' => msg }
    # end
  end
end

# RSpec.configure do |config|
#   config.include WaitForAsync
# end