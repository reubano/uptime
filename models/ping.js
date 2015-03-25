var mongoose = require('mongoose');
var Schema   = mongoose.Schema;

var Ping = new Schema({
  timestamp    : { type: Date, default: Date.now },
  isUp         : Boolean,  // false if ping returned a non-OK status code or timed out
  isResponsive : Boolean,  // true if the ping time is less than the check max time
  isSmall    : Boolean,
  time         : Number,
  check        : { type: Schema.ObjectId, ref: 'Check' },
  tags         : [String],
  monitorName  : String,
  // for pings in error, more details need to be persisted
  downtime     : Number,   // time since last ping if the ping is down
  error        : String,
  details      : Schema.Types.Mixed,
  owner: { type: Schema.ObjectId, ref: 'Account' }
});
Ping.index({ timestamp: -1 });
Ping.index({ check: 1 });
Ping.plugin(require('mongoose-lifecycle'));

Ping.methods.findCheck = function(callback) {
  return this.db.model('Check').findById(this.check, callback).populate('owner', '-pass -date -id');
};

Ping.methods.setDetails = function(details) {
  this.details = details;
  this.markModified('details');
};

Ping.statics.createForCheck = function(status, timestamp, time, check, monitorName, error, details, callback) {
  timestamp = parseInt(timestamp, 10);
  timestamp = (typeof timestamp !== 'NaN') ? new Date(timestamp) : new Date();
  var ping = new this();
  ping.timestamp = timestamp;

  if (status && check.maxTime) {
    ping.isResponsive = time < check.maxTime;
  } else {
    ping.isResponsive = false;
  }
  if (status && !ping.isResponsive) {
    status = false;
    error = "unresponsive";
  }
  ping.isUp = status;
  ping.time = time;
  ping.check = check;
  ping.tags = check.tags;
  ping.monitorName = monitorName;
  if (!status) {
    ping.downtime = check.interval || 60000;
    ping.error = error;
  }
  ping.isSmall = false;
  if (details) {
  	var _details = JSON.parse(details);
    ping.setDetails(_details);
    if(typeof _details.length != 'undefined'){

    	//Are we less than 1 byte?
    	ping.isSmall = _details.length < (check.smallSize || 1000);

    	if(ping.isSmall){
    		if(!error){
    			error = "";
    		}
    		error += (error.length ? " & " : "" ) + "Response size is too small";
    	}
    }
  }
  ping.owner = check.owner;
  ping.save(function(err1) {
    if (err1) return callback(err1);
    check.setLastTest(status, timestamp, error); // will create CheckEvent if necessary
    check.save(function(err2) {
      if (err2) return callback(err2);
      callback(null, ping);
    });
  });
};

Ping.statics.cleanup = function(maxAge, callback) {
  var oldestDateToKeep = new Date(Date.now() - (maxAge ||  3 * 31 * 24 * 60 * 60 * 1000));
  this.find({ timestamp: { $lt: new Date(oldestDateToKeep) } }).remove(callback);
};

module.exports = mongoose.model('Ping', Ping);
