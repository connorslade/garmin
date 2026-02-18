using Toybox.Graphics;
using Toybox.WatchUi;

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
