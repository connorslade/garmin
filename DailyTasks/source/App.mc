import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class App extends Application.AppBase {
    var api as Api;

    function initialize() {
        AppBase.initialize();
        self.api = new Api();
    }

    function onStart(state as Dictionary?) as Void {
        self.api.fetchMonth(2025, 6);
    }

    function onStop(state as Dictionary?) as Void { }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new View(self.api);
        return [ view, new Events(view) ];
    }

}

function getApp() as App {
    return Application.getApp() as App;
}