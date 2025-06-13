import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Communications;

class GarminGenesisApp extends Application.AppBase {
    var schedule;

    function initialize() {
        AppBase.initialize();
        self.schedule = new Schedule();
    }

    function onStart(state as Dictionary?) as Void {
        self.schedule.update();
    }

    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [ new GarminGenesisGlance(self.schedule) ];
    }
}

function getApp() as GarminGenesisApp {
    return Application.getApp() as GarminGenesisApp;
}

