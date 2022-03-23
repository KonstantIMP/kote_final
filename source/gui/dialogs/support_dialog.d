module gui.dialogs.support_dialog;

import gtk.Dialog, adw.Window, gtk.Button, gtk.ComboBoxText;
import gtk.TextView, gtk.Grid;

import db.description;

class SupportDialog : Dialog {
    private ComboBoxText cmt;
    private TextView tv;
    private Button ok;

    private Profile pr;

    public void setPr(Profile p) {pr = p;}

    public this(Window parent) {
        super(); setTransientFor(parent); setTitle("Связь с поддержкой");

        cmt = new ComboBoxText();
        cmt.append("01", "Товар сломан");
        cmt.append("02", "Не поступили баллы за инвент");
        cmt.append("03", "Жалоба на сотрудников");
        cmt.append("04", "Другой");
        cmt.setActiveId("03");

        tv = new TextView(); tv.setHexpand(true); tv.setVexpand(true);

        ok = new Button("Отправить");

        auto mb = new Grid();
        mb.attach(cmt, 0, 0, 5, 1);
        mb.attach(tv, 0, 1, 5, 5);
        mb.attach(ok, 0, 6, 5, 1);

        mb.setRowHomogeneous(true);
        mb.setColumnHomogeneous(true);
        mb.setRowSpacing(5);

        setDefaultSize(300, 300);
        setChild(mb);

        ok.addOnClicked((b) {
            import std.parallelism, glib.Timeout, gui.dialogs.async_task_dialog;

            auto tt = task!sendIt(pr, cmt.getActiveText(), tv.getBuffer().getText());
            tt.executeInNewThread();

            import adw.Window : AW = Window;
            auto ad = new AsyncTaskDialog(parent);
            ad.show();

            Timeout check;
            check = new Timeout(250, (){
                if (tt.done()) {
                    check.stop();
                    ad.close();
                    close();
                }
                return true;
            }, false);
        });
    }

    private static void sendIt(Profile p, string theme, string text) {
        import smtp;
        string sbj = "Письмо от " ~ p.login ~ " на тему " ~ theme;
        string t = "23.03.2022 Поступило письмо от пользователя ~ " ~ p.login ~ "\n";
        t ~= "Текст: " ~ text;
        sendEmail("KO.T.E@yandex.ru", sbj, t);
    }
}
