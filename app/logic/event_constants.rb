module EventConstants

  # To trigger:

  # Pusher.trigger('channel', 'event', {foo: 'bar'})
  # Pusher.trigger(['channel_1', 'channel_2'], 'event_name', {foo: 'bar'})

  def trigger_event(channels:, event:, data: {})
    log "Triggering event #{event} on channels #{channels} with data #{data}"
    log "Pusher info: app ID: #{Pusher.app_id}, key: #{Pusher.key}, secret: #{Pusher.secret}, host: #{Pusher.host}, port: #{Pusher.port}"
    Pusher.trigger(channels, event, data)
  rescue Pusher::Error => e
    # (Pusher::AuthenticationError, Pusher::HTTPError, or Pusher::Error)
    log "PUSHER ERROR!"
    log e.message
    log e.backtrace
  rescue => e
    log e.message
    log e.backtrace
  end

  def log(message)
    if self.respond_to?(:log_as_step)
      log_as_step message
    else
      ap message
    end
  end

  # recipe channel and events

  def recipe_channel(recipe_id)
    "recipe_#{recipe_id}"
  end

  def recipe_updated_event
    'recipe_updated'
  end

  # process chain channel and events

  def process_chain_channel(process_chain_id)
    "process_chain_#{process_chain_id}"
  end

  def process_chain_error_event
    'processing_error'
  end

  def process_chain_started_processing_event
    'processing_started'
  end

  def process_chain_done_processing_event
    'processing_completed'
  end

  # process step events

  def process_step_started_event
    'process_step_started'
  end

  def process_step_finished_event
    'process_step_completed'
  end

end