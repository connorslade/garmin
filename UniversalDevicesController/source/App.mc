import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class App extends Application.AppBase {
    var devices = new Devices(method(:deviceUpdate));
    var favorites = new String [0];

    var menuUpdated = false;
    var menu = new WatchUi.Menu2({
        :title => "Devices",
        :dividerType => WatchUi.Menu2.DIVIDER_TYPE_ICON,
    });

    function deviceUpdate() {
        for (var i = 0; i < self.devices.count(); i++) {
            var device = self.devices.get(i);
            var percent = ((device.value.toFloat() / 255.0) * 100.0).toNumber();
            var desc = device.value == 0 ? "Off" : "On - " + percent + "%";

            if (menuUpdated) {
                self.menu.deleteItem(0);
            }

            self.menu.addItem(
                new WatchUi.MenuItem(device.name, desc, i, {
                    :icon => Rez.Drawables.LightOff,
                })
            );
        }

        self.menuUpdated = true;
        WatchUi.requestUpdate();
    }

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        devices.update();
    }

    function onStop(state as Dictionary?) as Void {}

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [self.menu, new MenuInputDelegate(self.devices)];
    }
}

function getApp() as App {
    return Application.getApp() as App;
}

class MenuInputDelegate extends WatchUi.Menu2InputDelegate {
    var devices as Devices;

    function initialize(devices as Devices) {
        self.devices = devices;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var deviceIndex = item.getId() as Number;
        var device = self.devices.get(deviceIndex);
        var menu = new WatchUi.ActionMenu({
            :theme => WatchUi.ACTION_MENU_THEME_DARK,
        });

        if (device.isOn()) {
            menu.addItem(new ActionMenuItem({ :label => "Turn Off" }, 0));
        } else {
            menu.addItem(new ActionMenuItem({ :label => "Turn On" }, 1));
        }

        menu.addItem(new ActionMenuItem({ :label => "Set Brightness" }, 2));
        menu.addItem(new ActionMenuItem({ :label => "Move to Top" }, 3));

        var delegate = new MyActionMenuDelegate(self.devices, deviceIndex);
        WatchUi.showActionMenu(menu, delegate);
    }
}

class MyActionMenuDelegate extends WatchUi.ActionMenuDelegate {
    var devices as Devices;
    var deviceIndex as Number;

    function initialize(devices as Devices, deviceIndex as Number) {
        ActionMenuDelegate.initialize();
        self.devices = devices;
        self.deviceIndex = deviceIndex;
    }

    function onBack() as Void {}

    function onSelect(item as ActionMenuItem) as Void {
        switch (item.getId()) {
            case 0:
                self.devices.setDevice(self.deviceIndex, 0);
                break;
            case 1:
                self.devices.setDevice(self.deviceIndex, 255);
                break;
            default:
                break;
        }
        WatchUi.requestUpdate();
    }
}
