/**
 * Insert and change dialog
 */
module gui.row_dialog;

import gtk.Dialog, gtk.Button, gtk.Widget;
import gtk.Entry, gtk.ComboBoxText, gtk.SizeGroup;
import gtk.Label, gtk.Box, adw.Window;
import gtk.SpinButton, gtk.Switch;

import gui.widgets.date_picker, gui.widgets.time_picker;
import gui.widgets.phone_entry;

import db.helper, defines;
import db.uda: SQLite3TableEntry = Entry, SQLite3TableEntryType = EntryType;

import std.array, std.string, std.traits;
import glib.Timeout, std.parallelism;

import std.array : split;

/** 
 * Describes entry node (all types)
 */
private struct Node {
    Widget input;
    Label name;
}

/** 
 * Provides check 
 */
private struct CheckableEntry {
    private Entry checkable;
    string regex = "";

    public bool check() @trusted {
        import std.regex;
        if (regex == "") return checkable.getText().length > 0;
        return !matchFirst(checkable.getText(), regex).empty;
    }
}

/** 
 * Insert and change dialog
 */
class RowDialog(T) : Dialog {
    private Widget [string] children;
    private Node [string] nodes;

    private Timeout [string] checkers;
    private CheckableEntry [] valid = new CheckableEntry[0];

    /** 
     * Supported Dialog's responses
     */
    public static enum Responses {
        OK_Response, CANCEL_Response
    }

    /** 
     * Init's the dialog
     */
    public this(Window parent) @trusted { super();
        setTransientFor(parent); setModal(true);

        createUI(); fillNodes();
    }

    /** 
     * Fills the dialog for change
     */
    public this(Window parent, T row) @trusted {
        this(parent); setTitle("Changing");

        foreach (arg; __traits(allMembers, T)) {
            static if (hasUDA!(__traits (getMember, T, arg), SQLite3TableEntry) != false)
            {
                SQLite3TableEntry entry = getUDAs!(__traits (getMember, T, arg), SQLite3TableEntry)[0];
                if (entry.autoincrement) continue;
            
                static if (is (typeof(__traits (getMember, T, arg)) == bool)) 
                    (cast(Switch)nodes[arg].input).setActive(__traits (getMember, row, arg));
                else static if (is (typeof(__traits (getMember, T, arg)) == int))
                    (cast(SpinButton)nodes[arg].input).setValue(cast(double)(__traits (getMember, row, arg)));
                else static if (is (typeof(__traits (getMember, T, arg)) == double))
                    (cast(SpinButton)nodes[arg].input).setValue(__traits (getMember, row, arg));
                else static if (is (typeof(__traits (getMember, T, arg)) == string)) {
                    switch (entry.type) {
                        case SQLite3TableEntryType.Phone:
                            (cast(PhoneNumberEntry)nodes[arg].input).setPhoneNumber(__traits (getMember, row, arg));
                            break;
                        case SQLite3TableEntryType.Date:
                            (cast(DatePicker)nodes[arg].input).setDate(__traits (getMember, row, arg)); break;
                        case SQLite3TableEntryType.Time:
                            (cast(TimePicker)nodes[arg].input).setTime(__traits (getMember, row, arg)); break;
                        default:
                            if (entry.type == SQLite3TableEntryType.Link || entry.type == SQLite3TableEntryType.Enumeration) {
                                import gtk.TreeModelIF, gtk.TreeIter;

                                TreeModelIF model = (cast(ComboBoxText)nodes[arg].input).getModel();
                                TreeIter iter; model.getIterFirst(iter);

                                do {
                                    import gobject.Value; Value val;
                                    model.getValue(iter, 0, val);

                                    if (val.getString() == __traits (getMember, row, arg)) {
                                        (cast(ComboBoxText)nodes[arg].input).setActiveIter(iter);
                                        break;
                                    }
                                } while (model.iterNext(iter));

                                break;
                            }
                            else (cast(Entry)nodes[arg].input).setText(__traits (getMember, row, arg));
                    }
                }
            }
        }
    }

