import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

class View extends WatchUi.View {
    var api;
    var selected = 0;
    var _events;

    var y = 0;
    var current = 0;
    var toggle = false;

    function initialize(api as Api) {
        View.initialize();
        self.api = api;
        self._events = new Events(self);
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        var small_height = dc.getFontHeight(Graphics.FONT_SMALL);
        var tiny_height = dc.getFontHeight(Graphics.FONT_XTINY);

        var days = self.api.getDays() as Array<Date>;
        current = 0;
        y = dc.getHeight() / 2;

        for (var i = 0; i < days.size() && current < selected; i++) {
            y -= small_height;
            current++;

            var count = self.api.count(days[i]);
            for (var j = 0; j < count && current < selected; j++) {
                current++;
                y -= tiny_height;
            }
        }

        current = 0;
        for (var i = 0; i < days.size(); i++) {
            var day = days[i];
            var tasks = (self.api.tasks as Dictionary<Date, Array<Task>>)[day];
            if (tasks.size() == 0) { continue; }

            setColor(dc);
            dc.drawText(dc.getWidth() / 2, y, Graphics.FONT_SMALL, day.toString(), Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
            y += small_height;
            current++;

            for (var j = 0; j < tasks.size(); j++) {
                drawTask(dc, tasks[j], 0);
            }
        }

        toggle = false;
    }

    function drawTask(dc as Dc, task as Task, indent as Number) {
        var shift = 16 * indent;

        setColor(dc);
        if (toggle && current == selected) {
            task.complete = !task.complete;
        }

        dc.drawCircle(16 + shift, y, 12);
        if (task.complete) {
            dc.fillCircle(16 + shift, y, 8);
        }

        dc.drawText(32 + shift, y, Graphics.FONT_XTINY, task.content, Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_LEFT);
        y += dc.getFontHeight(Graphics.FONT_XTINY);
        current++;

        for (var i = 0; i < task.children.size(); i++) {
            drawTask(dc, task.children[i], indent + 1);
        }
    }

    function setColor(dc as Dc) {
        if (current == selected) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        }
    }
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
                self.view.selected++;
                break;
            case WatchUi.KEY_UP:
                self.view.selected--;
                break;
            case WatchUi.KEY_ENTER:
                self.view.toggle = true;
                WatchUi.requestUpdate();
                break;
        }

        self.view.selected = Misc.max(0, self.view.selected);
        WatchUi.requestUpdate();

        return false;
    }
}