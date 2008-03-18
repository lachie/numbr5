class Insulter
  PHRASE1 = ["artless","bawdy","beslubbering","bootless","churlish","clouted",
  		"cockered","craven","currish","dankish","dissembling","droning","errant","fawning",
  		"fobbing","frothy","froward","gleeking","goatish","gorbellied","impertinent",
  		"infectious","jarring","loggerheaded","lumpish","mammering","mangled","mewling",
  		"paunchy","pribbling","puking","puny","qualling","rank","reeky","roguish","ruttish",
  		"saucy","spleeny","spongy","surly","tottering","unmuzzled","vain","venomed",
  		"villainous","warped","wayward","weedy","yeasty"]

  PHRASE2 = ["base-court","bat-fowling","beef-witted","beetle-headed",
  		"boil-brained","clapper-clawed","clay-brained","common-kissing","crook-pated",
  		"dismal-dreaming","dizzy-eyed","doghearted","dread-bolted","earth-vexing",
  		"elf-skinned","fat-kidneyed","fen-sucked","flap-mouthed","fly-bitten",
  		"folly-fallen","fool-born","full-gorged","guts-griping","half-faced","hasty-witted",
  		"hedge-born","hell-hated","idle-headed","ill-breeding","ill-nurtured","knotty-pated",
  		"milk-livered","motley-minded","onion-eyed","plume-plucked","pottle-deep",
  		"pox-marked","reeling-ripe","rough-hewn","rude-growing","rump-fed","shard-borne",
  		"sheep-biting","spur-galled","swag-bellied","tardy-gaited","tickle-brained",
  		"toad-spotted","urchin-snouted","weather-bitten"]

  PHRASE3 = ["apple-john","baggage","barnacle","bladder","boar-pig","bugbear",
  		"bum-bailey","canker-blossom","clack-dish","clotpole","codpiece","coxcomb","death-token",
  		"dewberry","flap-dragon","flax-wench","flirt-gill","foot-licker","fustilarian",
  		"giglet","gudgeon","haggard","harpy","hedge-pig","horn-beast","hugger-mugger",
  		"joithead","lewdster","lout","maggot-pie","malt-worm","mammet","measle","minnow",
  		"miscreant","moldwarp","mumble-news","nut-hook","pigeon-egg","pignut","pumpion",
  		"puttock","ratsbane","scut","skainsmate","strumpet","varlet","vassal","wagtail",
  		"whey-face"]

  def self.pick(list)
    list[rand(list.size)]
  end

  def self.welcome_to(place, name=nil)
    name = " #{name}" if name
    "Welcome to #{place}#{name}, thou #{pick(PHRASE1)} #{pick(PHRASE2)} #{pick(PHRASE3)}!"
  end
  
  def self.insult(nick)
    p1 = pick(PHRASE1)
    joiner = [?a,?e,?i,?o,?u].include?(p1[0]) ? 'an' : 'a'
    "#{nick}: thou art #{joiner} #{p1} #{pick(PHRASE2)} #{pick(PHRASE3)}!"
  end
end

if __FILE__ == $0
  puts Insulter.welcome_to('#ror_au','bob')
end
