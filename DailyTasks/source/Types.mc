import Toybox.Lang;

class Task {
    var content as String;
    var complete as Boolean;
    var children as Array<Task>;

    function initialize(content as String, complete as Boolean, children as Array<Task>) {
        self.content = content;
        self.complete = complete;
        self.children = children;
    }

    function serialize() as Dictionary {
        var children = new Dictionary[self.children.size()];
        for (var i = 0; i < children.size(); i++) {
            children[i] = self.children[i].serialize();
        }

        return {
            "content" => self.content,
            "complete" => self.complete,
            "children" => children
        };
    }

    static function deserialize(data as Dictionary | Null) as Task {
        var count = data["children"].size();
        var children = new Task[count];

        for (var i = 0; i < count; i++) {
            children[i] = Task.deserialize(data["children"][i]);
        }

        return new Task(data["content"], data["complete"], children);
    }
}

const MONTHS as Dictionary<Number, String> = {
    1 => "January",
    2 => "February",
    3 => "March",
    4 => "April",
    5 => "May",
    6 => "June",
    7 => "July",
    8 => "August",
    9 => "September",
    10 => "October",
    11 => "November",
    12 => "December"
};

class Date {
    var year as Number;
    var month as Number;
    var day as Number;

    static function zero() as Date {
        return new Date(0, 1, 1);
    }

    function initialize(year as Number, month as Number, day as Number) {
        self.year = year;
        self.month = month;
        self.day = day;
    }

    function compareTo(other as Date) as Number {
        if (self.year != other.year) { return self.year - other.year; }
        if (self.month != other.month) { return self.month - other.month; }
        return self.day - other.day;
    }

    function toString() as String {
        return MONTHS[self.month] + " " + self.day + ", " + self.year;
    }

    // Parses a date from year month day format (YY-mm-dd)
    static function fromString(str as String) as Date {
        var ymSeparator = str.find("-");
        var mdSeparator = ymSeparator + 1 + str.substring(ymSeparator + 1, null).find("-");

        var year = str.substring(0, ymSeparator).toNumber();
        var month = str.substring(ymSeparator + 1, mdSeparator).toNumber();
        var day = str.substring(mdSeparator + 1, null).toNumber();

        return new Date(year, month, day);
    }
}