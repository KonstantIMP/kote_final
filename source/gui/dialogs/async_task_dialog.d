module gui.dialogs.async_task_dialog;

import gtk.Dialog, gtk.Label, adw.Window;
import std.parallelism, d2sqlite3;

class AsyncTaskDialog : Dialog
{
    public this(Window parent)
    {
        super();
        setTransientFor(parent);
        setModal(true);
        setTitle(`Работа с БД`);
        setDeletable(false);
        setDefaultSize(300, 150);
        
        Label msg = new Label("");
        msg.setUseMarkup(true);
        msg.setMarkup(`<b>Подождите. Операция выполняется</b>`);

        foreach (p; [`top`, `bottom`, `start`, `end`])
        {
            msg.setProperty(`margin-` ~ p, 10);
        } setChild(msg);
    }
}
