module gui.pages.nomenclatures;

import db.description, gui.widgets.data_page;
import gtk.Widget, gtk.Box, gui.widgets.table_widget;
import adw.Window, gui.widgets.table_widget;
import db.description : Station;
import gtk.Grid, gtk.Button;
import gui.dialogs.row_dialog;
import gui.dialogs.async_task_dialog;
import std.parallelism, glib.Timeout;
import db.helper;

public class NomenclaturePage : DataPage
{
    private TableWidget!Nomenclature table;

    public this(Window win, Box self)
    {
        super(win, self);
    }

    override protected void createUI()
    {
        table = new TableWidget!(Nomenclature)();
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

        auto insertDialog = new RowDialog!Nomenclature(parent);
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

public class NomenclatureInputPage : DataPage
{
    private TableWidget!Input table;

    

    public this(Window win, Box self)
    {
        super(win, self);
    }

    override protected void createUI()
    {
        table = new TableWidget!(Input)();
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

        auto insertDialog = new RowDialog!Input(parent);
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

public class NomenclatureOutputPage : DataPage
{
    private TableWidget!Output table;

    

    public this(Window win, Box self)
    {
        super(win, self);
    }

    override protected void createUI()
    {
        table = new TableWidget!(Output)();
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

        auto insertDialog = new RowDialog!Output(parent);
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

public class NomenclatureMovesPage : DataPage
{
    private TableWidget!Moves table;

    public this(Window win, Box self)
    {
        super(win, self);
    }

    override protected void createUI()
    {
        table = new TableWidget!(Moves)();
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

        auto insertDialog = new RowDialog!Moves(parent);
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

public class NomenclaturePricesPage : DataPage
{
    private TableWidget!Price table;

    public this(Window win, Box self)
    {
        super(win, self);
    }

    override protected void createUI()
    {
        table = new TableWidget!(Price)();
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

        auto insertDialog = new RowDialog!Price(parent);
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

public class NomenclatureTypesPage : DataPage
{
    private TableWidget!NomenclatureType table;

    public this(Window win, Box self)
    {
        super(win, self);
    }

    override protected void createUI()
    {
        table = new TableWidget!(NomenclatureType)();
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

        auto insertDialog = new RowDialog!NomenclatureType(parent);
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

