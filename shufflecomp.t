#charset "UTF-8"
// Copyright © 2014 Doug Orleans.
//
// This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero
// General Public License as published by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
// implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public
// License for more details.
//
// You should have received a copy of the GNU Affero General Public License along with this program.  If not,
// see: http://www.gnu.org/licenses/agpl-3.0.html
//
// This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License. To view
// a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative
// Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

#include <adv3.h>
#include <en_us.h>

gameMain: GameMainDef
  initialPlayerChar = me
  showIntro() {
    """
    "Sing to me of your sadness and tell me of your joy..."\b
    <b><<versionInfo.name>></b>\n
    <<versionInfo.byline>>\n
    Release <<versionInfo.version>> (<<versionInfo.serialNum>>)\b
    First-time players should type <<aHref('ABOUT', 'ABOUT')>>.\b
    """;
    libGlobal.scoreObj = nil;
  }
;

versionInfo: GameID
  IFID = '853AF89C-7D32-49EE-85FA-77A49F1ACD99'
  name = 'Look Around the Corner'
  byline = 'by Doug Orleans (as Robert Whitlock)'
  authorEmail = 'Doug Orleans <dougorleans@gmail.com>'
  desc = 'An interactive fiction (an entry in ShuffleComp 2014) inspired by the song "Look Around the Corner"
          by Quantic & Alice Russell with the Combo Bárbaro.'
  version = '5'
  releaseDate = '2014-06-12'
  firstPublished = '2014-05-12'
  forgiveness = 'Merciful'
  licenseType = 'Freeware'
  copyingRules = 'No Restrictions'
  serialNum = static releaseDate.findReplace('-', '', ReplaceAll, 1)
  showAbout() {
     """
     An interactive fiction (an entry in ShuffleComp 2014) inspired by the song
     <<link('http://www.youtube.com/watch?v=p4yJp4CLRL4',
            '"Look Around the Corner" by Quantic & Alice Russell with the Combo Bárbaro.')>>\b

     Thanks to my testers: Scooter Burch, Juhana Leinonen, Jason McIntosh, Zach Samuels, Carolyn VanEseltine,
     Olly V., and Caleb Wilson.  Also thanks to Sam Kabo Ashwell for organizing the competition, and thanks to
     Caleb Wilson, Andrew Schultz, and Jason Dyer for posting positive reviews during the comp. :)\b

     Extra-special thanks to the Mysterious Strangers who submitted the song "Look Around the Corner" and
     the pseudonym "Robert Whitlock". I hope to learn your identities some day so I can properly thank you here!\b

     Please feel free to <<link('mailto:dougorleans@gmail.com', 'send me feedback')>>. The source code is
     available (under the <<aHref('http://www.gnu.org/licenses/agpl-3.0.html', 'AGPLv3')>>) on
     <<link('http://github.com/dougo/shufflecomp', 'GitHub')>>, where you can also
     submit bug reports.  The text is licensed under
     <<aHref('http://creativecommons.org/licenses/by-sa/4.0/', 'CC BY-SA 4.0')>>.
     """;
  }
  showCredit() { showAbout(); }
  link(href, text) { // for console mode, include the href in the alt text.
    "<<aHrefAlt(href, text, '<<text>> &lt;<<href>>&gt;')>>";
  }
;

