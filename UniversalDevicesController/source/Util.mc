import Toybox.Lang;
using Toybox.Graphics;
using Toybox.WatchUi;

class Set {
    var inner = {};

    function insert(value as Object) {
        self.inner.put(value, null);
    }

    function remove(value as Object) {
        self.inner.remove(value);
    }

    function contains(value as Object) {
        return self.inner.hasKey(value);
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
