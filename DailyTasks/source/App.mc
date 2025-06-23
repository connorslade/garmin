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
        self.api.update();
    }

    function onStop(state as Dictionary?) as Void { }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new View() ];
    }

}

function getApp() as App {
    return Application.getApp() as App;
}