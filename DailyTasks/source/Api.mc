import Toybox.Lang;
import Toybox.Communications;
import Toybox.System;

const BASE_URL as String = "https://localhost";

class Api {
    var tasks as Dictionary<Date, Array<Task>>;

    function initialize() {
        tasks = {};
    }

    function fetchMonth(year as Number, month as Number) as Void {
        var url = BASE_URL + "/api/private/tasks/" + year + "/" + month.format("%02d");
        Communications.makeWebRequest(url, {}, {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, method(:onReceive));
    }

    function onReceive(responseCode as Number, data as Dictionary | Null) as Void {
        if (responseCode != 200 || data == null) {
            return;
        }

        var days = data.keys();
        for (var i = 0; i < days.size(); i++) {
            var day = days[i] as String;
            var arr = new Task[data[day].size()];
            for (var j = 0; j < arr.size(); j++) {
                arr[j] = Task.deserialize(data[day][j]);
            }

            var date = Date.fromString(day);
            self.tasks.put(date, arr);
        }

        WatchUi.requestUpdate();
    }

    function getDays() as Array<Date> {
        var days = self.tasks.keys();
        days.sort(new DateComparator());
        return days;
    }

    function count(date as Date) as Number {
        var out = 0;
        if (!self.tasks.hasKey(date)) { return out; }

        var tasks = self.tasks[date];
        for (var i = 0; i < tasks.size(); i++) {
            out += tasks[i].count();
        }

        return out;
    }
}