    /** 
     * Returns entered row data
     */
    public T getRow() @trusted {
        T result; 

        foreach (arg; __traits(allMembers, T)) {
            static if (hasUDA!(__traits (getMember, T, arg), SQLite3TableEntry) != false)
            {
                SQLite3TableEntry entry = getUDAs!(__traits (getMember, T, arg), SQLite3TableEntry)[0];
                if (entry.autoincrement) continue;

                static if (is (typeof(__traits (getMember, T, arg)) == bool)) 
                    __traits (getMember, result, arg) = (cast(Switch)nodes[arg].input).getActive();
                else static if (is (typeof(__traits (getMember, T, arg)) == int))
                    __traits (getMember, result, arg) = cast(int)(cast(SpinButton)nodes[arg].input).getValue();
                else static if (is (typeof(__traits (getMember, T, arg)) == double))
                    __traits (getMember, result, arg) = (cast(SpinButton)nodes[arg].input).getValue();
                else static if (is (typeof(__traits (getMember, T, arg)) == string)) {
                    switch (entry.type) {
                        case SQLite3TableEntryType.Phone:
                            __traits (getMember, result, arg) = (cast(PhoneNumberEntry)nodes[arg].input).getPhoneNumber();
                            break;
                        case SQLite3TableEntryType.Date:
                            __traits (getMember, result, arg) = (cast(DatePicker)nodes[arg].input).getDate(); break;
                        case SQLite3TableEntryType.Time:
                            __traits (getMember, result, arg) = (cast(TimePicker)nodes[arg].input).getTime(); break;
                        case SQLite3TableEntryType.Enumeration:
                            __traits (getMember, result, arg) = (cast(ComboBoxText)nodes[arg].input).getActiveText(); break;
                        case SQLite3TableEntryType.Link:
                            __traits (getMember, result, arg) = (cast(ComboBoxText)nodes[arg].input).getActiveText(); break;
                        default:
                            __traits (getMember, result, arg) = (cast(Entry)nodes[arg].input).getText();
                    }
                }
            }
        }

        return result;
    }

    /** 
     * Generates QR data in JSON
     */
    private string genQR() @trusted {
        import std.json; JSONValue record = parseJSON("{}");

        foreach (arg; __traits(allMembers, T)) {
            static if (hasUDA!(__traits (getMember, T, arg), SQLite3TableEntry) != false)
            {
                SQLite3TableEntry entry = getUDAs!(__traits (getMember, T, arg), SQLite3TableEntry)[0];
                if (entry.autoincrement) continue;

                static if (is (typeof(__traits (getMember, T, arg)) == bool)) 
                    record[arg] = (cast(Switch)nodes[arg].input).getActive();
                else static if (is (typeof(__traits (getMember, T, arg)) == int))
                    record[arg] = cast(int)(cast(SpinButton)nodes[arg].input).getValue();
                else static if (is (typeof(__traits (getMember, T, arg)) == double))
                    record[arg] = (cast(SpinButton)nodes[arg].input).getValue();
                else static if (is (typeof(__traits (getMember, T, arg)) == string)) {
                    switch (entry.type) {
                        case SQLite3TableEntryType.Phone:
                            record[arg] = (cast(PhoneNumberEntry)nodes[arg].input).getPhoneNumber(); break;
                        case SQLite3TableEntryType.Date:
                            record[arg] = (cast(DatePicker)nodes[arg].input).getDate(); break;
                        case SQLite3TableEntryType.Time:
                            record[arg] = (cast(TimePicker)nodes[arg].input).getTime(); break;
                        case SQLite3TableEntryType.Enumeration:
                            record[arg] = (cast(ComboBoxText)nodes[arg].input).getActiveText(); break;
                        case SQLite3TableEntryType.Link:
                            record[arg] = (cast(ComboBoxText)nodes[arg].input).getActiveText(); break;
                        default:
                            record[arg] = (cast(Entry)nodes[arg].input).getText();
                    }
                }
            }
        }

        return record.toString();
    }

    /** 
     * Creates dialog's ui
     */
    private void createUI() @trusted {
        SizeGroup btns = new SizeGroup(GtkSizeGroupMode.BOTH);

        children["cancel_btn"] = addButton("Cancel", Responses.CANCEL_Response);
        children["ok_btn"] = addButton("OK", Responses.OK_Response);

        foreach (b; [children["ok_btn"], children["cancel_btn"]]) btns.addWidget(b);

        foreach(margin; ["top", "bottom", "end", "start"]) {
            getContentArea().setProperty("margin-" ~ margin, 5);
        }

        getContentArea().setValign(GtkAlign.FILL); getContentArea().setVexpand(true);
        getContentArea().setHalign(GtkAlign.FILL); getContentArea().setHexpand(true);

        getContentArea().setOrientation(GtkOrientation.VERTICAL);
        getContentArea().setSpacing(5);

        setTitle("Insertion");
    }

