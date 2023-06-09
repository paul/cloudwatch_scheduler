# frozen_string_literal: true

require "aws-sdk-sqs"
require "aws-sdk-cloudwatchevents"

module CloudwatchScheduler
  class Provisioner
    attr_reader :config

    def initialize(config, sqs_client: Aws::SQS::Client.new,
                   cwe_client: Aws::CloudWatchEvents::Client.new)
      @config = config
      @sqs_client = sqs_client
      @cwe_client = cwe_client
    end

    def provision
      create_queue!
      create_events!
    end

    def create_queue!
      attributes = { "VisibilityTimeout" => config.queue_visibility_timeout.to_s }
      @queue_url = sqs.create_queue(queue_name: queue_name, attributes: attributes).queue_url

      create_dead_letter_queue! if config.use_dead_letter_queue
    end

    def create_events!
      rule_arns = config.tasks.map do |_name, task|
        rule_arn = cwe.put_rule(
          name:                task.rule_name,
          schedule_expression: task.rule_schedule_expression,
          state:               "ENABLED",
          description:         "CloudwatchScheduler task"
        ).rule_arn

        cwe.put_targets(
          rule:    task.rule_name,
          targets: [
            {
              id:    task.rule_name,
              arn:   queue_arn,
              input: task.event_data.to_json
            }
          ]
        )

        rule_arn
      end

      policy = {
        Version:   "2012-10-17",
        Id:        "#{queue_arn}/SQSDefaultPolicy",
        Statement: rule_arns.map do |rule_arn|
          {
            Sid:       "TrustCWESendingToSQS",
            Effect:    "Allow",
            Principal: {
              AWS: "*"
            },
            Action:    "sqs:SendMessage",
            Resource:  queue_arn,
            Condition: {
              ArnEquals: {
                "aws:SourceArn": rule_arn
              }
            }
          }
        end
      }

      sqs.set_queue_attributes(
        queue_url:  queue_url,
        attributes: {
          "Policy" => policy.to_json
        }
      )
    end

    private

    def create_dead_letter_queue!
      dlq_name = "#{queue_name}-failures"
      dlq_url = sqs.create_queue(queue_name: dlq_name).queue_url
      dlq_arn = sqs.get_queue_attributes(queue_url: dlq_url, attribute_names: ["QueueArn"]).attributes["QueueArn"]

      redrive_attrs = {
        maxReceiveCount:     config.queue_max_receive_count.to_s,
        deadLetterTargetArn: dlq_arn
      }.to_json

      attributes = { "RedrivePolicy" => redrive_attrs }

      sqs.set_queue_attributes(queue_url: queue_url, attributes: attributes)
    end

    def queue_name
      config.actual_queue_name
    end

    def queue_url
      @queue_url ||= sqs.get_queue_url(queue_name: queue_name).queue_url
    end

    def queue_arn
      @queue_arn ||=
        sqs
        .get_queue_attributes(queue_url: queue_url, attribute_names: ["QueueArn"])
        .attributes["QueueArn"]
    end

    def cwe
      @cwe_client
    end

    def sqs
      @sqs_client
    end
  end
end
