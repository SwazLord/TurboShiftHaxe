import starling.display.MovieClip;
import starling.filters.SineWaveFilter;

class EnemyCar extends MovieClip
{
    public function new()
    {
        super(Game.current_instance._asst_manager.getTextures("enemy_car_"), 1);
    }
    
    public function reset() : Void
    {
        currentFrame = Math.floor(Math.random() * 5);
        this.filter = null;
    }
    
    public function crashed() : Void
    {
        this.filter = new SineWaveFilter(10, 30);
    }
}
