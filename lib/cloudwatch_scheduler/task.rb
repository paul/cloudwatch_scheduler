require 'active_support/core_ext/digest/uuid'

module CloudwatchScheduler
  class Task
    attr_reader :name, :code

    def initialize(name, every: nil, cron: nil, &code)
      @name = name
      @every, @cron = every, cron
      fail "You must specify one of every: or cron:" unless [@every, @cron].any?
      @code = code
    end

    def invoke
      code.call
    end

    def job_id
      Digest::UUID.uuid_v5(Digest::UUID::DNS_NAMESPACE, name)
    end

    # {"job_class":"PollActionJob","job_id":"d319ca2e-235f-492b-ab9d-a76d35490ae9",
    #  "queue_name":"scalar-production-poller","priority":null,"arguments":[433],
    #  "locale":"en"}
    def event_data
      {
        job_class: CloudwatchScheduler::Job.name,
        job_id: job_id,
        queue_name: CloudwatchScheduler::Job.queue_name,
        arguments: [name],
        locale: "en",
        priority: nil
      }
    end

    def rule_name
      limit = 64 - CloudwatchScheduler::Job.queue_name.length
      [name[0, limit-1], CloudwatchScheduler::Job.queue_name].join("-")
    end

    def rule_schedule_expression
      if @every
        rate_exp
      else
        cron_exp
      end
    end

    def rate_exp
      units = if @every % 1.day == 0
                "day"
              elsif @every % 1.hour == 0
                "hour"
              elsif @every % 1.minute == 0
                "minute"
              else
                fail "Intervals less than 1 minute are not allowed by Cloudwatch Events."
              end

      qty = @every.to_i / 1.send(units)

      "rate(#{qty.to_i} #{units.pluralize(qty)})"
    end

    def cron_exp
      "cron(#{@cron})"
    end

  end
end
