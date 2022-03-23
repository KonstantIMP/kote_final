fucking_bullshit_source = [
    'app.d',
    'defines.d',

    'gui/window.d',
    'gui/widgets/color_scheme_button.d',
    'gui/widgets/data_page.d',
    'gui/widgets/table_widget.d',
    'gui/widgets/date_picker.d',
    'gui/widgets/phone_entry.d',
    'gui/widgets/time_picker.d',
    'gui/dialogs/async_task_dialog.d',
    'gui/dialogs/row_dialog.d',
    'gui/dialogs/login_dialog.d',
    'gui/dialogs/signup_dialog.d',
    'gui/dialogs/support_dialog.d',

    'gui/pages/stations.d',
    'gui/pages/nomenclatures.d',
    'gui/pages/events.d',
    'gui/pages/payments.d',
    'gui/pages/users.d',

    'db/uda.d',
    'db/description.d',
    'db/helper.d',
    'db/schema.d',
    'db/shared_database.d'
]

fucking_bullshit_bin = executable(
    'abp037task2',
    fucking_bullshit_source,
    dependencies: [sqlite3_dep, gtkd_dep, resources_dep, d2sqlite3_dep, smtp_dep],
    install: true,
    d_args: ['-J=../resource/']
)
