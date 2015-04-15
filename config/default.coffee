seconds = 1000
minutes = seconds * 60
hours = minutes * 60
days = hours * 24
months = days * 30

module.exports =
  url: process.env.BASE_URL

  mongodb:
    server: process.env.MONGO_ENDPOINT  # localhost
    database: process.env.MONGO_DATABASE  # uptime
    user: process.env.MONGO_USER
    password: process.env.MONGO_PWD
    # alternative to setting server, database, user and password separately
    connectionString: process.env.MONGODB_URL

  monitor:
    name: origin
    apiUrl: 'http://localhost:8082/api'  # must be accessible without a proxy
    pollingInterval: seconds * 10
    timeout: seconds * 5
    userAgent: 'NodeUptime/3.0 (https://github.com/springerpe/uptime)'

  analyzer:
    updateInterval: minutes * 1
    qosAggregationInterval: minutes * 10
    pingHistory: months * 3

  autoStartMonitor: true

  plugins: [
    './plugins/console'
    './plugins/patternMatcher'
    './plugins/httpOptions'
    './plugins/httpsOAuthOptions'
    # './plugins/pagerduty'
    # './plugins/email'
    # './plugins/basicAuth'
    './plugins/hipchat'
    './plugins/victorops'
    # './plugins/statushub'
    './plugins/statuspage'
    './plugins/httpriemann'
  ]

  email:
    method: 'SMTP'
    # see https://github.com/andris9/nodemailer for transport options
    transport:
      # see https://github.com/andris9/Nodemailer/blob/master/lib/wellknown.js
      # for well-known services
      service: process.env.EMAIL_SERVICE or 'Gmail'
      auth:
        user: process.env.EMAIL_USER
        pass: process.env.EMAIL_PASSWORD
    event:
      up: true
      down: true
      paused: true
      restarted: true
    message:
      from: process.env.EMAIL_FROM
      to: process.env.EMAIL_RECIPIENTS
    # The email plugin also uses the main `url` param for hyperlinks in the
    # sent emails

  basicAuth:
    username: process.env.BASIC_AUTH_USER
    password: process.env.BASIC_AUTH_PASSWORD

  verbose: process.env.DEBUG || false

  # ssl:
  #   enabled: true
  #   certificate: process.env.SSL_CRT  # certificate file
  #   key: process.env.SSL_KEY  # key file
  #   selfSigned: false

  hipchat:
    # HipChat Admin API Key https://www.hipchat.com/admin/api
    apiKey: process.env.HIPCHAT_KEY
    # tag name : HipChat room ID where send notification
    tag: hipchat: process.env.HIPCHAT_ROOM

  victorops: endpoint: process.env.VICTOROPS_ENDPOINT

  # statushub:
  #  endpoint: https://statushub.io/api/status_pages  # the same for all
  #  # ['my_stuff'] as you can have a number of different status pages
  #  subdomains: process.env.STATUSHUB_SUBDOMAINS
  #  apiKey: process.env.STATUSHUB_KEY

  pushbullet:
    apikey: process.env.PAGERDUTY_KEY

  pagerduty:
    serviceKey: process.env.PAGERDUTY_KEY
    event:
      up: true
      down: true
      paused: false
      restarted: false

  httpriemann:
    endpoint: process.env.RIEMANN_URL
    username: process.env.RIEMANN_USERNAME
    password: process.env.RIEMANN_PASSWORD

  webPageTest:
    server: 'http://www.webpagetest.org'
    key:
    testOptions: