require 'httparty'

class ExecutionWorker
  include Sidekiq::Worker
  include EventConstants
  include DirectoryMethods

  sidekiq_options retry: false

  def perform(chain_id, callback_url)
    ap "Perform - chain id#{chain_id}"
    sleep(5) unless Rails.env.test? # icky hack to solve race condition - not final solution

    @process_chain = ProcessChain.includes(:process_steps).find(chain_id)
    runner = Execution::RecipeExecutionRunner.new(process_steps_in_order: process_steps_in_order, chain_file_location: @process_chain.working_directory, process_chain: @process_chain)
    begin
      runner.run!
    rescue => e
      ap e.message
      ap e.backtrace
      raise e
    ensure
      post_to_callback(callback_url)
    end
  end

  def process_steps_in_order
    @process_chain.process_steps.order(:position)
  end

  def post_to_callback(callback_url)
    return unless callback_url.present?
    begin
      HTTParty.post(callback_url,
                    :body => serialized_chain,
                    :headers => { 'Content-Type' => 'application/json' } )
    rescue => e
      ap "Could not post to callback URL #{callback_url}"
      ap "#{e.message}"
      ap "#{e.backtrace}"
    end
  end

  def serialized_chain
    serialization = ActiveModelSerializers::SerializableResource.new(@process_chain)
    serialization.to_json
  end
end