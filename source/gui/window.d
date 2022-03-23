module gui.window;

import adw.Window, adw.Application;
import gtk.Builder, gtk.Widget, gtk.Button, gtk.Stack;
import gtk.Box, gui.widgets.color_scheme_button;
import gui.dialogs.async_task_dialog;
import adw.Leaflet : Leaflet;

import gobject.ParamSpec, gobject.ObjectG;

import std.parallelism, glib.Timeout;
import gui.pages.nomenclatures;
import gui.pages.users, gui.pages.payments;

import db.description : Profile;

class KoteWindow : Window
{
    private Widget [string] pages;
    private Widget [string] children;
    private bool done = false;
    private Profile global;

    public this(ref Builder ui, Application app_instance) @trusted
    { 
        import adw.c.types : AdwWindow;
        super(cast(AdwWindow *)(cast(Window)ui.getObject("manager_window")).getWindowStruct(), true);
        connectObjects(ui); connectSignals();

        executeInitTask();
    }

    private void executeInitTask() {
        auto t = task!initTask();
        t.executeInNewThread();
    
        AsyncTaskDialog d = new AsyncTaskDialog(this);
        d.addOnResponse((i, d) {d.close();});
        d.show();

        Timeout check = null;
        check = new Timeout(250, ()
            {
                if (t.done) {
                    d.response(0);
                    check.stop();
                    connectPages();
                    login();
                }
                return true;
            }, false
        );
    }

    private void login() {
        import gtk.Dialog; Dialog ud = new Dialog();
        ud.setTransientFor(this); ud.setTitle("Начало работы");
        ud.addButton("Вход в ЛК", 10); ud.addButton("Регистрация", 11);

        bool checked = false;
        ud.addOnResponse((i, d) {
            if (!checked) {
                if (i == 10) {
                    bool ch1 = false;
                    import gui.dialogs.login_dialog;
                    auto li = new LoginDialog(this);
                    li.addOnResponse((i, d) {
                        if (!ch1) {
                            loadData(li.getPr());
                            ch1 = true;
                        }
                        li.close();
                    });
                    li.show();
                    checked = true;
                }
                else if (i == 11) {
                    bool ch2 = false;
                    import gui.dialogs.signup_dialog;
                    auto su = new SignUpDialog(this);
                    su.addOnResponse((i, d) {
                        if (!ch2) {
                            loadData(su.getPr());
                            ch2 = true;
                        }
                        su.close();
                    });
                    su.show();
                    checked = true;
                }
            } d.close();
        }); ud.show();
    }

    private void loadData(Profile p) {
        import std.conv : to;

        children["balance_umsg"].setProperty("label", to!string(p.balance));
        children["email_umsg"].setProperty("label", p.email);
        children["phone_umsg"].setProperty("label", p.phone);
        children["login_umsg"].setProperty("label", p.login);

        children["fio_l"].setProperty("label", "ФИО: " ~ p.lastname ~ " " ~ p.name ~ " " ~ p.surname);
        children["sex_l"].setProperty("label", "Пол: " ~ p.sex);
        children["hb_l"].setProperty("label", "ДР: " ~ p.hb);
        children["ap_l"].setProperty("label", "Доп.телефон: " ~ p.aphone);
        children["ae_l"].setProperty("label", "Доп.email: " ~ p.aemail);
        children["addr_l"].setProperty("label", "Адрес: " ~ p.addr);

        children["premium_urev"].setProperty("reveal-child", !p.premium);
        children["premium_data_urev"].setProperty("reveal-child", p.premium);
        
        global = p;
    }

