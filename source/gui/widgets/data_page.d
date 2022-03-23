module gui.widgets.data_page;

import gtk.Box, adw.Window, gtk.Widget;
import gtk.Grid, gtk.Button;

class DataPage : Box
{
    protected Widget [string] children;
    protected Window parent;

    public this(Window win, Box self)
    {
        super(self.getBoxStruct(), true);
        parent = win;

        createUI(); connectSignals();
    }

    protected void createUI() 
    {
        Grid control = new Grid();
        control.setRowHomogeneous(true); control.setColumnHomogeneous(true);
        control.setRowSpacing(5); control.setColumnSpacing(5);

        children["insert_btn"] = new Button("Создать");
        children["change_btn"] = new Button("Изменить");
        children["delete_btn"] = new Button("Удалить");
        children["drop_btn"] = new Button("Удалить всё");

        control.attach(children["insert_btn"], 0, 0, 1, 1);
        control.attach(children["change_btn"], 1, 0, 1, 1);
        control.attach(children["delete_btn"], 0, 1, 1, 1);
        control.attach(children["drop_btn"], 1, 1, 1, 1);

        foreach (margin; ["top", "bottom", "start", "end"]) {
            setProperty("margin-" ~ margin, 5);
        }
        append(control); children["control"] = control;
    }

    public void updateData() {}

    protected void connectSignals() @trusted {
        (cast(Button)children["drop_btn"]).addOnClicked( (btn) {
            drop();
        });

        (cast(Button)children["delete_btn"]).addOnClicked( (btn) {
            remove();
        });

        (cast(Button)children["insert_btn"]).addOnClicked( (btn) {
            insert();
        });

        (cast(Button)children["change_btn"]).addOnClicked( (btn) {
            change();
        });
    }

    protected void drop() {}
    protected void insert() {}
    protected void remove() {}
    protected void change() {}
}
