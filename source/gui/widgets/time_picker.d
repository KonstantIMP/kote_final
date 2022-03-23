/**
 * Widget for safe time pick
 * Authors:
 *   KonstantIMP <mihedovkos@gmail.com>
 *   Loveseo8 <maggaket@gmail.com>
 * Date: 02 Dec 2021
 */
module gui.widgets.time_picker;

import gtk.MenuButton, gtk.Popover;
import gtk.SpinButton;

/** 
 * Widget for safe time pick
 */
class TimePicker : MenuButton {
    private SpinButton h_sb, m_sb;
    private Popover popover;

    /** 
     * Init's the widget
     */
    public this() @trusted {
        import gtk.Adjustment;
        h_sb = new SpinButton(new Adjustment(0, -1, 24, 1, 0, 0), 1, 0);
        m_sb = new SpinButton(new Adjustment(0, -1, 61, 1, 0, 0), 5, 0);

        popover = new Popover();

        createUI();
        setCurrentTime();
        connectSignal(h_sb);
        connectSignal(m_sb);
    }

    /** 
     * Returns selected time
     */
    public string getTime() @trusted {
        return getLabel();
    }

    /** 
     * Sets time from string
     */
    public void setTime(string t) @trusted {
        import std.conv, std.string, std.array : split;
        
        h_sb.setValue(to!double(t.split(":")[0].strip()));
        m_sb.setValue(to!double(t.split(":")[1].strip()));
    }

    /** 
     * Creates widget ui
     */
    private void createUI() @trusted {
        import gtk.Box, gtk.Label;

        foreach (sb; [h_sb, m_sb]) sb.setOrientation(GtkOrientation.VERTICAL);

        Box hm_box = new Box(GtkOrientation.HORIZONTAL, 5);
        hm_box.append(h_sb); hm_box.append(new Label(":")); hm_box.append(m_sb);
        
        popover.setChild(hm_box); setPopover(popover);
    }

    /** 
     * Set current time
     */
    private void setCurrentTime() @trusted {
        import glib.DateTime;
        DateTime tmp = new DateTime();
        h_sb.setValue(cast(double)tmp.getHour());
        m_sb.setValue(cast(double)tmp.getMinute());

        updateTime();
    }

    /** 
     * Update visible time
     */
    private void updateTime() @trusted {
        import std.conv : to;
        import std.string : rightJustify;
        setLabel(rightJustify(to!string(cast(int)h_sb.getValue()), 2, '0') ~ " : " ~ rightJustify(to!string(cast(int)m_sb.getValue()), 2, '0'));
    }

    /** 
     * Improve buttons overflow
     */
    private void connectSignal(SpinButton btn) @trusted {
        btn.addOnChanged( (edit) {
            if (-1 == cast(int)btn.getValue()) {
                btn.setValue(btn.getAdjustment().getUpper() - 1);
            }
            else if (btn.getAdjustment().getUpper() == btn.getValue()) {
                btn.setValue(btn.getAdjustment().getLower() + 1);
            }
            updateTime();
        });
    }
}

