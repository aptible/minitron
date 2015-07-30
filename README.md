![Aptible, Inc.](http://aptible-media-assets-manual.s3.amazonaws.com/web-horizontal-350.png)

# Minitron

_Minitron.rb_ is a Zendesk => Segment.io webhook-based integration.

Tickets updated to a `Closed` status will trigger a post to the sinatra server which contains ID, Status, and Group. Minitron uses the ticket ID to query the Zendesk api for ticket and ticket_metric data which is forwarded on to Segment.

### Local testing

1. Set up a local enpdoint using Localtunnel.

    a) Install [localtunnel](http://localtunnel.me/) 
    
    b) Run it using port `4567`
      
        lt --port 4567

2. Set up a test target and trigger in Zendesk.

    a) The [Zendesk trigger](https://support.zendesk.com/hc/en-us/articles/203662106-Streamlining-workflow-with-ticket-updates-and-triggers#topic_usx_vxx_tb) should require the requester be you (the tester) and include any change. The trigger message should be a json block that includes the id and status. 

              {
                  "id": "{{ticket.id}}",
                  "group":"{{ticket.group.name}}",
                  "status": "{{ticket.status}}"
              }

    b) The [Zendesk target](https://support.zendesk.com/hc/en-us/articles/203662136-Notifying-external-targets) should be set to the local endpoint you set up in (1).  NB: You will need to reset this endpoint each time the tunnel session ends

3.  Make your changes to the app, then fire it up and alter your test ticket to see the response. 

4.  View any received messages in the segment debugger logs.

### Deploy on Aptible

 1. Create an app in your [Aptible dashboard](https://dashboard.aptible.com) for Minitron. 

 2. Use the [Aptible CLI](https://github.com/aptible/aptible-cli) to set necessary env variables:

   ```
   aptible config:set SEGMENTIO_WRITEKEY=<YOUR_KEY> ZENDESK_TOKEN=<YOUR_TOKEN> ZENDESK_USER=<YOUR_USER> PORT=3000 --app Minitron
   ```

 5. Clone this repository and push it to your Aptible app:

   ```
   git clone https://github.com/aptible/minitron.git
   cd minitron
   git remote add aptible git@beta.aptible.com:minitron.git
   git push aptible master
   ```
 6. Set your Zendesk target endpoint to your aptible domain (e.g. minitron.on-aptible.com)

## Copyright and License

MIT License, see [LICENSE](LICENSE.md) for details.

Copyright (c) 2015 [Aptible](https://www.aptible.com). All rights reserved.

[<img src="https://s.gravatar.com/avatar/d551a12eca2f98e71c8044c04e9aee1d&s=50" style="border-radius: 50%;" alt="@wcpines" />](https://github.com/wcpines)
