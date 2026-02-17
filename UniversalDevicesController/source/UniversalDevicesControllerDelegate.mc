import Toybox.Lang;
import Toybox.WatchUi;

class UniversalDevicesControllerDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new UniversalDevicesControllerMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}