import Toybox.Lang;
import Toybox.Communications;
import Toybox.System;

(:glance)
class Schedule {
    var classes as Array<Class> | Null;
    var message as String | Null;
    var lastUpdate as Number = 0;

    function initialize() {}
    
    function update() as Void {
        var url = "https://widget.connorcode.com/api/schedule/bWagb5zdDR";
        Communications.makeWebRequest(url, {}, {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, method(:onReceive));
    }

    function updateIfNeeded() as Void {
        var timeout = 1000 * 60 * 15;
        if (System.getTimer() - self.lastUpdate > timeout) {
            self.update();
        }
    }

    function isLoading() as Boolean {
        return self.classes == null;
    }

    function nextClass(now as Time) as Class | Null {
        if (self.classes == null || self.classes.size() == 0) {
            return null;
        }

        for (var i = 0; i < self.classes.size(); i++) {
            var klass = self.classes[i];
            if (now.compareTo(klass.start) == -1) {
                return klass;
            }
        }

        var last = self.classes[self.classes.size() - 1];
        return new Class("End of Day", "", last.end, last.end);
    }

    function onReceive(responseCode as Lang.Number, data as Lang.Dictionary | Null) as Void {
        if (responseCode != 200 || data == null) {
            return;
        }

        var type = data["type"] as String;

        if (type.equals("message")) {
            self.message = data["data"] as String;
            self.classes = new Class[0];
        } else if (type.equals("schedule")) {
            var classesRaw = data["data"] as Array;
            var classes = new Class[classesRaw.size()];

            for (var i = 0; i < classesRaw.size(); i++) {
                var classRaw = classesRaw[i] as Dictionary;
                classes[i] = new Class(
                    classRaw["name"],
                    classRaw["teacher"],
                    Time.fromString(classRaw["start"]),
                    Time.fromString(classRaw["end"])
                );
            }

            self.classes = classes;
            self.message = null;
        }

        self.lastUpdate = System.getTimer();
    }
}

(:glance)
class Class {
    var name;
    var teacher;
    var start;
    var end;

    function initialize(name as String, teacher as String, start as Time, end as Time) {
        self.name = name;
        self.teacher = teacher;
        self.start = start;
        self.end = end;
    }
}

(:glance)
class Time {
    var hour;
    var minute;

    function initialize(hour as Number, minute as Number) {
        self.hour = hour;
        self.minute = minute;
    }

    static function fromString(time as String) as Time{
        var separator = time.find(":");
        var hour = time.substring(0, separator).toNumber();
        var minute = time.substring(separator + 1, null).toNumber();

        if (hour != 12 && time.find("PM") != null) {
            hour += 12;
        }

        return new Time(hour, minute);
    }

    static function now() as Time {
        var clock = System.getClockTime();
        return new Time(clock.hour, clock.min);
    }

    function compareTo(other as Time) as Number {
        if (self.hour < other.hour || (self.hour == other.hour && self.minute < other.minute)) {
            return -1;
        } else if (self.hour > other.hour || (self.hour == other.hour && self.minute > other.minute)) {
            return 1;
        } else {
            return 0;
        }
    }

    function subtract(other as Time) as Time {
        var minutes = self.asMinutes() - other.asMinutes();
        return new Time(minutes / 60, minutes % 60);
    }

    function asMinutes() as Number {
        return self.hour * 60 + self.minute;
    }

    function toString() as String {
        return self.hour.format("%02d") + ":" + self.minute.format("%02d");
    }
}