bedroom: Room 'Bedroom'
  """
  This is your bedroom, or at least you think it is. The room is mostly very dim and indistinct. To the north
  stretches a long hallway, lit at the far end by the new light of the dawn<<if me.days>>. The light looks
  a little different than it did yesterday<<end>>.

  <<if me.newDay>><<beginDay>><<end>>
  """
  beginDay() {
    "\bAnother day is <<one of>>born<<or>>born<<or>>here<<as decreasingly likely outcomes>>,
     rise up!";
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

+Fixture 'bedroom/room/here' 'bedroom'
  "You can't make out anything in the room, other than the hallway to the north lit at the end by the dawn light."
;

+Fixture 'hall/hallway' 'hallway'
  "The hallway stretches north, then turns to the east, into the dawn light."
  dobjFor(Enter) remapTo(TravelVia, hallway)
;

+Distant 'new light of the dawn dawn/light' 'light'
  "At the end of the hallway, the new light of the dawn streams in from around the corner."
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
  pcDesc = "You have been yourself since the earliest recording of time.
            You will be yourself till our days are done."
  newDay = true
  days = 0
  posture = lying
  goToSleep() {
    if (posture != lying) { tryImplicitAction(Lie); }
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

+++Component 'eyes' 'eyes'
  "They are wide open."
  isPlural = true
  dobjFor(Open) {
    verify() { illogical('They are wide open.'); }
  }
  dobjFor(Close) {
    verify() { }
    action() {
      "You close your eyes for a few seconds, but the dawn light seeps in, beckoning.";
    }
  }
;

hallway: Room 'Hallway'
  """
  Here at the north end of the hallway, the dawn light streams in from around the corner to the east.
  Back to the south is your bedroom.
  """

  south = bedroom
  east = aroundCorner

  actorKnowsDestination(actor, connector) { return true; }

  // Replace defaultEastWall so we can override LOOK EAST.
  roomParts = [defaultFloor, defaultCeiling, defaultNorthWall, defaultSouthWall, lightWall, defaultWestWall]
;

DefineTAction(LookAround);

VerbRule(LookAround)
  ('look' | 'l' | 'peer' | 'peek') 'around' singleDobj : LookAroundAction
  verbPhrase = 'look/looking around (what)'
;

+corner: RoomPart 'corner' 'corner'
  dobjFor(LookAround) {
    action() {
      "You look around the corner, into the light.\b";
      replaceAction(Hypnotize);
    }
  }
  dobjFor(Examine) remapTo(LookAround, corner)
;

+light: Fixture 'new light of the dawn dawn/light' 'light'
  dobjFor(Examine) remapTo(LookAround, corner)
  dobjFor(LookIn) remapTo(LookAround, corner)
  dobjFor(Enter) remapTo(TravelVia, aroundCorner)
;

lightWall: DefaultWall
  adjective = 'e' 'east'
  name = 'east wall'
  dobjFor(Examine) remapTo(LookAround, corner)
;

aroundCorner: DeadEndConnector
  apparentDestName = 'around the corner'
  travelDesc() {
    "You step around the corner, into the light.\b";
    replaceAction(Hypnotize);
  }
;

modify explicitExitLister
  showListItem(obj, options, pov, infoTab) {
    if (obj.dest_ && obj.dest_.connector == aroundCorner) {
      " east, <<obj.destName_>>"; // instead of "east, to <<obj.destName_>>"
    } else {
      inherited(obj, options, pov, infoTab);
    }
  }
;

DefineIAction(Hypnotize)
  dawn() {
    """
    <<one of>>
    The light is not coming from (just) the sun, but from all the stars in the sky. The light from each star
    has been traveling for years or eons to reach your eyes, while the matter that makes up your body and
    everything you know also came from the stars long before that.
    <<or>>
    The light of the dawn filters through an enormous tree, whose trunk divides into branches, whose branches
    divide into twigs, whose twigs carry leaves.  Each leaf has veins that branch into smaller and smaller
    veins, bringing water and minerals to every chlorophyllic cell.
    <<or>>
    The light is emanating from a giant eye, the eye of Enki, from Ki-En-Gir, the land of the lords of brightness.
    The eye is a disc of smaller eyes, and each smaller eye is itself a disc of smaller eyes, and so on, until
    you can make out the smallest quantic layer of eyes. They look back at you, unblinking.
    <<or>>
    The light beams from the center of a rapidly spinning wheel. Around that wheel is a larger wheel, spinning
    once for every ten revolutions of the inner wheel. Around that wheel is a still larger wheel, spinning ten
    times slower, and so on, out to the outermost wheel which is perfectly motionless.
    <<or>>
    The light decomposes into a lattice of lines and angles, strobing from side to side and up and down. The
    steady movement of lines across intersecting lines forms a periodic syncopation in alternating dimensions.
    <<cycling>>
    """;
  }
  highlight(text) {
    if (me.days < 5) {
      "<<text>>";
    } else {
      "<b><u><<text>></u></b>";
    }
  }
  hypnosis() {
    """
    <<one of>>
    <<highlight('S')>>pace and time<<or>>
    <<highlight('L')>>eaves and branches<<or>>
    <<highlight('E')>>yes and souls<<or>>
    <<highlight('E')>>ternity and stillness<<or>>
    <<highlight('P')>>atterns and rhythms<<cycling>>""";
  }
  execAction() {
    """
    ~o~\b
    <<dawn>>\b
    ~o~\b
    So enchanted, hypnotized by <<hypnosis>>... Who knows if this is all there is?\b
    Come the morning, we get to start anew.\n
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

DefineIAction(Sing)
  execAction() {
    "You sing of your sadness. There is no reply.";
  }
;

VerbRule(Sing)
  'sing' : SingAction
  verbPhrase = 'sing/singing'
;

DefineIAction(Wake)
  execAction() {
    "You are awake. You are awake. Yes, you are awake.";
  }
;

VerbRule(Wake)
  'wake' | 'wake' 'up' | 'awake' : WakeAction
  verbPhrase = 'wake/waking'
;

modify HintAction
  execSystemAction() {
    "Look around the corner, tell me what do you see?";
  }
;

DefineTAction(WTF);

VerbRule(WTF)
  'wtf' singleDobj : WTFAction
;

modify VocabObject
  dobjFor(WTF) {
    action() { "HELLO WTF {the dobj/him}"; }
  }
;

modify playerMessages
  askUnknownWord(actor, txt) {
    if (txt.compareIgnoreCase('xyzzy') == 0) {
      "<.parser>The word <q><<txt>></q> is not necessary in this story... OR IS IT?<./parser>";
      oopsNote();
    } else {
      inherited(actor, txt);
    }
  }
;