    private static void initTask() {
        import db.helper, db.schema, db.description;
        DatabaseHelper.exec(Schema!NomenclatureType.buildSchema!NomenclatureType().createRequest);
        DatabaseHelper.exec(Schema!Station.buildSchema!Station().createRequest);
        DatabaseHelper.exec(Schema!User.buildSchema!User().createRequest);
        DatabaseHelper.exec(Schema!StationPause.buildSchema!StationPause().createRequest);
        DatabaseHelper.exec(Schema!StationStop.buildSchema!StationStop().createRequest);
        DatabaseHelper.exec(Schema!Nomenclature.buildSchema!Nomenclature().createRequest);
        DatabaseHelper.exec(Schema!Input.buildSchema!Input().createRequest);
        DatabaseHelper.exec(Schema!Output.buildSchema!Output().createRequest);
        DatabaseHelper.exec(Schema!Start.buildSchema!Start().createRequest);
        DatabaseHelper.exec(Schema!Finish.buildSchema!Finish().createRequest);
        DatabaseHelper.exec(Schema!Payment.buildSchema!Payment().createRequest);
        DatabaseHelper.exec(Schema!Bonuses.buildSchema!Bonuses().createRequest);
        DatabaseHelper.exec(Schema!Moves.buildSchema!Moves().createRequest);
        DatabaseHelper.exec(Schema!Price.buildSchema!Price().createRequest);
        DatabaseHelper.exec(Schema!Profile.buildSchema!Profile().createRequest);
    }

    private void connectPages() @trusted {
        import gtk.Box, gui.widgets.data_page, gui.pages.stations;
        pages["stations_content"] = new StationsPage(this, cast(Box)children["stations_content"]);
        /*pages["station_pauses_content"] = new StationPausesPage(this, cast(Box)children["station_pauses_content"]);
        pages["station_stopes_content"] = new StationStopsPage (this, cast(Box)children["station_stopes_content"]);
        pages["articles_content"] = new NomenclaturePage(this, cast(Box)children["articles_content"]);
        pages["article_start_content"] = new NomenclatureInputPage(this, cast(Box)children["article_start_content"]);
        pages["article_finish_content"] = new NomenclatureOutputPage(this, cast(Box)children["article_finish_content"]);
        pages["article_moves_content"] = new NomenclatureMovesPage (this, cast(Box)children["article_moves_content"]);
        pages["article_changes_content"] = new NomenclaturePricesPage (this, cast(Box)children["article_changes_content"]);
        pages["article_types_content"] = new NomenclatureTypesPage (this, cast(Box)children["article_types_content"]);

        pages["users_content"] = new UsersPage (this, cast(Box)children["users_content"]);
        pages["start_content"] = new StartPage (this, cast(Box)children["start_content"]);
        pages["finish_content"] = new FinishPage (this, cast(Box)children["finish_content"]);
        pages["payment_content"] = new PaymentPage (this, cast(Box)children["payment_content"]);
        pages["bonus_content"] = new BonusesPage (this, cast(Box)children["bonus_content"]);*/

        auto t = task!updateTables(pages);
        t.executeInNewThread();
    
        AsyncTaskDialog d = new AsyncTaskDialog(this);
        d.addOnResponse((i, d) {d.close();});
        d.show();

        Timeout check = null;
        check = new Timeout(250, ()
            {
                if (t.done) {
                    d.response(0);
                    check.stop();
                }
                return true;
            }, false
        );
    }

    private static void updateTables(Widget [string] tables) {
        foreach (t; tables.values)
        {
            import gui.widgets.data_page;
            (cast(DataPage)t).updateData();
        }        
    }

