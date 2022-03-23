module app;

import adw.Application, gtk.Builder, gui.window, r.r, defines;

int main(string [] args)
{
    Application kote_app = new Application("org.kimp.loveseo8.kote", GApplicationFlags.FLAGS_NONE);

	kote_app.addOnActivate(
		(app) 
		{
			Builder ui_builder = new Builder();
			ui_builder.addFromString(R.PROFILE_WINDOW_LAYOUT, R.PROFILE_WINDOW_LAYOUT.length);

			KoteWindow kote_win = new KoteWindow(ui_builder, kote_app);
			kote_app.addWindow(kote_win);
			kote_win.show();
		}
	);

	return kote_app.run(args);
}
