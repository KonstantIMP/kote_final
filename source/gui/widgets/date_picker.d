/**
 * GUI date picker for insert dialog
 * Authors:
 *   KonstantIMP <mihedovkos@gmail.com>
 *   Loveseo8 <maggaket@gmail.com>
 * Date: 02 Dec 2021
 */
module gui.widgets.date_picker;

import gtk.MenuButton, gtk.Calendar, gtk.Popover, gtk.Button;

/** 
 * GUI date picker for insert dialog
 */
class DatePicker : MenuButton {
    private Calendar calendar;
    private Popover popover;
    private Button empty;

    /** 
     * Init's the widgte
     */
    public this() @trusted { super();
        empty = new Button("Не установлено");
        calendar = new Calendar();
        popover = new Popover();

        createUI();
        connectSignals();
    }

    /** 
     * Returns string with selected date
     */
    public string getSelectedDate() @trusted {
        import std.string : rightJustify;
        import std.conv : to;

        string result = "";

        result ~= rightJustify(to!string(calendar.getDate().getDayOfMonth), 2, '0') ~ ".";
        result ~= rightJustify(to!string(calendar.getDate().getMonth), 2, '0') ~ ".";
        result ~= to!string(calendar.getDate().getYear());

        return result;
    }

    /** 
     * Modified date getter
     */
    public string getDate() @trusted {
        return getLabel();
    }

    /** 
     * Set date from string
     */
    public void setDate(string date) @trusted {
        import std.array : split;
        import std.conv: to;

        if (date == "-") {
            setLabel(date); return;
        }

        string [] d = date.split(".");
        if (d.length != 3) return;

        import std.stdio;
        writeln(d[2] ~ "-" ~ d[1] ~ "-" ~ d[0]);

        import glib.DateTime;

        DateTime dt = new DateTime(calendar.getDate().getTimezone(), to!int(d[2]), to!int(d[1]), to!int(d[0]), 0, 0, 0);
        calendar.selectDay(dt);
    }

    /** 
     * Creates widget's ui
     */
    private void createUI() @trusted {
        import gtk.Box; Box children = new Box(GtkOrientation.VERTICAL, 5);

        calendar.setHalign(GtkAlign.FILL); calendar.setVexpand(true);
        calendar.setValign(GtkAlign.FILL); calendar.setHexpand(true);

        children.append(calendar);
        children.append(empty);

        popover.setChild(children);
        setPopover(popover);

        setLabel(getSelectedDate());
    }

    /** 
     * Connect handlers
     */
    private void connectSignals() @trusted {
        calendar.addOnDaySelected( (c) {
            setLabel(getSelectedDate());
        });
        empty.addOnClicked( (btn) {
            setLabel("-");
        });
    }
}
