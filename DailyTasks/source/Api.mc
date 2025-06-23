import Toybox.Lang;
import Toybox.Communications;
import Toybox.System;

class Api {
    function initialize() {}

    function update() as Void {
        var url = "http://127.0.0.1:8080/api/private/tasks/today";
        Communications.makeWebRequest(url, {}, {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, method(:onReceive));
    }

    function onReceive(responseCode as Lang.Number, data as Lang.Dictionary | Null) as Void {
        System.println(responseCode);
        System.println(data);
        if (responseCode != 200 || data == null) {
            return;
        }

    }
}