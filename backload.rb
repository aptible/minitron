require 'zendesk_api'
require 'segment/analytics'
require 'json'
require 'pry'

# rubocop:disable LineLength
def load!
  zendesk_client.tickets.all do |ticket|
    status = ticket.status
    group = ticket.group
    next unless status == 'Closed' && group == 'Support'
    ticket_metrics = ticket.metrics
    requester = ticket.requester
    unless requester.external_id
      puts "Failed to process ticket #{ticket.id}: no external ID"
      next
    end
    summary = {
      user_id: requester.external_id,
      event: 'Created Support Ticket',
      timestamp: ticket.created_at,
      properties: {
        ticket_id: id,
        priority: ticket.priority,
        subject: ticket.subject,
        tags: ticket.tags.map(&:id),
        satisfaction_rating_score: ticket.satisfaction_rating.score,
        created_at: ticket.created_at,
        updated_at: ticket.updated_at,
        initially_assigned_at: ticket_metrics.initially_assigned_at,
        assigned_at: ticket_metrics.assigned_at,
        solved_at: ticket_metrics.solved_at,
        reply_time_in_calendar_minutes: ticket_metrics.reply_time_in_minutes.calendar,
        reply_time_in_business_minutes: ticket_metrics.reply_time_in_minutes.business,
        first_resolution_time_in_calendar_minutes: ticket_metrics.first_resolution_time_in_minutes.calendar,
        first_resolution_time_in_business_minutes: ticket_metrics.first_resolution_time_in_minutes.business,
        full_resolution_time_in_calendar_minutes: ticket_metrics.full_resolution_time_in_minutes.calendar,
        full_resolution_time_in_business_minutes: ticket_metrics.full_resolution_time_in_minutes.business
      }
    }
    puts JSON.pretty_generate(summary)
    segment_client.track(summary)
  end
end
# rubocop:enable LineLength

def zendesk_client
  fail 'ENV["ZENDESK_TOKEN"] not set!' unless ENV['ZENDESK_TOKEN']

  # https://github.com/zendesk/zendesk_api_client_rb#configuration
  @zendesk_client ||= ZendeskAPI::Client.new do |config|
    config.url = 'https://aptible.zendesk.com/api/v2'
    config.username = ENV['ZENDESK_USER']
    config.token = ENV['ZENDESK_TOKEN']
  end
end

def segment_client
  fail 'ENV["SEGMENTIO_WRITEKEY"] not set!' unless ENV['SEGMENTIO_WRITEKEY']
  @segment_client = Segment::Analytics.new(write_key: ENV['SEGMENTIO_WRITEKEY'])
end

# Call load! method
load!
