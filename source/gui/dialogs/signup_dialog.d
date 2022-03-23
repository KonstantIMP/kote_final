module gui.dialogs.signup_dialog;

import adw.Window, gtk.Dialog, gtk.Button;
import gui.dialogs.async_task_dialog;
import gtk.Widget, gtk.Button, gtk.Grid;
import gtk.Box, gtk.Label, gtk.Entry;
import gui.widgets.phone_entry;
import gtk.Separator, gtk.Expander;
import gtk.ToggleButton;
import gtk.CheckButton;

import gtk.Revealer;
import db.description, db.helper;

class SignUpDialog : Dialog {
    private Widget [string] children;
    private string code = "12345678";
    private Profile pr;

    public this(Window parent) {
        super(); setTransientFor(parent); setModal(true);
        setTitle("Регистрация"); setDefaultSize(300, 400);
        createUI(); connectSignals();
    }

    private void createUI() {
        Box main_container = new Box(GtkOrientation.VERTICAL, 5);

        Grid control = new Grid(); control.setProperty("margin-start", 5);
        control.setRowHomogeneous(true); control.setRowSpacing(5);
        control.setColumnHomogeneous(true); control.setColumnSpacing(5);
        control.setHalign(GtkAlign.FILL); control.setProperty("margin-end", 5);
        control.setProperty("margin-top", 5);

        auto login_msg = new Label("Логин"); login_msg.setXalign(0.0); 
        control.attach(login_msg, 0, 0, 1, 1);
        auto phone_msg = new Label("Телефон"); phone_msg.setXalign(0.0); 
        control.attach(phone_msg, 0, 1, 1, 1);
        auto email_msg = new Label("Email"); email_msg.setXalign(0.0); 
        control.attach(email_msg, 0, 2, 1, 1);

        auto login_en = new Entry(); login_en.setAlignment(1.0);
        control.attach(login_en, 1, 0, 4, 1);
        auto phone_en = new PhoneNumberEntry();
        control.attach(phone_en, 1, 1, 4, 1);
        auto email_en = new Entry(); login_en.setAlignment(1.0);
        control.attach(email_en, 1, 2, 4, 1);

        children["login_en"] = login_en;
        children["phone_en"] = phone_en;
        children["email_en"] = email_en;

        main_container.append(control);

        auto sep = new Separator(GtkOrientation.HORIZONTAL);
        sep.setHalign(GtkAlign.FILL);
        main_container.append(sep);

        control = new Grid(); control.setProperty("margin-start", 5);
        control.setRowHomogeneous(true); control.setRowSpacing(5);
        control.setColumnHomogeneous(true); control.setColumnSpacing(5);
        control.setHalign(GtkAlign.FILL); control.setProperty("margin-end", 5);
        control.setProperty("margin-top", 5);

        Entry p1 = new Entry(); p1.setAlignment(.0); p1.setVisibility(false);
        p1.setInputHints(GtkInputHints.PRIVATE); p1.setInputPurpose(GtkInputPurpose.PASSWORD);
        control.attach(p1, 0, 0, 6, 1); p1.setPlaceholderText("Введите пароль");
        Entry p2 = new Entry(); p2.setAlignment(.0); p2.setVisibility(false);
        p2.setInputHints(GtkInputHints.PRIVATE); p2.setInputPurpose(GtkInputPurpose.PASSWORD);
        control.attach(p2, 0, 1, 6, 1); p2.setPlaceholderText("Повторите пароль");

        children["p1"] = p1; children["p2"] = p2;

        ToggleButton ph1 = new ToggleButton(); ph1.setIconName("weather-clear-symbolic");
        control.attach(ph1, 6, 0, 1, 1); 
        ToggleButton ph2 = new ToggleButton(); ph2.setIconName("weather-clear-symbolic");
        control.attach(ph2, 6, 1, 1, 1);

        children["ph1"] = ph1; children["ph2"] = ph2;

        main_container.append(control);

        sep = new Separator(GtkOrientation.HORIZONTAL);
        sep.setHalign(GtkAlign.FILL);
        main_container.append(sep);

        auto ch1 = new CheckButton("Даю согласие не обработку персональных данных");
        main_container.append(ch1);
        auto ch2 = new CheckButton("Ознакомлен и согласен с правилами системной аренды");
        main_container.append(ch2);
        
        children["ch1"] = ch1; children["ch2"] = ch2;

        sep = new Separator(GtkOrientation.HORIZONTAL);
        sep.setHalign(GtkAlign.FILL);
        main_container.append(sep);

        auto email_btn = new Button("Подтвердить email"); email_btn.setHalign(GtkAlign.FILL);
        main_container.append(email_btn); email_btn.setSensitive(false);

        children["email_btn"] = email_btn;

        auto em_check_rev = new Revealer();
        auto em_check_box = new Box(GtkOrientation.VERTICAL, 5);

        em_check_box.append(new Label("Введите код подтверждения или измените email"));

        auto check_code = new Entry(); check_code.setPlaceholderText("XXXX - XXXX");
        em_check_box.append(check_code); check_code.setAlignment(.5);
        check_code.setMaxLength(9);

        em_check_rev.setChild(em_check_box); em_check_rev.setRevealChild(false);
        main_container.append(em_check_rev);

        children["em_check_rev"] = em_check_rev;
        children["check_code"] = check_code;

        auto finish_rev = new Revealer();
        auto finish_box = new Box(GtkOrientation.VERTICAL, 5);

        sep = new Separator(GtkOrientation.HORIZONTAL);
        sep.setHalign(GtkAlign.FILL);
        finish_box.append(sep);

        auto sign_btn = new Button("Зарегестрироваться"); sign_btn.setHalign(GtkAlign.FILL);
        finish_box.append(sign_btn);

        finish_rev.setChild(finish_box); finish_rev.setRevealChild(false);

        main_container.append(finish_rev);

        children["finish_rev"] = finish_rev;
        children["sign_btn"] = sign_btn;

        setChild(main_container);
    }

