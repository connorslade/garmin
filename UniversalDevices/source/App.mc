import Toybox.Lang;
using Toybox.Application;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.WatchUi;

class App extends Application.AppBase {
    var devices = new Devices(method(:deviceUpdate));
    var favorites = new Set();
    var showAll = false;

    var menuUpdated = false;
    var menu = new WatchUi.Menu2({
        :title => "Devices",
        :footer => "Loading...",
        :dividerType => WatchUi.Menu2.DIVIDER_TYPE_ICON,
    });

    function deviceUpdate() {
        if (self.showAll) {
            self.menu.setFooter(null);
        } else {
            self.menu.setFooter("Show All");
        }

        while (self.menu.deleteItem(0)) {}
        for (var i = 0; i < self.devices.count(); i++) {
            var device = self.devices.get(i);

            if (
                self.favorites.size() > 0 &&
                !self.showAll &&
                !self.favorites.contains(device.address)
            ) {
                continue;
            }

            var value = device.value();
            var percent = Math.round((value.toFloat() / 255.0) * 10.0) * 10.0;
            var desc = value == 0 ? "Off" : "On - " + percent.toNumber() + "%";

            var icon = new WatchUi.Bitmap({
                :rezId => device.isOn()
                    ? Rez.Drawables.LightOn
                    : Rez.Drawables.LightOff,
                :locX => WatchUi.LAYOUT_HALIGN_CENTER,
                :locY => WatchUi.LAYOUT_VALIGN_CENTER,
            });
            self.menu.addItem(
                new WatchUi.IconMenuItem(device.name(), desc, i, icon, {})
            );
        }

        self.menuUpdated = true;
        WatchUi.requestUpdate();
    }

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        var favorites = Storage.getValue("favorites");
        if (favorites != null) {
            self.favorites.inner = favorites;
        }

        devices.update();
    }

    function onStop(state as Dictionary?) as Void {
        Storage.setValue("favorites", self.favorites.inner);
    }

    function getInitialView() as [WatchUi.Views] or
        [WatchUi.Views, WatchUi.InputDelegates] {
        return [self.menu, new MenuInputDelegate(self)];
    }
}

function getApp() as App {
    return Application.getApp() as App;
}

class MenuInputDelegate extends WatchUi.Menu2InputDelegate {
    var app as App;

    function initialize(app as App) {
        Menu2InputDelegate.initialize();
        self.app = app;
    }

    function onSelect(item) {
        var device = self.app.devices.get(item.getId() as Number);
        var menu = new WatchUi.ActionMenu({
            :theme => WatchUi.ACTION_MENU_THEME_DARK,
        });

        if (device.isOn()) {
            menu.addItem(new ActionMenuItem({ :label => "Turn Off" }, 0));
        } else {
            menu.addItem(new ActionMenuItem({ :label => "Turn On" }, 1));
        }

        menu.addItem(new ActionMenuItem({ :label => "Set Brightness" }, 2));

        if (!self.app.favorites.contains(device.address)) {
            menu.addItem(new ActionMenuItem({ :label => "Add Favorite" }, 3));
        } else {
            menu.addItem(
                new ActionMenuItem({ :label => "Remove Favorite" }, 4)
            );
        }

        var delegate = new ActionMenuDelegate(device, self.app);
        WatchUi.showActionMenu(menu, delegate);
    }

    function onWrap(key as WatchUi.Key) as Boolean {
        if (key == WatchUi.KEY_DOWN) {
            self.app.showAll = true;
            self.app.deviceUpdate();
            return false;
        } else if (key == WatchUi.KEY_UP) {
            self.app.showAll = false;
            self.app.deviceUpdate();
            return false;
        }

        return true;
    }
}

class ActionMenuDelegate extends WatchUi.ActionMenuDelegate {
    var device as DeviceRef;
    var app as App;

    function initialize(device as DeviceRef, app as App) {
        ActionMenuDelegate.initialize();
        self.device = device;
        self.app = app;
    }

    function onBack() as Void {}

    function onSelect(item as WatchUi.ActionMenuItem) as Void {
        switch (item.getId()) {
            case 0:
                self.device.setValue(0);
                break;
            case 1:
                self.device.setValue(255);
                break;
            case 2:
                var start = (self.device.value().toFloat() / 255.0) * 100.0;
                var picker = new WatchUi.Picker({
                    :title => centerText("Brightness", Graphics.FONT_SMALL),
                    :pattern => [
                        new PercentPickerFactory(start.toNumber(), 10),
                    ],
                });
                var pickerDelegate = new BrightnessPickerDelegate(self.device);
                WatchUi.pushView(picker, pickerDelegate, WatchUi.SLIDE_LEFT);
                break;
            case 3:
                self.app.favorites.insert(self.device.address);
                self.app.deviceUpdate();
                break;
            case 4:
                self.app.favorites.remove(self.device.address);
                self.app.deviceUpdate();
                break;
            default:
                break;
        }
        WatchUi.requestUpdate();
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
    var device as DeviceRef;

    function initialize(device as DeviceRef) {
        PickerDelegate.initialize();
        self.device = device;
    }

    function onAccept(values as Array) as Boolean {
        var brightness = (values[0].toFloat() / 100.0) * 255.0;
        self.device.setValue(brightness.toNumber());
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
