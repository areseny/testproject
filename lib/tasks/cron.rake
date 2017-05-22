# this is a band aid solution to address the fact that something is preventing occasional workers from being enqueued in Sidekiq.

task :enqueue_jobs => :environment do
  puts "#{Time.now.utc.strftime("%y-%m-%d %H:%M:%S")} CRON JOB: Checking queue for unprocessed events..."

  q = Sidekiq::Queue.new
  # check if the queue is empty
  if q.count >= 1
    puts "There is a count of #{q.count} job(s) in the queue so I'll stop here and try again later"
    return
  end
  # ensure there are no running jobs
  workers = Sidekiq::Workers.new
  if workers.size >= 1
    puts "there is a count of #{workers.size} currently running threads so I'll stop here and try again later"
    return
  end

  # find all process_chains that have no executed_at
  # tell them to run
  nonstarted_chains = ProcessChain.where(executed_at: nil)
  if nonstarted_chains.count > 0
    puts "Found #{nonstarted_chains.count} chains that were not started. IDs: #{nonstarted_chains.map(&:id)}"
    nonstarted_chains.each do |chain|
      puts "Starting chain ID #{chain.id}"
      jobid = ExecutionWorker.perform_async(chain.id, "")
      puts "Ran perform_async. Job ID #{jobid}"
    end
  else
    puts "No chains to start"
  end
  puts "#{Time.now.utc.strftime("%y-%m-%d %H:%M:%S")} CRON JOB: end"
end