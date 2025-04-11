import starling.animation.Transitions;

class Animations
{
    public static inline var JUMP : String = "jump";
    public static inline var SHAKE_3X : String = "shake3x";
    
    public function new()
    {
    }
    
    // call this in the project's startup code
    public static function registerTransitions() : Void
    {
        Transitions.register(JUMP, jump);
        Transitions.register(SHAKE_3X, shake3x);
    }
    
    private static function jump(ratio : Float) : Float
    {
        return Math.sin(ratio * Math.PI);
    }
    
    private static function shake3x(ratio : Float) : Float
    {
        return Math.sin(ratio * Math.PI * 3);
    }
}
