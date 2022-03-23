module gui.widgets.table_widget;

import gtk.Box, gtk.Button, gtk.Widget;
import gtk.TreeView, gtk.ScrolledWindow;
import gtk.TreeViewColumn, gtk.ListStore;
import gtk.TreeIter, gtk.TreeModelIF, adw.Window;
import glib.Timeout, std.parallelism, gtk.Grid;
import std.signals, std.typecons;
import db.helper, defines;
import std.traits, db.uda;

import std.typecons;

public class TableWidget(T) : ScrolledWindow
{
    protected GType [] types = new GType[0];
    protected int [string] column_indexes;
    protected TreeViewColumn [] columns;
    private ListStore db_store;
    protected TreeView db_view;

    mixin Signal!(T, bool);

    public this()
    {
        super(); initModel(); initDBViewer();

        foreach (widget; [this, db_view]) {
            widget.setHexpand(true); widget.setHalign(GtkAlign.FILL);
            widget.setVexpand(true); widget.setValign(GtkAlign.FILL);
        } setChild(db_view);

        db_view.getSelection().setMode(GtkSelectionMode.SINGLE);
        db_view.setGridLines(GtkTreeViewGridLines.BOTH);
        db_view.setRubberBanding(true);
    }

    private void initDBViewer()
    {
        import gtk.CellRendererText, gtk.CellRendererToggle;

        columns = new TreeViewColumn[0];
        db_view = new TreeView(db_store);
        int index = 0;

        foreach (arg; __traits (allMembers, T))
        {
            static if (hasUDA!(__traits (getMember, T, arg), Entry) == false) continue;
            else
            {
                Entry entry = getUDAs!(__traits (getMember, T, arg), Entry)[0];

                TreeViewColumn column;

                if (entry.type == EntryType.Boolean) {
                    CellRendererToggle renderer = new CellRendererToggle();
                    column = new TreeViewColumn(entry.name, renderer, "active", index);
                }
                else {
                    CellRendererText renderer = new CellRendererText();

                    column = new TreeViewColumn(entry.name, renderer, "text", index);            
                    column.setResizable(true);
                    column.setMinWidth(100);

                    if (entry.sortable) {
                        column.setSortIndicator(true);
                        column.setSortColumnId(index);
                    }
                    else {
                        column.setSortIndicator(false);
                    }
                }

                column_indexes[arg] = index; db_view.appendColumn(column);
                columns ~= column; index++;
            }
        }
    }

    private void initModel()
    {
        foreach (arg; __traits (allMembers, T)) {
            static if (hasUDA!(__traits (getMember, T, arg), Entry) == false) continue;
            static if (is (typeof (__traits (getMember, T, arg)) == int)) types ~= GType.INT;
            else static if (is (typeof (__traits (getMember, T, arg)) == bool)) types ~= GType.BOOLEAN;
            else static if (is (typeof (__traits (getMember, T, arg)) == double)) types ~= GType.DOUBLE;
            else types ~= GType.STRING;
        }
        db_store = new ListStore(types);
    }

    public void insertRow(T row)
    {
        TreeIter iter; db_store.append(iter); int ct = 0;
        
        foreach (arg; __traits(allMembers, T))
        {
            static if (hasUDA!(__traits (getMember, T, arg), Entry) != false)
            {
                db_store.setValue(iter, ct, __traits(getMember, row, arg));
                ct += 1;
            }
        }
    }

    public void requestData()
    {
        import db.helper;
        foreach (row; DatabaseHelper.select!T())
        {
            insertRow(row);
        }
    }

    public Nullable!T getSelected() @trusted {
        Nullable!T result; result.nullify();

        TreeIter iter; TreeModelIF model;
        db_view.getSelection().getSelected(model, iter);

        if (db_store.iterIsValid(iter) == false) return result;
        result = getByIter(iter);
        return result;
    }

    protected Nullable!T getByIter(TreeIter iter) @trusted {
        T tmp = T();

        foreach (arg; __traits (allMembers, T)) {
            static if (hasUDA!(__traits (getMember, T, arg), Entry) != false)
            {
                import gobject.Value, std.conv : to;

                Value val;
                db_store.getValue(iter, column_indexes[arg], val);

                static if (is (typeof(__traits(getMember, tmp, arg)) == int)) 
                    __traits(getMember, tmp, arg) = val.getInt();
                else static if (is (typeof(__traits(getMember, tmp, arg)) == double)) 
                    __traits(getMember, tmp, arg) = val.getDouble();
                else static if (is (typeof(__traits(getMember, tmp, arg)) == bool)) 
                    __traits(getMember, tmp, arg) = val.getBoolean();
                else 
                    __traits(getMember, tmp, arg) = val.getString();
            }
        }

        Nullable!T result = tmp;
        return result;
    }
}
