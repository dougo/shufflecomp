#include <adv3.h>
#include <en_us.h>

gameMain: GameMainDef
  initialPlayerChar = me
  showIntro() {
    """
    "Sing to me of your sadness and tell me of your joy..."\b
    <b><<versionInfo.name>>: <<versionInfo.headline>></b>\n
    <<versionInfo.byline>>\n
    Release <<versionInfo.version>> (<<versionInfo.serialNum>>)\b
    First-time players should type ABOUT.\b
    """;
    libGlobal.scoreObj = nil;
  }
;

versionInfo: GameID
  IFID = '853AF89C-7D32-49EE-85FA-77A49F1ACD99'
  name = 'Look Around The Corner'
  headline = 'A ShuffleComp entry'
  byline = 'by Robert Whitlock'
  authorEmail = 'Robert Whitlock <rwshuffle@gmail.com>'
  desc = 'An interactive fiction inspired by the song "Look Around The Corner" by Quantic & Alice Russell
          with the Combo B&aacute;rbaro. https://www.youtube.com/watch?v=p4yJp4CLRL4'
  version = '2'
  releaseDate = '2014-05-11'
  forgiveness = 'Merciful'
  licenseType = 'Freeware'
  copyingRules = 'No Restrictions'
  serialNum = static releaseDate.findReplace('-', '', ReplaceAll, 1)
  showAbout() {
     """
     <<desc>>\b

     Thanks to my testers: Scooter Burch, Juhana Leinonen, Jason McIntosh, Carolyn VanEseltine, and Caleb Wilson.\b

     Please send bug reports and other feedback to rwshuffle@gmail.com. I am also happy to provide the TADS 3
     source code on request. (It will be published on Github after the competition is over.)
     """;
  }
  showCredit() { showAbout(); }
;

bedroom: Room 'Bedroom'
  """
  This is your bedroom. To the north stretches a long hallway, lit at the far end by the light of the dawn.
  <<if me.newDay>>\bAnother day is born, rise up!<<end>>
  """
  roomDesc() {
    inherited;
    me.newDay = nil;
  }
  north: TravelMessage { ->hallway "Eyes wide open, you tread wisely down the length of the hallway." }
  out asExit(north)
  down: NoTravelMessage {
    dobjFor(TravelVia) {
      remap = (me.posture == standing) ? [LieAction] : [LieOnAction, defaultFloor]
    }
  }
  up: NoTravelMessage {
    dobjFor(TravelVia) {
      remap = (me.posture == standing) ? inherited() : [StandAction]
      action() { bedroom.cannotTravel(); }
    }
  }
;

VerbRule(RiseUp)
  'rise' 'up' | 'rise' | 'arise' : StandAction
;

+bed: Bed, Heavy 'bed' 'bed'
  out asExit(bedroom.north)
  up = noTravelOut
  down: NoTravelMessage {
    dobjFor(TravelVia) remapTo(Lie)
  }
;

++me: Actor
  newDay = true
  days = 0
  posture = lying
  goToSleep() {
    if (posture != lying) {
      tryImplicitAction(Lie);
    }
    """
    You close your eyes and swiftly drift off to sleep, to the gently pulsating sound of violins...\b
    """;
    inputManager.pauseForMore(true);
    cls();
    """
    You wake up to the sound and smell of sizzling bacon drifting in from down the hall.\b
    "Dear, were you sleepwalking again?"
    """;
    finishGameMsg('You have woken up.', []);
  }
;

hallway: Room 'Hallway'
  """
  Here at the north end of the hallway, the new light of the dawn streams in from around the corner to the east.
  Back to the south is your bedroom.
  """

  south = bedroom
  east = light

  actorKnowsDestination(actor, connector) { return true; }

  // TODO: x light, x dawn, go to light? enter light?
;

DefineTAction(LookAround);

VerbRule(LookAround)
  ('look' | 'l' | 'peer' | 'peek') 'around' singleDobj : LookAroundAction
  verbPhrase = 'look/looking around (what)'
;

+corner: RoomPart 'corner' 'corner'
  // TODO: x corner should look into the light.
  dobjFor(LookAround) {
    action() {
      "You look around the corner, into the light.\b";
      replaceAction(Hypnotize);
    }
  }
;

light: DeadEndConnector
  // TODO: this shows the exit as "east, to the light". Better would be "east, into the light",
  // or "east, around the corner". Need to make a new subclass of ExitLister?
  apparentDestName = 'the light'
  travelDesc() {
    "You step around the corner, into the light.\b";
    replaceAction(Hypnotize);
  }
;

DefineIAction(Hypnotize)
  highlight(text) {
    if (me.days < 5) {
      "<<text>>";
    } else {
      "<b><u><<text>></u></b>";
    }
  }
  execAction() {
    """
    ~o~\b
    <<one of>>
    The light is not coming from (just) the sun, but from all the stars in the sky. The light from each star
    has been traveling for years or eons to reach your eyes, while the matter that makes up your body and
    everything you know also came from the stars long before that.
    \b~o~\bYou are hypnotized by <<highlight('S')>>pace and time.
    <<or>>
    The light of the dawn filters through an enormous tree, whose trunk divides into branches, whose branches
    divide into twigs, whose twigs carry leaves.  Each leaf has veins that branch into smaller and smaller
    veins, bringing water and minerals to every chlorophyllic cell.
    \b~o~\bYou are hypnotized by <<highlight('L')>>eaves and branches.
    <<or>>
    The light is emanating from a giant eye, the eye of Enki, from Ki-En-Gir, the land of the lords of brightness.
    The eye is a disc of smaller eyes, and each smaller eye is itself a disc of smaller eyes, and so on, until
    you can make out the smallest quantic layer of eyes. They look back at you, unblinking.
    \b~o~\bYou are hypnotized by <<highlight('E')>>yes and souls.
    <<or>>
    The light beams from the center of a rapidly spinning wheel. Around that wheel is a larger wheel, spinning
    once for every ten revolutions of the inner wheel. Around that wheel is a still larger wheel, spinning ten
    times slower, and so on, out to the outermost wheel which is perfectly motionless.
    \b~o~\bYou are hypnotized by <<highlight('E')>>ternity and stillness.
    <<or>>
    The light decomposes into a lattice of lines and angles, strobing from side to side and up and down. The
    steady movement of lines across intersecting lines forms a periodic syncopation in alternating dimensions.
    \b~o~\bYou are hypnotized by <<highlight('P')>>atterns and rhythms.
    <<cycling>>\b
    """;

    inputManager.pauseForMore(true);
    cls();
    me.days++;
    me.newDay = true;

    me.moveIntoForTravel(bed);
    me.makePosture(lying);
    "\b";
    me.lookAround(true);
  }
;

modify HintAction
  execSystemAction() {
    "Look around the corner, tell me what do you see?";
  }
;

// TODO: xyzzy?
