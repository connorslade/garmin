import Toybox.Graphics;
import Toybox.WatchUi;

(:glance)
class GarminGenesisGlance extends WatchUi.GlanceView {
    var schedule;

    function initialize(schedule as Schedule) {
        GlanceView.initialize();
        self.schedule = schedule;
    }

    function onUpdate(dc as Dc) as Void {
        GlanceView.onUpdate(dc);

        var text = "";

        self.schedule.updateIfNeeded();
        if (self.schedule.isLoading()) {
            text = "Loading...";
            requestUpdate();
        } else if (self.schedule.message != null) {
            text = self.schedule.message;
        } else {
            var now = Time.now();
            var klass = self.schedule.nextClass(now);

            if (now.compareTo(klass.end) == 1) {
                text = "School Day Over";
            } else {
                var remaining = klass.start.subtract(now);
                text = " Next: " + klass.name + "\n " + klass.start.toString() + " ( in " + remaining.toString() + " )";
            }
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(0, dc.getHeight() / 2.0, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_LEFT);
    }
}
