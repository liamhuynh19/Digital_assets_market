class FirstWorkerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "FirstWorkerJob is running with arguments: #{args.inspect}"
    sleep(5) # Simulate a long-running job
    puts "FirstWorkerJob completed."
  end
end
