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

    function get(index as Number) as DeviceRef {
        return new DeviceRef(self, index);
    }

    function getByAddress(address as String) as Device? {
        for (var i = 0; i < self.devices.size(); i++) {
            var device = self.devices[i];
            if (device.address == address) {
                return device;
            }
        }

        return null;
    }

    function update() as Void {
        Communications.makeWebRequest(
            BASE_URL + "/devices",
            {},
            {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :headers => { "Authorization" => AUTHENTICATION },
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

    function setDevice(device as Device, value as Number) as Void {
        device.value = value;
        Communications.makeWebRequest(
            BASE_URL + "/device/" + Communications.encodeURL(device.address),
            { "value" => value },
            {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => { "Authorization" => AUTHENTICATION },
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

class DeviceRef {
    var devices as Devices;
    var address as String;

    function initialize(devices as Devices, deviceIndex as Number) {
        self.devices = devices;
        self.address = devices.devices[deviceIndex].address;
    }

    function get() as Device? {
        return self.devices.getByAddress(self.address);
    }

    function value() as Number {
        var device = self.get();
        if (device != null) {
            return self.get().value;
        }
        return 0;
    }

    function name() as String {
        var device = self.get();
        if (device != null) {
            return device.name;
        }

        return "";
    }

    function isOn() as Boolean {
        var device = self.get();
        return device != null && device.value != 0;
    }

    function setValue(value as Number) {
        var device = self.get();
        if (device != null) {
            self.devices.setDevice(device, value);
        }
    }
}
