import Toybox.Lang;
import Toybox.Communications;
import Toybox.System;
import Toybox.WatchUi;

class Devices {
    var devices as Array<Device>;
    var callback as (Method());

    function initialize(callback as (Method())) {
        self.devices = new Device [0];
        self.callback = callback;
    }

    function count() as Number {
        return self.devices.size();
    }

    function get(index as Number) as Device {
        return self.devices[index];
    }

    function update() as Void {
        Communications.makeWebRequest(
            BASE_URL + "/devices",
            {},
            {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            },
            method(:onReceiveDevices)
        );
    }

    function onReceiveDevices(
        responseCode as Lang.Number,
        data as Lang.Dictionary?
    ) as Void {
        if (responseCode != 200 || data == null) {
            return;
        }

        var rawDevices = data as Array;
        self.devices = new Device [rawDevices.size()];
        for (var i = 0; i < rawDevices.size(); i++) {
            self.devices[i] = Device.deserialize(rawDevices[i]);
        }

        self.callback.invoke();
    }

    function setDevice(index as Number, value as Number) as Void {
        var device = self.devices[index];
        device.value = value;
        Communications.makeWebRequest(
            BASE_URL + "/device/" + Communications.encodeURL(device.address),
            {
                "value" => value,
            },
            {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
            },
            method(:onReceiveSetDevice)
        );
        self.callback.invoke();
    }

    function onReceiveSetDevice(
        responseCode as Lang.Number,
        data as Lang.Dictionary?
    ) as Void {}
}

class Device {
    var address as String;
    var name as String;
    var value as Number;

    function initialize(address as String, name as String, value as Number) {
        self.address = address;
        self.name = name;
        self.value = value;
    }

    static function deserialize(data as Dictionary) as Device {
        return new Device(data["address"], data["name"], data["value"]);
    }

    function isOn() as Boolean {
        return self.value != 0;
    }
}