    private void connectSignals() {
        (cast(ToggleButton)children["ph1"]).addOnToggled( (tb) {
            (cast(Entry)children["p1"]).setVisibility(tb.getActive());
            tb.setIconName(tb.getActive() ? "weather-overcast-symbolic" : "weather-clear-symbolic");
        });
        (cast(ToggleButton)children["ph2"]).addOnToggled( (tb) {
            (cast(Entry)children["p2"]).setVisibility(tb.getActive());
            tb.setIconName(tb.getActive() ? "weather-overcast-symbolic" : "weather-clear-symbolic");
        });

        foreach (id; ["login_en", "email_en", "p1", "p2"]) {
            (cast(Entry)children[id]).addOnChanged((e) {check();} );
        }

        (cast(Entry)children["check_code"]).addOnChanged((e) {
            if ((cast(Entry)children["check_code"]).getText().length < 8) {
                (cast(Revealer)children["finish_rev"]).setRevealChild(false);
                return;
            }
            import std.string : strip;
            (cast(Revealer)children["finish_rev"]).setRevealChild(
                (cast(Entry)children["check_code"]).getText().strip() == code ||
                (cast(Entry)children["check_code"]).getText().strip() == code[0..4] ~ " " ~ code[4..8] ||
                (cast(Entry)children["check_code"]).getText().strip() == code[0..4] ~ " " ~ code[4..8]
            );
        } );

        (cast(PhoneNumberEntry)children["phone_en"]).addOnPhoneChanged(() {check();});

        foreach (id; ["ch1", "ch2"]) {
            (cast(CheckButton)children[id]).addOnToggled((ch) {check();});
        }

        (cast(Button)children["email_btn"]).addOnClicked((btn) {
            (cast(Revealer)children["em_check_rev"]).setRevealChild(true);
            btn.setSensitive(false);

            import std.parallelism, glib.Timeout, gui.dialogs.async_task_dialog;

            auto t = task!sendCode((cast(Entry)children["email_en"]).getText());
            t.executeInNewThread();

            import adw.Window : AW = Window;
            auto ad = new AsyncTaskDialog(cast(AW)getTransientFor());
            ad.show();

            Timeout check = null;
            check = new Timeout(250, () {
                if (t.done()) {
                    ad.close();
                    check.stop();
                    code = t.yieldForce();
                }
                return true;
            }, false);
        });

        (cast(Button)children["sign_btn"]).addOnClicked((btn) {
            Profile p = {
                login: (cast(Entry)children["login_en"]).getText(),
                phone: (cast(PhoneNumberEntry)children["phone_en"]).getPhoneNumber(),
                email: (cast(Entry)children["email_en"]).getText(),
                psswd: (cast(Entry)children["p1"]).getText()
            };

            import std.parallelism, glib.Timeout, gui.dialogs.async_task_dialog;

            auto t = task!insertProfile(p); pr = p;
            t.executeInNewThread();

            import adw.Window : AW = Window;
            auto ad = new AsyncTaskDialog(cast(AW)getTransientFor());
            ad.show();

            Timeout check = null;
            check = new Timeout(250, () {
                if (t.done()) {
                    ad.close();
                    check.stop();
                    response(10);
                }
                return true;
            }, false);
        });
    }

    public Profile getPr() {
        return pr;
    }

    private static void insertProfile(Profile p) {
        DatabaseHelper.insert(p);
    }

    private void check() {
        bool state = true; import std.regex;

        state = state && ((cast(Entry)children["login_en"]).getText().length != 0);
        state = state && ((cast(PhoneNumberEntry)children["phone_en"]).getPhoneNumber().length != 0);
        state = state && (!matchFirst((cast(Entry)children["email_en"]).getText(), "(\\w+)(\\.|_)?(\\w*)@(\\w+)(\\.(\\w+))+").empty);

        state = state && ((cast(Entry)children["p1"]).getText().length != 0);
        state = state && ((cast(Entry)children["p1"]).getText() == (cast(Entry)children["p2"]).getText());

        state = state && ((cast(CheckButton)children["ch1"]).getActive());
        state = state && ((cast(CheckButton)children["ch2"]).getActive());

        (cast(Button)children["email_btn"]).setSensitive(state);
        (cast(Revealer)children["em_check_rev"]).setRevealChild(false);
    }

    private static string sendCode(string em) {
        import std.random, smtp: sendEmail;
        
        auto rnd = Random(unpredictableSeed);
        auto a = uniform(10000000, 100000000, rnd);

        import std.conv : to;

        string tmplt = "Вы получили это письмо, т.к. Ваш E-mail " ~ em;
        tmplt ~= "был указан при регистрации в нашем приложении.\n";
        tmplt ~= "Для подтверждения укажите этот код в приложении - " ~ to!string(a) ~ "\n";
        tmplt ~= "В случае, если Вы получили письмо по ошибке, просто проигнорируйте его. \n\n";
        tmplt ~= "Ваш КОТЭ.\n";

        sendEmail(em, "Подтверждение регистрации в приложении \"Аренда от КОТЭ\"", tmplt);
        return to!string(a);
    }
}

