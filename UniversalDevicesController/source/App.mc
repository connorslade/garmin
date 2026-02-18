import Toybox.Application;
import Toybox.Graphics;
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
        while (self.menu.deleteItem(0)) {}

        for (var i = 0; i < self.devices.count(); i++) {
            var device = self.devices.get(i);
            var percent = ((device.value.toFloat() / 255.0) * 100.0).toNumber();
            var desc = device.value == 0 ? "Off" : "On - " + percent + "%";

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
        // menu.addItem(new ActionMenuItem({ :label => "Move to Top" }, 3));

        var delegate = new ActionMenuDelegate(self.devices, deviceIndex);
        WatchUi.showActionMenu(menu, delegate);
    }
}

class ActionMenuDelegate extends WatchUi.ActionMenuDelegate {
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
            case 2:
                var start =
                    (self.devices.get(self.deviceIndex).value.toFloat() /
                        255.0) *
                    100.0;
                var picker = new WatchUi.Picker({
                    :title => centerText("Brightness", Graphics.FONT_SMALL),
                    :pattern => [
                        new PercentPickerFactory(start.toNumber(), 10),
                    ],
                });
                WatchUi.pushView(
                    picker,
                    new BrightnessPickerDelegate(self),
                    WatchUi.SLIDE_LEFT
                );
                break;
            default:
                break;
        }
        WatchUi.requestUpdate();
    }
}

function centerText(text, size) as WatchUi.Text {
    return new WatchUi.Text({
        :text => text,
        :color => Graphics.COLOR_WHITE,
        :font => size,
        :locX => WatchUi.LAYOUT_HALIGN_CENTER,
        :locY => WatchUi.LAYOUT_VALIGN_CENTER,
    });
}

function min(a, b) {
    if (a < b) {
        return a;
    } else {
        return b;
    }
}

class PercentPickerFactory extends WatchUi.PickerFactory {
    var offset as Number;
    var step as Number;

    function initialize(start as Number, step as Number) {
        PickerFactory.initialize();
        self.offset = start / step;
        self.step = step;
    }

    function getDrawable(index as Number, isSelected as Boolean) {
        return centerText(
            self.getValue(index).toString() + "%",
            Graphics.FONT_MEDIUM
        );
    }

    function getSize() as Number {
        return 100 / self.step + 1;
    }

    function getValue(index as Number) {
        return min(((index + self.offset) % self.getSize()) * step, 100);
    }
}

class BrightnessPickerDelegate extends WatchUi.PickerDelegate {
    var actionMenu as ActionMenuDelegate;

    function initialize(actionMenu as ActionMenuDelegate) {
        PickerDelegate.initialize();
        self.actionMenu = actionMenu;
    }

    function onAccept(values as Array) as Boolean {
        var brightness = (values[0].toFloat() / 100.0) * 255.0;
        self.actionMenu.devices.setDevice(
            self.actionMenu.deviceIndex,
            brightness.toNumber()
        );
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onActionMenu() as Boolean {
        return true;
    }

    function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
