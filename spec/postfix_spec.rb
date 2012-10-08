require 'spec_helper'

describe "postfix grok patterns" do

  let(:tested_pattern_file) { 'patterns/postfix' }

  describe "%{QUEUEID}" do

    it_should_behave_like "a grok pattern matcher",
                          description,
                          %w(38D2311EF05: NOQUEUE:),
                          %w(foo bar)

  end

  describe "%{ADDRESS}" do

    it_should_behave_like "a grok pattern matcher",
                          description,
                          %w(<user@example.com>),
                          %w(not_valid_address)

    it_should_behave_like "a grok field matcher",
                          description,
                          "<user@example.com>",
                          {local: 'user', remote: 'example.com'}

  end

  describe "%{RELAY}" do

    it_should_behave_like "a grok pattern matcher", description,
                          %w(none
                          alt1.aspmx.l.google.com[173.194.73.27]:25
                          mta5.am0.yahoodns.net[98.136.216.26]:25)

    it_should_behave_like "a grok field matcher", description,
                          "alt1.aspmx.l.google.com[173.194.73.27]:25",
                          {ip: '173.194.73.27', port: '25'}

  end

  describe "%{DELAYS}" do

    it_should_behave_like "a grok pattern matcher", description,
                          %w(0.3/0/0.28/0.33 144607/0.19/0.64/0.51)

    it_should_behave_like "a grok field matcher", description,
                          "144607/0.19/0.64/0.51",
                          {a: '144607', b: '0.19', c: '0.64', d: '0.51'}

  end

  describe "%{DSN}" do

    it_should_behave_like "a grok pattern matcher", description, %w(2.0.0 4.4.1)

  end

  describe "%{STATUS}" do

    it_should_behave_like "a grok pattern matcher", description, %w(sent deferred bounced expired)

  end

  describe "%{POSTFIX_CONNECT_ERROR}" do

    smtp_connect_error = "connect to axxx-xx.com[208.22.22.22]:25: Connection refused"

    it_should_behave_like "a grok pattern matcher", description, [smtp_connect_error]

    it_should_behave_like "a grok field matcher", description, smtp_connect_error,
                          {ip: '208.22.22.22', port: '25', reason: "Connection refused"}

  end

  describe "%{POSTFIX_LOST_CONNECTION}" do

    lost_connection_error = "7587E11F91A: lost connection with mxx.xxx.net[213.22.22.22] while sending DATA command"

    it_should_behave_like "a grok pattern matcher", description, [lost_connection_error]

    it_should_behave_like "a grok field matcher", description, lost_connection_error,
                          {queue_id: '7587E11F91A', ip: '213.22.22.22', hostname: 'mxx.xxx.net', while: "sending DATA command"}

  end

  describe "%{POSTFIX_HOST_REFUSED}" do

    host_refused_error = "AFBB511F85A: host smtp.nxx.fr[93.22.22.22] refused to talk to me: 554 5.7.1 <mxxx.xxxx.org[144.22.22.22]>: Client host rejected: Abus detecte GU_EIB_02"

    it_should_behave_like "a grok pattern matcher", description, [host_refused_error]

    it_should_behave_like "a grok field matcher", description, host_refused_error,
                          {
                              queue_id: 'AFBB511F85A', ip: '93.22.22.22', hostname: 'smtp.nxx.fr',
                              reason: "554 5.7.1 <mxxx.xxxx.org[144.22.22.22]>: Client host rejected: Abus detecte GU_EIB_02"
                          }

  end

  describe "a whole logline should match POSTFIXSMTPLOG" do

    # Real log lines with masked ip and email addresses, used as sample data
    loglines = [
        # delivered message
        "Oct  2 06:45:02 hostname postfix/smtp[16872]: B020F3CA00: to=<user@example.org>, relay=mail.example.org[144.22.22.22]:25, delay=0.09, delays=0.07/0/0.01/0.01, dsn=2.0.0, status=sent (250 2.0.0 Ok: queued as BF88888888)",
        "Oct  2 06:41:00 hostname postfix/smtp[16863]: 3E84A11EF6F: to=<user@example.org>, relay=mx1.example.org[195.22.22.22]:25, delay=143191, delays=143188/0.05/0.4/2.9, dsn=2.0.0, status=sent (250 ok 1349174460 qp 13230 by mx1.example.org)",
        # deferred message
        "Oct  2 06:26:18 hostname postfix/smtp[15784]: 63B9F11EF4D: to=<user@mad.example.com>, relay=none, delay=142211, delays=142190/0.03/21/0, dsn=4.4.1, status=deferred (connect to mad.example.com[80.22.22.22]:25: Connection timed out)",
        # bounced message
        "Oct  2 14:00:59 hostname postfix/smtp[16325]: 1F77D3C52C: to=<rpx-xx.xxx@domain-secondpart.de>, relay=asl.domain.de[217.22.22.22]:25, delay=83704, delays=83702/0.08/2/0.12, dsn=5.0.0, status=bounced (host asl.domain.de[217.22.22.22] said: 550 Access denied (sender blacklisted) (in reply to RCPT TO command))",
        # user with disk quota exceeded
        "Oct  2 13:15:59 hostname postfix/smtp[12922]: 78CDE3D0D4: to=<dnxxxxx@fxxxxxx.fm>, relay=in1-smtp.mxxxxx.com[66.22.22.22]:25, delay=51738, delays=51736/0.44/2.2/0.02, dsn=4.7.1, status=deferred (host in1-smtp.mxxxxxxx.com[66.22.22.22] said: 451 4.7.1 <dnxxxxxx@fxxxxx.fm>: Recipient address rejected: User is over quota, try again later (in reply to RCPT TO command))"
    ]

    it_should_behave_like "a grok pattern matcher", "%{POSTFIXSMTPLOG}", loglines

    it_should_behave_like "a grok field matcher", "%{POSTFIXSMTPLOG}",
                          loglines.last,
                          {
                              to: '<dnxxxxx@fxxxxxx.fm>', relay: 'in1-smtp.mxxxxx.com[66.22.22.22]:25',
                              ip: '66.22.22.22', port: '25',
                              delay: '51738', status: 'deferred',
                              reason: 'host in1-smtp.mxxxxxxx.com[66.22.22.22] said: 451 4.7.1 <dnxxxxxx@fxxxxx.fm>: Recipient address rejected: User is over quota, try again later (in reply to RCPT TO command)'
                          }

  end

  describe "Postfix smtp edge cases logs extracted from real logfiles" do

    with_custom_relay = with_original_to = "E8C9B11EFEC: to=<dyyyy@example.org>, orig_to=<dxxxx@example.org>, relay=custom, delay=1, delays=0.01/0/0/1, dsn=2.0.0, status=sent (delivered via custom service)"
    with_conn_use = "2111411F0D1: to=<jxxxx@cxxxxx.net>, relay=mx2.cxxxx.net[76.22.22.22]:25, conn_use=2, delay=5706, delays=5671/30/0.12/5.2, dsn=2.0.0, status=sent (250 2.0.0 64cP1k0015SCSiQ064cU6t mail accepted for delivery)"
    dunno_why = "81F2411EE44: to=<wxxxxxx@sxxxxxx.org.br>, relay=cor.sxxxx.org.br[189.22.22.22]:25, delay=14, delays=7.1/0.1/1.4/5.5, dsn=2.6.0, status=sent (250 2.6.0 <dxxx@anonymous> [InternalId=244401] Queued mail for delivery)"

    it_should_behave_like "a grok pattern matcher", "%{POSTFIX_SMTP_LOG}", [
        with_original_to, with_custom_relay, with_conn_use, dunno_why
    ]

    it_should_behave_like "a grok field matcher", "%{POSTFIX_SMTP_LOG}", with_original_to, {original_to: '<dxxxx@example.org>'}

    it_should_behave_like "a grok field matcher", "%{POSTFIX_SMTP_LOG}", with_custom_relay, {relay: 'custom'}

  end

end
