import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Communications;

class App extends Application.AppBase {
    var schedule;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
        self.schedule = Schedule.deserialize(Storage.getValue("schedule") as Dictionary | Null);
        self.schedule.updateIfNeeded(true);
    }

    function onStop(state as Dictionary?) as Void {
        Storage.setValue("schedule", self.schedule.serialize());
    }

    function getGlanceView() as [GlanceView] or [GlanceView, GlanceViewDelegate] or Null {
        return [ new Glance(self.schedule) ];
    }
}

function getApp() as App {
    return Application.getApp() as App;
}

