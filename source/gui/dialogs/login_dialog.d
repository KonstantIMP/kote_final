module gui.dialogs.login_dialog;

import gtk.Dialog, adw.Window, gtk.Button, gtk.Label;
import gtk.Entry, gtk.Box, std.typecons;
import db.description : Profile;

class LoginDialog : Dialog {
    private Entry login, psswd;
    private Button proceed;

    Profile pr;

    public this(Window parent) {
        super(); setTransientFor(parent); setTitle("Вход в ЛК");
        login = new Entry(); psswd = new Entry(); proceed = new Button("Выполнить вход");
        createUI();

        foreach (en; [login, psswd]) en.addOnChanged((e) {check();});
        proceed.addOnClicked((b) {
            import glib.Timeout, std.parallelism, gui.dialogs.async_task_dialog;

            auto t = task!logIn(login.getText(), psswd.getText());
            t.executeInNewThread();

            import adw.Window: AW = Window;
            auto ad = new AsyncTaskDialog(cast(AW)getTransientFor());
            ad.show();

            Timeout check = null;
            check = new Timeout(250, () {
                if (t.done) {
                    auto res = t.yieldForce();
                    if (!res.isNull) {
                        pr = res.get();
                        response(11);
                    } ad.close();
                    check.stop();
                }
                return true;
            }, false);
        });
    }

    public Profile getPr() { return pr; }

    private void createUI() {
        auto b = new Box(GtkOrientation.VERTICAL, 5);
        b.setHalign(GtkAlign.FILL);

        b.setMarginBottom(5); b.setMarginEnd(5);
        b.setMarginTop(5); b.setMarginStart(5);
        b.append(login); b.append(psswd); b.append(proceed);

        login.setPlaceholderText("Введите имя пользователя");
        psswd.setPlaceholderText("Введите пароль");
        psswd.setVisibility(false);

        setChild(b); check();
    }

    private void check() {
        proceed.setSensitive(login.getText().length * psswd.getText().length > 0);
    }

    private static Nullable!Profile logIn(string l, string p) {
        import db.helper;
        Nullable!Profile result;
        auto res = DatabaseHelper.select!Profile(" login=\"" ~ l ~ "\" AND psswd=\"" ~ p ~ "\" ");
        if (res.length == 0) result.nullify();
        else result = res[0];

        return result;
    }
}
