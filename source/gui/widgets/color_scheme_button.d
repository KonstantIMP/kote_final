/**
 * Button for color scheme changing
 * Authors:
 *   KonstantIMP <mihedovkos@gmail.com>
 *   Loveseo8 <maggaket@gmail.com>
 * Date: 02 Dec 2021
 */
module gui.widgets.color_scheme_button;

/** Import libadwaitaand gtk */
import gtk.Button, gtk.Widget, adw.StyleManager;

/** 
 * Button for color scheme changing
 */
class ColorSchemeButton : Button
{
    /** 
     * Inits the object from Widget instance
     * Params:
     *   instance = The button
     */
    public this(Widget instance) @trusted
    {
        super((cast(Button)instance).getButtonStruct(), true);

        setSchemeIcon();
        this.addOnClicked(&onButtonClicked);
    }

    /** 
     * Set icon except theme
     */
    private void setSchemeIcon() @trusted
    {
        StyleManager manager = StyleManager.getDefault();

        if (manager.getDark())
        {
            this.setIconName("weather-clear-symbolic");
        }
        else
        {
            this.setIconName("weather-clear-night-symbolic");
        }
    }

    /** 
     * Change application's theme
     * Params:
     *   self = Pressed button
     */
    protected void onButtonClicked(Button self) @trusted
    {
        StyleManager manager = StyleManager.getDefault();
        
        if (manager.getDark())
        {
            manager.setColorScheme(AdwColorScheme.FORCE_LIGHT);
        }
        else
        {
            manager.setColorScheme(AdwColorScheme.FORCE_DARK);
        }

        setSchemeIcon();
    }
}
