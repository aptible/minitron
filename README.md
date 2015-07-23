![Aptible, Inc.](http://aptible-media-assets-manual.s3.amazonaws.com/web-horizontal-350.png)

#Minitron
_________

_Minitron.rb_ is a zendesk-to-segment webhook-based integration.

Each time a ticket status changes to `Closed`, a zendesk trigger hits the sinatra app endpoint with an ID and a status.  The app then uses that ID to query the zendesk api for ticket and ticket_metric data which is forwarded on to segment.

###Local testing

1. Set up a local enpdoint using localtunnel

    a) Install [localtunnel](http://localtunnel.me/) 
    
    b) Run it using port `4567`

2. Set up a test target and trigger in zendesk

    a) The trigger should require the requester be you (the tester) and include any change. The trigger message should be a json block that includes the id and status. 

    b) The target should be set to the local endpoint you set up in (1).  NB: You wil need to reset this endpoint each time the tunnel session ends

3.  Make your changes to the app, then fire it up and alter your test ticket to see the response. 

4.  View any received messages in the [segment debugger](https://segment.com/aptible/backend-prod/debugger)

Copyright (c) 2015 [Aptible](https://www.aptible.com). All rights reserved.

[<img src="https://s.gravatar.com/avatar/d551a12eca2f98e71c8044c04e9aee1d&s=50" style="border-radius: 50%;" alt="@wcpines" />](https://github.com/wcpines)
