public enum PowerupType
{
  BULLETHELL, SHIELDS, ENGINES
};

public class Powerup extends Physical implements Friendly
{
  PowerupType type;

	public Powerup(PVector _loc, PVector _size, PImage _sprite, PowerupType _type, Sector _sector, Shape _collider)
	{
		super("Powerup", _loc, _size, 500, _sector, _collider);

		sprite = _sprite;
		sprite.resize((int)size.x, (int)size.y);

    type = _type;
	}

  /**
	 * Toggles powerup modes on the player
	 * @param _friend Friendly object
 	 */
  public void ProvideAid(Physical _friend)
  {
  	if(_friend instanceof Player)		//HACK force check
  	{
      Player play = (Player)_friend;
      if(type == PowerupType.BULLETHELL)
      {
        play.EnableBulletHell();
      }
      else if(type == PowerupType.SHIELDS)
      {
        play.shield.RestoreShield();

      }
      else if(type == PowerupType.ENGINES)
      {
        play.EnableEngineBoost();
      }
      else
      {
        println("[ERROR] Invalid powerup type!");
      }
  		
  	}

    toBeKilled = true;
  }

}