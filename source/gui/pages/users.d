module gui.pages.users;

import db.description, gui.widgets.data_page;
import gtk.Widget, gtk.Box, gui.widgets.table_widget;
import adw.Window, gui.widgets.table_widget;
import db.description : Station;
import gtk.Grid, gtk.Button;

import gui.dialogs.row_dialog;
import gui.dialogs.async_task_dialog;

import std.parallelism, glib.Timeout;
import db.helper;

public class UsersPage : DataPage
{
    private TableWidget!User table;

    public this(Window win, Box self)
    {
        super(win, self);
    }

    override protected void createUI()
    {
        table = new TableWidget!(User)();
        append(table);

        super.createUI();
    }

    override public void updateData()
    {
        table.requestData();
    }

    override protected void insert()
    {
        bool inserted = false;

        auto insertDialog = new RowDialog!User(parent);
        insertDialog.addOnResponse((i, d) {
            if (!inserted) {
                auto t = task!insertRow(insertDialog.getRow());
                t.executeInNewThread();

                AsyncTaskDialog ad = new AsyncTaskDialog(parent);
                ad.show();

                Timeout check;
                check = new Timeout(250, () {
                    if (t.done()) {
                        table.insertRow(t.yieldForce());
                        ad.close();
                        check.stop();
                    } return true;
                }, false);

                inserted = true;
            } d.close();
        });
        insertDialog.show();
    }

    private static T insertRow(T)(T row) {
        DatabaseHelper.insert(row);
        return row;
    }
}
