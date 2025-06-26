import Toybox.Lang;

class Misc {
    static function min(a as Number, b as Number) as Number {
        if (a < b) { return a; }
        else { return b; }
    }

    static function max(a as Number, b as Number) as Number {
        if (a > b) { return a; }
        else { return b; }
    }
}