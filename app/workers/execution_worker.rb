require 'httparty'

class ExecutionWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(chain_id, callback_url)
    process_chain = ProcessChain.find(chain_id)
    runner = Execution::RecipeExecutionRunner.new(process_chain.step_classes)
    runner.run!(files: process_chain.input_file)
    process_chain.map_results(runner, process_chain.process_steps.sort_by(&:position))
    process_chain.update_attribute(:finished_at, Time.now)
    post_to_callback(process_chain, callback_url)
  end

  def post_to_callback(process_chain, callback_url)
    return unless callback_url.present?
    begin
      HTTParty.post(callback_url,
                    :body => serialized_chain(process_chain),
                    :headers => { 'Content-Type' => 'application/json' } )
    rescue => e
      ap "Could not post to callback URL #{callback_url}"
      ap "#{e.message}"
      ap "#{e.backtrace}"
    end
  end

  def serialized_chain(process_chain)
    serialization = ActiveModelSerializers::SerializableResource.new(process_chain)
    serialization.to_json
  end
end