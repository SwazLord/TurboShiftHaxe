import starling.display.Sprite;
import starlingbuilder.engine.ICustomComponent;
import starling.display.Image;

class ButtonSprite extends Sprite implements ICustomComponent
{
    public var disabled(get, set) : Bool;

    private var ban_icon : Image;
    private var _disabled : Bool;
    
    public function initComponent() : Void
    {
        this.touchGroup = true;
        ban_icon = try cast(getChildByName("ban_icon"), Image) catch(e:Dynamic) null;
        ban_icon.visible = disabled;
    }
    
    private function get_disabled() : Bool
    {
        return _disabled;
    }
    
    private function set_disabled(value : Bool) : Bool
    {
        ban_icon.visible = _disabled = value;
        return value;
    }

    public function new()
    {
        super();
    }
}