    /** 
     * Fills content area
     */
    private void fillNodes() @trusted {
        SizeGroup lg = new SizeGroup(GtkSizeGroupMode.BOTH);
        SizeGroup rg = new SizeGroup(GtkSizeGroupMode.BOTH);

        foreach (arg; __traits(allMembers, T)) {
            static if (hasUDA!(__traits (getMember, T, arg), SQLite3TableEntry) != false)
            {
                SQLite3TableEntry entry = getUDAs!(__traits (getMember, T, arg), SQLite3TableEntry)[0];
                if (entry.autoincrement) continue;

                Node tmp = createNode(entry, arg);

                tmp.input.setHexpand(true); tmp.input.setHalign(GtkAlign.FILL);
                tmp.input.setVexpand(true); tmp.input.setValign(GtkAlign.FILL);

                Box nodeBox = new Box(GtkOrientation.HORIZONTAL, 5);
                nodeBox.append(tmp.name); nodeBox.append(tmp.input);

                lg.addWidget(tmp.name); rg.addWidget(tmp.input);
                tmp.name.setXalign(0.0); nodes[arg] = tmp;

                getContentArea().append(nodeBox);
            }
        }
    }

    /** 
     * Creates entry node
     */
    private Node createNode(SQLite3TableEntry entry, string arg) @trusted {
        Node result; result.name = new Label(entry.name);
        import std.stdio; writeln(arg);
        switch(entry.type) {
            case SQLite3TableEntryType.Integer:
                result.input = new SpinButton(-65000, 65000, 1.0);
                result.input.setProperty("value", 0.0);
                break;
            case SQLite3TableEntryType.Floating:
                if (arg == "latitude") result.input = new SpinButton(-90, 90, 1e-6);
                else if (arg == "longitude") result.input = new SpinButton(-180, 180, 1e-6);
                else result.input = new SpinButton(-65000, 65000, 1e-6);
                result.input.setProperty("value", 0.0);
                break;
            case SQLite3TableEntryType.Date:
                result.input = new DatePicker();
                break;
            case SQLite3TableEntryType.Time:
                result.input = new TimePicker();
                break;
            case SQLite3TableEntryType.Phone:
                result.input = new PhoneNumberEntry();

                CheckableEntry ch;
                ch.checkable = (cast(PhoneNumberEntry)result.input).getPhoneEntry();
                ch.regex = "^\\d{10,10}\\b$";
                valid ~= ch;

                break;
            case SQLite3TableEntryType.Boolean:
                result.input = new Switch();
                break;
            case SQLite3TableEntryType.Link:
                result.input = new ComboBoxText();
                result.input.setSensitive(false);

                auto task = task!loadLink(arg, entry, this);
                task.executeInNewThread();

                checkers[arg] = null;
                checkers[arg] = new Timeout(250, () { 
                    if (task.done) {
                        string tmp_a = task.yieldForce();
                        checkers[tmp_a].stop();
                        nodes[tmp_a].input.setSensitive(true);
                    }
                    return true;
                }, false);

                break;
            case SQLite3TableEntryType.Enumeration:
                result.input = new ComboBoxText();
                foreach (en; entry.enum_values) {
                    (cast(ComboBoxText)result.input).appendText(en);
                } (cast(ComboBoxText)result.input).setActive(0);
                break;
            default:
                result.input = new Entry();

                if (entry.max_length) result.input.setProperty("max-length", entry.max_length);

                if (entry.required || entry.regexp != "") {
                    CheckableEntry ch;
                    ch.checkable = cast(Entry)result.input;
                    ch.regex = entry.regexp;
                    valid ~= ch;
                }

                (cast(Entry)result.input).addOnChanged( (edit) {
                    checkAll();
                });
        } checkAll();

        return result;
    }

    /** 
     * Set ok sensitive extends entries
     */
    private void checkAll() @trusted {
        bool state = true;

        foreach (ch; valid) {
            state = state && ch.check();
        }

        children["ok_btn"].setSensitive(state);
    }

    /** 
     * Loads foreign data
     */
    protected static string loadLink(string arg, SQLite3TableEntry entry, RowDialog d) @trusted {
        string table = entry.link_address.split(":")[0];
        string value = entry.link_address.split(":")[1];
        /*auto data = DatabaseHelper.select(table, value);

        foreach(key; data) {
            (cast(ComboBoxText)d.nodes[arg].input).appendText(key[value]);
        }

        (cast(ComboBoxText)d.nodes[arg].input).setActive(0);*/

        return arg;
    }
}
