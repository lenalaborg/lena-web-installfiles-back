if (!__lenat__) var __lenat__ = {};

var INT_MAX = 2147483647;

function objChecker(objStr) {
    var exgistCheck = true;
    var parent = window, children;
    var objStrArr = objStr.split('.');
    for (var i = 0; i < objStrArr.length; i++) {
      var el = objStrArr[i];
      if (typeof (parent[el]) != 'undefined') {
        children = parent[el];
        parent = parent[el];
      } else {
        exgistCheck = "na";
      }
    }
    return exgistCheck ? children : exgistCheck;
  };

function validObj(prop, obj) {
    return (prop in obj);
}

function validVal(a, b) {
    if (a < 0 || a > INT_MAX) {
        a = b
    }
    return a;
}
var timingProps = ['navigationStart', 'fetchStart', 'domainLookupStart', 'domainLookupEnd', 'connectStart', 'connectEnd', 'requestStart',
    'responseStart', 'responseEnd', 'loadEventEnd', 'domInteractive'];
function checkPerformanceProp() {
    if (performance == undefined) return false;
    var result = true;
    if (!validObj('timing', performance)) return false;
    for (var i = 0; i < timingProps.length; i++) {
        result = result & validObj(timingProps[i], performance.timing);
    }
    if (!result) return false;
    
    if(!validObj('timeOrigin',performance))  return false;
    if (!validObj('navigation', performance)) return false;
    if (!validObj('type', performance.navigation)) return false;
    return true;
}

var resourceProps = ['fetchStart', 'domainLookupStart', 'domainLookupEnd', 'connectStart', 'connectEnd', 'requestStart',
    'responseStart', 'responseEnd', 'initiatorType'];

function checkResourceProp() {
    var result = true;
    //var res = window.performance.getEntries()[window.performance.getEntries().length-1];
    if (window.performance == undefined) return false;
    if (!validObj('getEntriesByType', window.performance)) return false;
    var res = window.performance.getEntriesByType("resource")[window.performance.getEntriesByType("resource").length-1];
    if (res == undefined) return false;
    for (var i = 0; i < resourceProps.length; i++) {
        result = result & validObj(resourceProps[i], res);
    }
    if (!result) return false;
    return true;
}

document.addEventListener("DOMContentLoaded", function () {
    __lenat__["DOMLoaded"] = new Date().getTime();
});

window.addEventListener('load', function () {
    setTimeout(function () {
    if (checkPerformanceProp()) {
        var t = performance.timing;
        __lenat__.fire("na", {
          "d": (new Date().getTime()),
          "T1": t.navigationStart,
          "T2": t.fetchStart,
          "T3": t.domainLookupStart,
          "T4": t.domainLookupEnd,
          "T5": t.connectStart,
          "T6": t.connectEnd,
          "T7": t.requestStart,
          "T8": t.responseStart,
          "T9": t.responseEnd,
          "T10": t.loadEventEnd,
          "T11": t.domInteractive,
          "O": performance.timeOrigin,
          "t": performance.navigation.type,
          "U": "na",
          "H": "na"

      });
    }
  }, 0);
});

if (!XMLHttpRequest.prototype._open) {
	XMLHttpRequest.prototype._open = XMLHttpRequest.prototype.open;
	XMLHttpRequest.prototype._send = XMLHttpRequest.prototype.send;
}

XMLHttpRequest.prototype.open = function (method, url, async, user, password) {
    //this._url = url;
    this._url = url;
    this._method = method;
    this._async = async;
    this._open(method, url, async, user, password);
}

XMLHttpRequest.prototype.send = function (body) {
    var uuid, hash;
    this._onloadend = this.onloadend;
    this.onloadend = function () {
        var _checkHost;
        var hasHost;
        if (this._url.indexOf('://') > 0) {
            hasHost = true;
        } else {
            hasHost = false;
        }
    	
        if (this._url.indexOf('://') < 1) {
            _checkHost = location.protocol + '//' + location.host; //this._url.split('://')[0];
        } else {
            _checkHost = this._url;
        }

        if (_checkHost.indexOf(location.host) > 0 || !hasHost) {
            uuid = this.getResponseHeader("eum-key");
            hash = this.getResponseHeader("eum-hash");
        }

        if (!this.__lenat) {
            if (checkResourceProp()) {
                var p = window.performance.getEntriesByType("resource")[window.performance.getEntriesByType("resource").length-1];
                __lenat__.fire(uuid, {
                    "C": this.status,
                    "I": p.initiatorType,
                    "T2": Math.round(validVal(p.fetchStart, 0)),
                    "T3": Math.round(validVal(p.domainLookupStart, 0)),
                    "T4": Math.round(validVal(p.domainLookupEnd, 0)),
                    "T5": Math.round(validVal(p.connectStart, 0)),
                    "T6": Math.round(validVal(p.connectEnd, 0)),
                    "T7": Math.round(validVal(p.requestStart, 0)),
                    "T8": Math.round(validVal(p.responseStart, 0)),
                    "T9": Math.round(validVal(p.responseEnd, 0)),
                    "N": p.name,
                    "U": uuid,
                    "H": hash
                });
            }
        }

        if (this._onloadend) {
            this._onloadend();
        }
    }
    this._send(body);
}


window.addEventListener('error', function(event) {

    var hasError = ('error' in event);
    var hasErrorMessage = (hasError && ('message' in event.error));
    __lenat__.fire("n/a", {
        "y": event.type,
        "m": hasError ? event.error.message : null,
        "l": event.lineno,
        "n": event.filename,
        "s": hasErrorMessage ? event.error.stack : null,
        "t": event.timeStamp
    });
});

__lenat__["fire"] = function (uuid, d) {
    if (typeof (uuid) == 'undefined') return;
    var p = typeof d == 'string' ? data : Object.keys(d).map(
        function (k) { return encodeURIComponent(k) + '=' + encodeURIComponent(d[k]) }
    ).join('&');

    var r = new XMLHttpRequest();
    r.__lenat = true;
    r.open("GET", "/eum_.gif?" + p, true);
    r.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    r.send(null);
}