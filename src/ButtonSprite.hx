import starling.display.Sprite;
import starling.display.Image;
import starlingbuilder.engine.ICustomComponent;

class ButtonSprite extends Sprite implements ICustomComponent
{
    public var disabled(get, set) : Bool;

    private var _ban_icon : Image;
    private var _disabled : Bool;
    
    private function get_disabled() : Bool
    {
        return _disabled;
    }
    
    private function set_disabled(value : Bool) : Bool
    {
        _ban_icon.visible = _disabled = value;
        return value;
    }
    
    
    public function initComponent() : Void
    {
        this.touchGroup = true;
        _ban_icon = try cast(getChildByName("ban_icon"), Image) catch(e:Dynamic) null;
    }

    public function new()
    {
        super();
    }
}
