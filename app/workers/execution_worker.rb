require 'httparty'

class ExecutionWorker
  include Sidekiq::Worker
  include EventConstants

  sidekiq_options retry: false

  def perform(chain_id, callback_url)
    @process_chain = ProcessChain.includes(:process_steps).find(chain_id)
    runner = Execution::RecipeExecutionRunner.new(process_step_hash: process_step_hash, chain_file_location: @process_chain.working_directory, chain_id: chain_id)
    trigger_event(channels: process_chain_channel(@process_chain.id), event: process_chain_started_processing_event)
    begin
      runner.run!
      trigger_event(channels: process_chain_channel(@process_chain.id), event: process_chain_done_processing_event)
    rescue => e
      ap e.message
      ap e.backtrace
      trigger_event(channels: process_chain_channel(@process_chain.id), event: process_chain_error_event)
    end
    @process_chain.map_results(runner.step_array)
    @process_chain.update_attribute(:finished_at, Time.now)
    post_to_callback(callback_url)
  end

  def process_step_hash
    @process_chain.process_steps.order(:position).inject({}) do |result, step|
      result[step.position] = step
      result
    end
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