    private void connectObjects(ref Builder ui) @trusted
    {
        children["color_scheme_button"] = new ColorSchemeButton(cast(Widget)ui.getObject("color_scheme_button"));

        children["content_box"] = cast(Widget)ui.getObject("content_box");
        children["stack"] = cast(Widget)ui.getObject("stack");
        children["back"] = cast(Widget)ui.getObject("back");

        children["login_umsg"] = cast(Widget)ui.getObject("login_umsg");
        children["phone_umsg"] = cast(Widget)ui.getObject("phone_umsg");
        children["phone_ubtn"] = cast(Widget)ui.getObject("phone_ubtn");
        children["email_umsg"] = cast(Widget)ui.getObject("email_umsg");
        children["email_ubtn"] = cast(Widget)ui.getObject("email_ubtn");
        children["balance_umsg"] = cast(Widget)ui.getObject("balance_umsg");
        children["balance_ubtn"] = cast(Widget)ui.getObject("balance_ubtn");
        children["balance_urev"] = cast(Widget)ui.getObject("balance_urev");
        children["premium_urev"] = cast(Widget)ui.getObject("premium_urev");
        children["support_ubtn"] = cast(Widget)ui.getObject("support_ubtn");

        children["premium_ubtn"] = cast(Widget)ui.getObject("premium_ubtn");
        children["premium_data_urev"] = cast(Widget)ui.getObject("premium_data_urev");

        children["balance_sb"] = cast(Widget)ui.getObject("balance_sb");
        children["balance_pr_btn"] = cast(Widget)ui.getObject("balance_pr_btn");        

        children["fio_l"] = cast(Widget)ui.getObject("fio_l");
        children["sex_l"] = cast(Widget)ui.getObject("sex_l");
        children["hb_l"] = cast(Widget)ui.getObject("hb_l");
        children["ap_l"] = cast(Widget)ui.getObject("ap_l");
        children["ae_l"] = cast(Widget)ui.getObject("ae_l");
        children["addr_l"] = cast(Widget)ui.getObject("addr_l");
        
        children["stations_content"] = cast(Widget)ui.getObject("stations_content");
        /*children["station_pauses_content"] = cast(Widget)ui.getObject("station_pauses_content");
        children["station_stopes_content"] = cast(Widget)ui.getObject("station_stopes_content");
    
        children["articles_content"] = cast(Widget)ui.getObject("articles_content");
        children["article_start_content"] = cast(Widget)ui.getObject("article_start_content");
        children["article_finish_content"] = cast(Widget)ui.getObject("article_finish_content");
        children["article_moves_content"] = cast(Widget)ui.getObject("article_moves_content");
        children["article_changes_content"] = cast(Widget)ui.getObject("article_changes_content");
        children["article_types_content"] = cast(Widget)ui.getObject("article_types_content");

        children["users_content"] = cast(Widget)ui.getObject("users_content");

        children["start_content"] = cast(Widget)ui.getObject("start_content");
        children["finish_content"] = cast(Widget)ui.getObject("finish_content");
        children["payment_content"] = cast(Widget)ui.getObject("payment_content");
        children["bonus_content"] = cast(Widget)ui.getObject("bonus_content");*/
    }

    private void connectSignals() @trusted
    {
        children["stack"].addOnNotify(&stackVisibleChildChanged, "visible-child");
        (cast(Button)children["back"]).addOnClicked(&backButtonPressed);

        import gtk.ToggleButton, gtk.SpinButton;
        (cast(ToggleButton)children["balance_ubtn"]).addOnToggled((t) {
            children["balance_urev"].setProperty("reveal-child", t.getActive());
        });

        (cast(Button)children["balance_pr_btn"]).addOnClicked((b) {
            Profile np = global;
            np.balance += cast(int)(cast(SpinButton)children["balance_sb"]).getValue();

            auto t = task!updateProfile(global, np);
            t.executeInNewThread();

            auto ad =new AsyncTaskDialog(this);
            ad.show();

            Timeout check = null;
            check = new Timeout(250, () {
                if (t.done()) {
                    loadData(t.yieldForce());
                    check.stop();
                    ad.close();
                }
                return  true;
            }, false);
        });

        (cast(Button)children["support_ubtn"]).addOnClicked((b) {
            import gui.dialogs.support_dialog;
            auto sd = new SupportDialog(this);
            sd.setPr(global); sd.show();
        });
    }

    private static Profile updateProfile(Profile old, Profile n) {
        import db.helper;
        DatabaseHelper.update(old, n);
        return n;
    }

    protected void stackVisibleChildChanged(ParamSpec, ObjectG) @trusted
    {
        Leaflet leaflet = cast(Leaflet)children["content_box"];
        leaflet.navigate(AdwNavigationDirection.FORWARD);
    }

    protected void backButtonPressed(Button) @trusted
    {
        Leaflet leaflet = cast(Leaflet)children["content_box"];
        leaflet.navigate(AdwNavigationDirection.BACK);
    }
}
