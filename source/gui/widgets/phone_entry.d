/**
 * Provides UI widget for phone number ener
 * Authors:
 *   KonstantIMP <mihedovkos@gmail.com>
 *   Loveseo8 <maggaket@gmail.com>
 * Date: 02 Dec 2021
 */
module gui.widgets.phone_entry;

import gtk.Entry, gtk.Box, gtk.Popover;
import gtk.MenuButton, gtk.Label;
import gtk.Button, gtk.SizeGroup;

import defines;

import std.parallelism, glib.Timeout;
import std.conv : to;

/** 
 * Widget for Phone number enter
 */
class PhoneNumberEntry : Box {
    private MenuButton region;
    private Popover popover;
    private Entry number;
    private SizeGroup sg;
    private Box buttons;

    /** 
     * Create's new widget
     */
    public this() @trusted {
        super(GtkOrientation.HORIZONTAL, 5);

        sg = new SizeGroup(GtkSizeGroupMode.BOTH);
        buttons = new Box(GtkOrientation.VERTICAL, 3);
        region = new MenuButton();
        popover = new Popover();
        number = new Entry();

        createUI();
    }

    /** 
     * Returns phone entry for data check
     */
    public Entry getPhoneEntry() @trusted {
        return number;
    }

    /** 
     * Sets number from formated string
     */
    public void setPhoneNumber(string s) @trusted {
        import std.ascii : isDigit; import std.array : split;
        foreach(ch; s.split("(")[1]) {
            import std.conv : to;
            if (isDigit(ch)) {
                number.setText(number.getText() ~ to!string(ch));
            }
        }
    }

    /** 
     * Return entered phone number
     */
    public string getPhoneNumber() @trusted {
        if (number.getText().length != 10) return "";
        return region.getLabel() ~ "(" ~ number.getText()[0 .. 3] ~ ")" ~ number.getText()[3 .. 6] ~ "-" ~ number.getText()[6 .. 8] ~ "-" ~ number.getText()[8 .. 10];
    }

    /** 
     * Add phone changing handler
     */
    public void addOnPhoneChanged(void delegate () dlg) @trusted {
        number.addOnChanged( (edit) {
            dlg();
        });
    }

    /** 
     * Add children
     */
    private void createUI() @trusted {
        region.setHexpand(false); region.setHalign(GtkAlign.START);
        number.setHexpand(true); number.setHalign(GtkAlign.FILL);

        region.setLabel("+7"); number.setMaxLength(10);

        region.setPopover(popover); popover.setChild(buttons);

        append(region); append(number);
    }

    /** 
     * Connect buttons
     */
    private void connectButton(Button btn) @trusted {
        buttons.append(btn); sg.addWidget(btn);
        btn.addOnClicked( (b) {
            region.setLabel(b.getLabel());
        });
    }
}
