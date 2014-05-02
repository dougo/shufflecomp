#charset "utf-8"
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
  }
;

versionInfo: GameID
  IFID = '853AF89C-7D32-49EE-85FA-77A49F1ACD99'
  name = 'Look Around The Corner'
  headline = 'A ShuffleComp entry'
  byline = 'by Robert Whitlock'
  authorEmail = 'Robert Whitlock <rwshuffle@gmail.com>'
  desc = 'An interactive fiction inspired by the song "Look Around The Corner" by Quantic & Alice Russell
          with the Combo Bárbaro. https://www.youtube.com/watch?v=p4yJp4CLRL4'
  version = '1'
  releaseDate = '2014-05-01'
  forgiveness = 'Merciful'
  licenseType = 'Freeware'
  copyingRules = 'No Restrictions'
  serialNum = static releaseDate.findReplace('-', '', ReplaceAll, 1)
  showAbout() {
     """
     <<desc>>\b

     This is the beta version. Really more like alpha. It was meant to be small and simple, but not as barren
     and boring as it is right now. Sorry about that. I hope to flesh this out a bit more before the final
     release, but we'll see.\b

     Please feel free to send me any and all ideas and suggestions, in addition to bug reports. I am also happy
     to provide the TADS 3 source code on request. Mail me at rwshuffle@gmail.com.\b

     What do you, the playtester, do?
     """;
  }
;

bedroom: Room 'Bedroom'
  """
  This is your bedroom. To the north stretches a long hallway.
  <<if me.newDay>>\bAnother day is born, rise up!<<end>>
  """
  roomDesc() {
    inherited;
    me.newDay = nil;
  }
  north = hallway
;

VerbRule(RiseUp)
  'rise' 'up' | 'rise' | 'arise' : StandAction
;

+bed: Bed, Heavy 'bed' 'bed'
;

++me: Actor
  newDay = true
  posture = lying
  goToSleep() {
    if (isDirectlyIn(bedroom)) {
      tryImplicitAction(LieOn, bed);
    }
    if (isDirectlyIn(bed)) {
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
    } else {
      inherited;
    }
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
;

DefineTAction(LookAround);

VerbRule(LookAround)
  ('look' | 'l' | 'peer' | 'peek') 'around' singleDobj : LookAroundAction
  verbPhrase = 'look/looking around (what)'
;

+corner: RoomPart 'corner'
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
  execAction() {
    """
    <<one of>>
    The light is not coming from (just) the sun, but from all the stars in the sky.
    We are made of the stars, you and I; the light from each star has been traveling for years, or eons,
    to reach us.
    \bYou are hypnotized by Space and time.
    <<or>>
    The light of the dawn filters through an enormous tree, whose trunk divides into branches, whose branches
    divide into twigs, whose twigs carry leaves.  Each leaf has veins the divide into smaller and smaller
    veins.
    \bYou are hypnotized by Leaves and branches.
    <<or>>
    TODO: eye of Marduk (or Tiamat?) made up of smaller quantic eyes
    \bYou are hypnotized by Eyes and souls.
    <<or>>
    TODO: wheels within wheels never turning
    \bYou are hypnotized by Eternity and stillness.
    <<or>>
    \bYou are hypnotized by Patterns? P?
    <<cycling>>\b
    """;

    inputManager.pauseForMore(true);
    cls();
    me.newDay = true;

    me.moveIntoForTravel(bed);
    me.makePosture(lying);
    "\b";
    me.lookAround(true);
  }
;
