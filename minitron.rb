require 'sinatra'
require 'zendesk_api'
require 'json'
require 'pry'
require 'segment/analytics'

# NOTE: Ticket ID not matched to actual ticket data--sample only
#
# {
#   "user_id": "d198724e-8ed1-4895-89fd-2d117d68a783",
#   "event": "Created Support Ticket"
#   "timestamp": "2015-07-21T19:50:13Z",
#   "properties": {
#     "ticket_id": 2263,
#     "priority": "normal",
#     "subject": "Colbytron tester ticket",
#     "tags": [],
#     "satisfaction_rating_score": "unoffered",
#     "created_at": "2015-07-21T19:50:13Z",
#     "updated_at": "2015-07-21T20:26:31Z",
#     "initially_assigned_at": "2015-07-21T20:13:23Z",
#     "assigned_at": "2015-07-21T20:13:23Z",
#     "solved_at": null,
#     "reply_time_in_calendar_minutes": 36,
#     "reply_time_in_business_minutes": 36,
#     "first_resolution_time_in_calendar_minutes": null,
#     "first_resolution_time_in_business_minutes": null,
#     "full_resolution_time_in_calendar_minutes": null,
#     "full_resolution_time_in_business_minutes": null
#   }
# }

set :port, (ENV['PORT'] || 3000).to_i

# rubocop:disable LineLength
post '/' do
  payload = JSON.parse(params['payload'])
  status = payload['status']
  group = payload['group']
  if status == 'closed' && group == 'Support'
    id = payload['id']
    ticket = zendesk_client.ticket.find(id: id)
    ticket_metrics = ticket.metrics
    requester = ticket.requester
    unless requester.external_id
      fail "Failed to process ticket ##{ticket.id}: no external ID"
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

private

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
