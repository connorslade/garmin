import Toybox.Graphics;
import Toybox.WatchUi;

class View extends WatchUi.View {
    var api;
    var scroll = 0;
    var _events;

    function initialize(api as Api) {
        View.initialize();
        self.api = api;
        self._events = new Events(self);
    }

    function onLayout(dc as Dc) as Void {}

    function onShow() as Void {}

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var days = self.api.getDays();

        var y = scroll;
        for (var i = 0; i < days.size(); i++) {
            dc.drawText(dc.getWidth() / 2, y, Graphics.FONT_XTINY, days[i].toString(), Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
            y += dc.getFontHeight(Graphics.FONT_XTINY);

            var tasks = self.api.tasks[days[i]];
            for (var j = 0; j < tasks.size(); j++) {
                dc.drawText(0, y, Graphics.FONT_XTINY, tasks[j].content, Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_LEFT);
                y += dc.getFontHeight(Graphics.FONT_XTINY);
            }
        }
    }

    function onHide() as Void {}
}

class Events extends WatchUi.BehaviorDelegate {
    var view;
    
    function initialize(view) {
        BehaviorDelegate.initialize();
        self.view = view;
    }

    function onKey(event) {
        switch (event.getKey()) {
            case WatchUi.KEY_DOWN:
                self.view.scroll += 10;
                WatchUi.requestUpdate();
                return true;
            case WatchUi.KEY_UP:
                self.view.scroll -= 10;
                WatchUi.requestUpdate();
                return true;
        }

        return false;
    }
}