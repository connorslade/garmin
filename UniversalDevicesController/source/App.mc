import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class App extends Application.AppBase {
    var devices = new Devices(method(:deviceUpdate));
    var menu = new WatchUi.Menu2({
        :title => "Devices",
        :theme => WatchUi.MENU_THEME_BLUE,
    });

    function deviceUpdate() {
        var devices = self.devices.devices;
        for (var i = 0; i < devices.size(); i++) {
            var device = devices[i];
            var percent = ((device.value.toFloat() / 255.0) * 100.0).toNumber();
            var desc = device.value == 0 ? "Off" : "On - " + percent + "%";
            self.menu.addItem(
                new MenuItem(device.name, desc, i, {
                    :alignment => WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT,
                    :icon => Rez.Drawables.LauncherIcon,
                })
            );
        }

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
        self.devices.setDevice(item.getId() as Number, 0);
        WatchUi.requestUpdate();
    }
}
