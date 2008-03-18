require 'runit/testcase'
require 'runit/cui/testrunner'
require File.dirname(__FILE__)+'/../lib/rice/irc'


class TestRICE__Message < RUNIT::TestCase
  def setup
    @t = RICE::Message
  end

  def teardown
  end

  def msg_to_a(str)
    @t.parse(str + "\r\n").to_a
  end

  def msg_to_s(*ary)
    @t.build(*ary).to_s.sub!("\r\n", '')
  end

  def test_to_s
    assert_equal(msg_to_s(nil, 'NICK', ['Wiz']),
		 'NICK Wiz')
    assert_equal(msg_to_s('WiZ!jto@tolsun.oulu.fi', 'NICK', ['Kilroy']),
		 ':WiZ!jto@tolsun.oulu.fi NICK Kilroy')
    assert_equal(msg_to_s(nil, 'USER', ['guest', '0', '*', 'Ronnie Reagan']),
		 'USER guest 0 * :Ronnie Reagan')
    assert_equal(msg_to_s(nil, 'USER', ['guest', '8', '*', 'Ronnie Reagan']),
		 'USER guest 8 * :Ronnie Reagan')
    assert_equal(msg_to_s(nil, 'OPER', ['foo', 'bar']),
		 'OPER foo bar')
    assert_equal(msg_to_s(nil, 'MODE', ['WiZ', '-w']),
		 'MODE WiZ -w')
    assert_equal(msg_to_s(nil, 'MODE', ['Angel', '+i']),
		 'MODE Angel +i')
    assert_equal(msg_to_s(nil, 'MODE', ['WiZ', '-o']),
		 'MODE WiZ -o')
    assert_equal(msg_to_s(nil, 'SERVICE', ['dict', '*', '*.fr', '0', '0', 'French Dictionary']),
		 'SERVICE dict * *.fr 0 0 :French Dictionary')
    assert_equal(msg_to_s(nil, 'QUIT', ['Gone to have lunch']),
		 'QUIT :Gone to have lunch')
    assert_equal(msg_to_s('syrk!kalt@millennium.stealth.net', 'QUIT', ['Gone to have lunch']),
		 ':syrk!kalt@millennium.stealth.net QUIT :Gone to have lunch')
    assert_equal(msg_to_s(nil, 'SQUIT', ['tolsun.oulu.fi', 'Bad Link ?']),
		 'SQUIT tolsun.oulu.fi :Bad Link ?')
    assert_equal(msg_to_s('Trillian', 'SQUIT', ['cm22.eng.umd.edu', 'Server out of control']),
		 ':Trillian SQUIT cm22.eng.umd.edu :Server out of control')
    assert_equal(msg_to_s(nil, 'JOIN', ['#foobar']),
		 'JOIN #foobar')
    assert_equal(msg_to_s(nil, 'JOIN', ['&foo', 'fubar']),
		 'JOIN &foo fubar')
    assert_equal(msg_to_s(nil, 'JOIN', ['#foo,&bar', 'fubar']),
		 'JOIN #foo,&bar fubar')
    assert_equal(msg_to_s(nil, 'JOIN', ['#foo,#bar', 'fubar,foobar']),
		 'JOIN #foo,#bar fubar,foobar')
    assert_equal(msg_to_s(nil, 'JOIN', ['#foo,#bar']),
		 'JOIN #foo,#bar')
    assert_equal(msg_to_s(nil, 'JOIN', ['0']),
		 'JOIN 0')
    assert_equal(msg_to_s('WiZ!jto@tolsun.oulu.fi', 'JOIN', ['#Twilight_zone']),
		 ':WiZ!jto@tolsun.oulu.fi JOIN #Twilight_zone')
    assert_equal(msg_to_s(nil, 'PART', ['#twilight_zone']),
		 'PART #twilight_zone')
    assert_equal(msg_to_s(nil, 'PART', ['#oz-ops,&group5']),
		 'PART #oz-ops,&group5')
    assert_equal(msg_to_s('WiZ!jto@tolsun.oulu.fi', 'PART', ['#playzone', 'I lost']),
		 ':WiZ!jto@tolsun.oulu.fi PART #playzone :I lost')
    assert_equal(msg_to_s(nil, 'MODE', ['#Finnish', '+imI', '*!*@*.fi']),
		 'MODE #Finnish +imI *!*@*.fi')
    assert_equal(msg_to_s(nil, 'MODE', ['#Finnish', '+o', 'Kilroy']),
		 'MODE #Finnish +o Kilroy')
    assert_equal(msg_to_s(nil, 'MODE', ['#Finnish', '+v', 'Wiz']),
		 'MODE #Finnish +v Wiz')
    assert_equal(msg_to_s(nil, 'MODE', ['#Fins', '-s']),
		 'MODE #Fins -s')
    assert_equal(msg_to_s(nil, 'MODE', ['#42', '+k', 'oulu']),
		 'MODE #42 +k oulu')
    assert_equal(msg_to_s(nil, 'MODE', ['#42', '-k', 'oulu']),
		 'MODE #42 -k oulu')
    assert_equal(msg_to_s(nil, 'MODE', ['#eu-opers', '+l', '10']),
		 'MODE #eu-opers +l 10')
    assert_equal(msg_to_s('WiZ!jto@tolsun.oulu.fi', 'MODE', ['#eu-opers', '-l']),
		 ':WiZ!jto@tolsun.oulu.fi MODE #eu-opers -l')
    assert_equal(msg_to_s(nil, 'MODE', ['&oulu', '+b']),
		 'MODE &oulu +b')
    assert_equal(msg_to_s(nil, 'MODE', ['&oulu', '+b', '*!*@*']),
		 'MODE &oulu +b *!*@*')
    assert_equal(msg_to_s(nil, 'MODE', ['&oulu', '+b', '*!*@*.edu', '+e', '*!*@*.bu.edu']),
		 'MODE &oulu +b *!*@*.edu +e *!*@*.bu.edu')
    assert_equal(msg_to_s(nil, 'MODE', ['#meditation', 'e']),
		 'MODE #meditation e')
    assert_equal(msg_to_s(nil, 'MODE', ['#meditation', 'I']),
		 'MODE #meditation I')
    assert_equal(msg_to_s(nil, 'MODE', ['!12345ircd', 'O']),
		 'MODE !12345ircd O')
    assert_equal(msg_to_s('WiZ!jto@tolsun.oulu.fi', 'TOPIC', ['#test', 'New topic']),
		 ':WiZ!jto@tolsun.oulu.fi TOPIC #test :New topic')
    assert_equal(msg_to_s(nil, 'TOPIC', ['#test', 'another topic']),
		 'TOPIC #test :another topic')
    assert_equal(msg_to_s(nil, 'TOPIC', ['#test', '']),
		 'TOPIC #test :')
    assert_equal(msg_to_s(nil, 'TOPIC', ['#test']),
		 'TOPIC #test')
    assert_equal(msg_to_s(nil, 'NAMES', ['#twilight_zone,#42']),
		 'NAMES #twilight_zone,#42')
    assert_equal(msg_to_s(nil, 'NAMES', []),
		 'NAMES')
    assert_equal(msg_to_s(nil, 'LIST', []),
		 'LIST')
    assert_equal(msg_to_s(nil, 'LIST', ['#twilight_zone,#42']),
		 'LIST #twilight_zone,#42')
    assert_equal(msg_to_s('Angel!wings@irc.org', 'INVITE', ['Wiz', '#Dust']),
		 ':Angel!wings@irc.org INVITE Wiz #Dust')
    assert_equal(msg_to_s(nil, 'INVITE', ['Wiz', '#Twilight_Zone']),
		 'INVITE Wiz #Twilight_Zone')
    assert_equal(msg_to_s(nil, 'KICK', ['&Melbourne', 'Matthew']),
		 'KICK &Melbourne Matthew')
    assert_equal(msg_to_s(nil, 'KICK', ['#Finnish', 'John', 'Speaking English']),
		 'KICK #Finnish John :Speaking English')
    assert_equal(msg_to_s('WiZ!jto@tolsun.oulu.fi', 'KICK', ['#Finnish', 'John']),
		 ':WiZ!jto@tolsun.oulu.fi KICK #Finnish John')
    assert_equal(msg_to_s('Angel!wings@irc.org', 'PRIVMSG', ['Wiz', 'Are you receiving this message ?']),
		 ':Angel!wings@irc.org PRIVMSG Wiz :Are you receiving this message ?')
    assert_equal(msg_to_s(nil, 'PRIVMSG', ['Angel', 'yes I\'m receiving it !']),
		 'PRIVMSG Angel :yes I\'m receiving it !')
    assert_equal(msg_to_s(nil, 'PRIVMSG', ['jto@tolsun.oulu.fi', 'Hello !']),
		 'PRIVMSG jto@tolsun.oulu.fi :Hello !')
    assert_equal(msg_to_s(nil, 'PRIVMSG', ['kalt%millennium.stealth.net@irc.stealth.net', 'Are you a frog?']),
		 'PRIVMSG kalt%millennium.stealth.net@irc.stealth.net :Are you a frog?')
    assert_equal(msg_to_s(nil, 'PRIVMSG', ['kalt%millennium.stealth.net', 'Do you like cheese?']),
		 'PRIVMSG kalt%millennium.stealth.net :Do you like cheese?')
    assert_equal(msg_to_s(nil, 'PRIVMSG', ['Wiz!jto@tolsun.oulu.fi', 'Hello !']),
		 'PRIVMSG Wiz!jto@tolsun.oulu.fi :Hello !')
    assert_equal(msg_to_s(nil, 'PRIVMSG', ['$*.fi', 'Server tolsun.oulu.fi rebooting.']),
		 'PRIVMSG $*.fi :Server tolsun.oulu.fi rebooting.')
    assert_equal(msg_to_s(nil, 'PRIVMSG', ['#*.edu', 'NSFNet is undergoing work, expect interruptions']),
		 'PRIVMSG #*.edu :NSFNet is undergoing work, expect interruptions')
    assert_equal(msg_to_s(nil, 'VERSION', ['tolsun.oulu.fi']),
		 'VERSION tolsun.oulu.fi')
    assert_equal(msg_to_s(nil, 'STATS', []),
		 'STATS')
    assert_equal(msg_to_s(nil, 'LINKS', ['*.au']),
		 'LINKS *.au')
    assert_equal(msg_to_s(nil, 'LINKS', ['*.edu', '*.bu.edu']),
		 'LINKS *.edu *.bu.edu')
    assert_equal(msg_to_s(nil, 'TIME', ['tolsun.oulu.fi']),
		 'TIME tolsun.oulu.fi')
    assert_equal(msg_to_s(nil, 'CONNECT', ['tolsun.oulu.fi', '6667']),
		 'CONNECT tolsun.oulu.fi 6667')
    assert_equal(msg_to_s(nil, 'TRACE', ['*.oulu.fi']),
		 'TRACE *.oulu.fi')
    assert_equal(msg_to_s(nil, 'ADMIN', ['tolsun.oulu.fi']),
		 'ADMIN tolsun.oulu.fi')
    assert_equal(msg_to_s(nil, 'ADMIN', ['syrk']),
		 'ADMIN syrk')
    assert_equal(msg_to_s(nil, 'INFO', ['csd.bu.edu']),
		 'INFO csd.bu.edu')
    assert_equal(msg_to_s(nil, 'INFO', ['Angel']),
		 'INFO Angel')
    assert_equal(msg_to_s(nil, 'SQUERY', ['irchelp', 'HELP privmsg']),
		 'SQUERY irchelp :HELP privmsg')
    assert_equal(msg_to_s(nil, 'SQUERY', ['dict@irc.fr', 'fr2en blaireau']),
		 'SQUERY dict@irc.fr :fr2en blaireau')
    assert_equal(msg_to_s(nil, 'WHO', ['*.fi']),
		 'WHO *.fi')
    assert_equal(msg_to_s(nil, 'WHO', ['jto*', 'o']),
		 'WHO jto* o')
    assert_equal(msg_to_s(nil, 'WHOIS', ['wiz']),
		 'WHOIS wiz')
    assert_equal(msg_to_s(nil, 'WHOIS', ['eff.org', 'trillian']),
		 'WHOIS eff.org trillian')
    assert_equal(msg_to_s(nil, 'WHOWAS', ['Wiz']),
		 'WHOWAS Wiz')
    assert_equal(msg_to_s(nil, 'WHOWAS', ['Mermaid', '9']),
		 'WHOWAS Mermaid 9')
    assert_equal(msg_to_s(nil, 'WHOWAS', ['Trillian', '1', '*.edu']),
		 'WHOWAS Trillian 1 *.edu')
    assert_equal(msg_to_s(nil, 'PING', ['tolsun.oulu.fi']),
		 'PING tolsun.oulu.fi')
    assert_equal(msg_to_s(nil, 'PING', ['WiZ', 'tolsun.oulu.fi']),
		 'PING WiZ tolsun.oulu.fi')
    assert_equal(msg_to_s(nil, 'PING', ['irc.funet.fi']),
		 'PING irc.funet.fi') # 'PING :irc.funet.fi'
    assert_equal(msg_to_s(nil, 'PONG', ['csd.bu.edu', 'tolsun.oulu.fi']),
		 'PONG csd.bu.edu tolsun.oulu.fi')
    assert_equal(msg_to_s(nil, 'ERROR', ['Server *.fi already exists']),
		 'ERROR :Server *.fi already exists')
    assert_equal(msg_to_s(nil, 'AWAY', ['Gone to lunch.  Back in 5']),
		 'AWAY :Gone to lunch.  Back in 5')
    assert_equal(msg_to_s(nil, 'REHASH', []),
		 'REHASH')
    assert_equal(msg_to_s(nil, 'DIE', []),
		 'DIE')
    assert_equal(msg_to_s(nil, 'RESTART', []),
		 'RESTART')
    assert_equal(msg_to_s(nil, 'SUMMON', ['jto']),
		 'SUMMON jto')
    assert_equal(msg_to_s(nil, 'SUMMON', ['jto', 'tolsun.oulu.fi']),
		 'SUMMON jto tolsun.oulu.fi')
    assert_equal(msg_to_s(nil, 'USERS', ['eff.org']),
		 'USERS eff.org')
    assert_equal(msg_to_s('csd.bu.edu', 'WALLOPS', ['Connect \'*.uiuc.edu 6667\' from Joshua']),
		 ':csd.bu.edu WALLOPS :Connect \'*.uiuc.edu 6667\' from Joshua')
    assert_equal(msg_to_s(nil, 'USERHOST', ['Wiz', 'Michael', 'syrk']),
		 'USERHOST Wiz Michael syrk')
    assert_equal(msg_to_s('ircd.stealth.net', '302', ['yournick', 'syrk=+syrk@millennium.stealth.net']),
		 ':ircd.stealth.net 302 yournick syrk=+syrk@millennium.stealth.net') # ':ircd.stealth.net 302 yournick :syrk=+syrk@millennium.stealth.net')
    assert_equal(msg_to_s(nil, 'ISON', ['phone', 'trillian', 'WiZ', 'jarlek', 'Avalon', 'Angel', 'Monstah', 'syrk']),
		 'ISON phone trillian WiZ jarlek Avalon Angel Monstah syrk')
  end

  def test_s_new
    assert_equal([nil, 'NICK', ['Wiz']],
		 msg_to_a('NICK Wiz'))
    assert_equal(['WiZ!jto@tolsun.oulu.fi', 'NICK', ['Kilroy']],
		 msg_to_a(':WiZ!jto@tolsun.oulu.fi NICK Kilroy'))
    assert_equal([nil, 'USER', ['guest', '0', '*', 'Ronnie Reagan']],
		 msg_to_a('USER guest 0 * :Ronnie Reagan'))
    assert_equal([nil, 'USER', ['guest', '8', '*', 'Ronnie Reagan']],
		 msg_to_a('USER guest 8 * :Ronnie Reagan'))
    assert_equal([nil, 'OPER', ['foo', 'bar']],
		 msg_to_a('OPER foo bar'))
    assert_equal([nil, 'MODE', ['WiZ', '-w']],
		 msg_to_a('MODE WiZ -w'))
    assert_equal([nil, 'MODE', ['Angel', '+i']],
		 msg_to_a('MODE Angel +i'))
    assert_equal([nil, 'MODE', ['WiZ', '-o']],
		 msg_to_a('MODE WiZ -o'))
    assert_equal([nil, 'SERVICE', ['dict', '*', '*.fr', '0', '0', 'French Dictionary']],
		 msg_to_a('SERVICE dict * *.fr 0 0 :French Dictionary'))
    assert_equal([nil, 'QUIT', ['Gone to have lunch']],
		 msg_to_a('QUIT :Gone to have lunch'))
    assert_equal(['syrk!kalt@millennium.stealth.net', 'QUIT', ['Gone to have lunch']],
		 msg_to_a(':syrk!kalt@millennium.stealth.net QUIT :Gone to have lunch'))
    assert_equal([nil, 'SQUIT', ['tolsun.oulu.fi', 'Bad Link ?']],
		 msg_to_a('SQUIT tolsun.oulu.fi :Bad Link ?'))
    assert_equal(['Trillian', 'SQUIT', ['cm22.eng.umd.edu', 'Server out of control']],
		 msg_to_a(':Trillian SQUIT cm22.eng.umd.edu :Server out of control'))
    assert_equal([nil, 'JOIN', ['#foobar']],
		 msg_to_a('JOIN #foobar'))
    assert_equal([nil, 'JOIN', ['&foo', 'fubar']],
		 msg_to_a('JOIN &foo fubar'))
    assert_equal([nil, 'JOIN', ['#foo,&bar', 'fubar']],
		 msg_to_a('JOIN #foo,&bar fubar'))
    assert_equal([nil, 'JOIN', ['#foo,#bar', 'fubar,foobar']],
		 msg_to_a('JOIN #foo,#bar fubar,foobar'))
    assert_equal([nil, 'JOIN', ['#foo,#bar']],
		 msg_to_a('JOIN #foo,#bar'))
    assert_equal([nil, 'JOIN', ['0']],
		 msg_to_a('JOIN 0'))
    assert_equal(['WiZ!jto@tolsun.oulu.fi', 'JOIN', ['#Twilight_zone']],
		 msg_to_a(':WiZ!jto@tolsun.oulu.fi JOIN #Twilight_zone'))
    assert_equal([nil, 'PART', ['#twilight_zone']],
		 msg_to_a('PART #twilight_zone'))
    assert_equal([nil, 'PART', ['#oz-ops,&group5']],
		 msg_to_a('PART #oz-ops,&group5'))
    assert_equal(['WiZ!jto@tolsun.oulu.fi', 'PART', ['#playzone', 'I lost']],
		 msg_to_a(':WiZ!jto@tolsun.oulu.fi PART #playzone :I lost'))
    assert_equal([nil, 'MODE', ['#Finnish', '+imI', '*!*@*.fi']],
		 msg_to_a('MODE #Finnish +imI *!*@*.fi'))
    assert_equal([nil, 'MODE', ['#Finnish', '+o', 'Kilroy']],
		 msg_to_a('MODE #Finnish +o Kilroy'))
    assert_equal([nil, 'MODE', ['#Finnish', '+v', 'Wiz']],
		 msg_to_a('MODE #Finnish +v Wiz'))
    assert_equal([nil, 'MODE', ['#Fins', '-s']],
		 msg_to_a('MODE #Fins -s'))
    assert_equal([nil, 'MODE', ['#42', '+k', 'oulu']],
		 msg_to_a('MODE #42 +k oulu'))
    assert_equal([nil, 'MODE', ['#42', '-k', 'oulu']],
		 msg_to_a('MODE #42 -k oulu'))
    assert_equal([nil, 'MODE', ['#eu-opers', '+l', '10']],
		 msg_to_a('MODE #eu-opers +l 10'))
    assert_equal(['WiZ!jto@tolsun.oulu.fi', 'MODE', ['#eu-opers', '-l']],
		 msg_to_a(':WiZ!jto@tolsun.oulu.fi MODE #eu-opers -l'))
    assert_equal([nil, 'MODE', ['&oulu', '+b']],
		 msg_to_a('MODE &oulu +b'))
    assert_equal([nil, 'MODE', ['&oulu', '+b', '*!*@*']],
		 msg_to_a('MODE &oulu +b *!*@*'))
    assert_equal([nil, 'MODE', ['&oulu', '+b', '*!*@*.edu', '+e', '*!*@*.bu.edu']],
		 msg_to_a('MODE &oulu +b *!*@*.edu +e *!*@*.bu.edu'))
    assert_equal([nil, 'MODE', ['#meditation', 'e']],
		 msg_to_a('MODE #meditation e'))
    assert_equal([nil, 'MODE', ['#meditation', 'I']],
		 msg_to_a('MODE #meditation I'))
    assert_equal([nil, 'MODE', ['!12345ircd', 'O']],
		 msg_to_a('MODE !12345ircd O'))
    assert_equal(['WiZ!jto@tolsun.oulu.fi', 'TOPIC', ['#test', 'New topic']],
		 msg_to_a(':WiZ!jto@tolsun.oulu.fi TOPIC #test :New topic'))
    assert_equal([nil, 'TOPIC', ['#test', 'another topic']],
		 msg_to_a('TOPIC #test :another topic'))
    assert_equal([nil, 'TOPIC', ['#test', '']],
		 msg_to_a('TOPIC #test :'))
    assert_equal([nil, 'TOPIC', ['#test']],
		 msg_to_a('TOPIC #test'))
    assert_equal([nil, 'NAMES', ['#twilight_zone,#42']],
		 msg_to_a('NAMES #twilight_zone,#42'))
    assert_equal([nil, 'NAMES', []],
		 msg_to_a('NAMES'))
    assert_equal([nil, 'LIST', []],
		 msg_to_a('LIST'))
    assert_equal([nil, 'LIST', ['#twilight_zone,#42']],
		 msg_to_a('LIST #twilight_zone,#42'))
    assert_equal(['Angel!wings@irc.org', 'INVITE', ['Wiz', '#Dust']],
		 msg_to_a(':Angel!wings@irc.org INVITE Wiz #Dust'))
    assert_equal([nil, 'INVITE', ['Wiz', '#Twilight_Zone']],
		 msg_to_a('INVITE Wiz #Twilight_Zone'))
    assert_equal([nil, 'KICK', ['&Melbourne', 'Matthew']],
		 msg_to_a('KICK &Melbourne Matthew'))
    assert_equal([nil, 'KICK', ['#Finnish', 'John', 'Speaking English']],
		 msg_to_a('KICK #Finnish John :Speaking English'))
    assert_equal(['WiZ!jto@tolsun.oulu.fi', 'KICK', ['#Finnish', 'John']],
		 msg_to_a(':WiZ!jto@tolsun.oulu.fi KICK #Finnish John'))
    
    
    assert_equal(['Angel!wings@irc.org', 'PRIVMSG', ['Wiz', 'Are you receiving this message ?']],
		 msg_to_a(':Angel!wings@irc.org PRIVMSG Wiz :Are you receiving this message ?'))
		
		 
   	assert_equal(['lachie!n=lachie@203.22.16.243','PRIVMSG',['#ror_au','numbr5: ?f']],
   	  msg_to_a(':lachie!n=lachie@203.22.16.243 PRIVMSG #ror_au :numbr5: ?f'))
		assert_equal(['toolmantim!n=tlucas@mail.jobfutures.com.au','PRIVMSG',['#ror_au', 'why it not like me?']],
  		msg_to_a(':toolmantim!n=tlucas@mail.jobfutures.com.au PRIVMSG #ror_au :why it not like me?'))
  	
  	assert_equal(['snapper!i=jason@nat/yahoo/x-421af13bba199cc8','PRIVMSG',['#ror_au','numbr5: ?f']],
  		msg_to_a(':snapper!i=jason@nat/yahoo/x-421af13bba199cc8 PRIVMSG #ror_au :numbr5: ?f'))
		 
		 
    assert_equal([nil, 'PRIVMSG', ['Angel', 'yes I\'m receiving it !']],
		 msg_to_a('PRIVMSG Angel :yes I\'m receiving it !'))
    assert_equal([nil, 'PRIVMSG', ['jto@tolsun.oulu.fi', 'Hello !']],
		 msg_to_a('PRIVMSG jto@tolsun.oulu.fi :Hello !'))
    assert_equal([nil, 'PRIVMSG', ['kalt%millennium.stealth.net@irc.stealth.net', 'Are you a frog?']],
		 msg_to_a('PRIVMSG kalt%millennium.stealth.net@irc.stealth.net :Are you a frog?'))
    assert_equal([nil, 'PRIVMSG', ['kalt%millennium.stealth.net', 'Do you like cheese?']],
		 msg_to_a('PRIVMSG kalt%millennium.stealth.net :Do you like cheese?'))
    assert_equal([nil, 'PRIVMSG', ['Wiz!jto@tolsun.oulu.fi', 'Hello !']],
		 msg_to_a('PRIVMSG Wiz!jto@tolsun.oulu.fi :Hello !'))
    assert_equal([nil, 'PRIVMSG', ['$*.fi', 'Server tolsun.oulu.fi rebooting.']],
		 msg_to_a('PRIVMSG $*.fi :Server tolsun.oulu.fi rebooting.'))
    assert_equal([nil, 'PRIVMSG', ['#*.edu', 'NSFNet is undergoing work, expect interruptions']],
		 msg_to_a('PRIVMSG #*.edu :NSFNet is undergoing work, expect interruptions'))
    assert_equal([nil, 'VERSION', ['tolsun.oulu.fi']],
		 msg_to_a('VERSION tolsun.oulu.fi'))
    assert_equal([nil, 'STATS', []],
		 msg_to_a('STATS'))
    assert_equal([nil, 'LINKS', ['*.au']],
		 msg_to_a('LINKS *.au'))
    assert_equal([nil, 'LINKS', ['*.edu', '*.bu.edu']],
		 msg_to_a('LINKS *.edu *.bu.edu'))
    assert_equal([nil, 'TIME', ['tolsun.oulu.fi']],
		 msg_to_a('TIME tolsun.oulu.fi'))
    assert_equal([nil, 'CONNECT', ['tolsun.oulu.fi', '6667']],
		 msg_to_a('CONNECT tolsun.oulu.fi 6667'))
    assert_equal([nil, 'TRACE', ['*.oulu.fi']],
		 msg_to_a('TRACE *.oulu.fi'))
    assert_equal([nil, 'ADMIN', ['tolsun.oulu.fi']],
		 msg_to_a('ADMIN tolsun.oulu.fi'))
    assert_equal([nil, 'ADMIN', ['syrk']],
		 msg_to_a('ADMIN syrk'))
    assert_equal([nil, 'INFO', ['csd.bu.edu']],
		 msg_to_a('INFO csd.bu.edu'))
    assert_equal([nil, 'INFO', ['Angel']],
		 msg_to_a('INFO Angel'))
    assert_equal([nil, 'SQUERY', ['irchelp', 'HELP privmsg']],
		 msg_to_a('SQUERY irchelp :HELP privmsg'))
    assert_equal([nil, 'SQUERY', ['dict@irc.fr', 'fr2en blaireau']],
		 msg_to_a('SQUERY dict@irc.fr :fr2en blaireau'))
    assert_equal([nil, 'WHO', ['*.fi']],
		 msg_to_a('WHO *.fi'))
    assert_equal([nil, 'WHO', ['jto*', 'o']],
		 msg_to_a('WHO jto* o'))
    assert_equal([nil, 'WHOIS', ['wiz']],
		 msg_to_a('WHOIS wiz'))
    assert_equal([nil, 'WHOIS', ['eff.org', 'trillian']],
		 msg_to_a('WHOIS eff.org trillian'))
    assert_equal([nil, 'WHOWAS', ['Wiz']],
		 msg_to_a('WHOWAS Wiz'))
    assert_equal([nil, 'WHOWAS', ['Mermaid', '9']],
		 msg_to_a('WHOWAS Mermaid 9'))
    assert_equal([nil, 'WHOWAS', ['Trillian', '1', '*.edu']],
		 msg_to_a('WHOWAS Trillian 1 *.edu'))
    assert_equal([nil, 'PING', ['tolsun.oulu.fi']],
		 msg_to_a('PING tolsun.oulu.fi'))
    assert_equal([nil, 'PING', ['WiZ', 'tolsun.oulu.fi']],
		 msg_to_a('PING WiZ tolsun.oulu.fi'))
    assert_equal([nil, 'PING', ['irc.funet.fi']],
		 msg_to_a('PING :irc.funet.fi'))
    assert_equal([nil, 'PONG', ['csd.bu.edu', 'tolsun.oulu.fi']],
		 msg_to_a('PONG csd.bu.edu tolsun.oulu.fi'))
    assert_equal([nil, 'ERROR', ['Server *.fi already exists']],
		 msg_to_a('ERROR :Server *.fi already exists'))
    assert_equal([nil, 'AWAY', ['Gone to lunch.  Back in 5']],
		 msg_to_a('AWAY :Gone to lunch.  Back in 5'))
    assert_equal([nil, 'REHASH', []],
		 msg_to_a('REHASH'))
    assert_equal([nil, 'DIE', []],
		 msg_to_a('DIE'))
    assert_equal([nil, 'RESTART', []],
		 msg_to_a('RESTART'))
    assert_equal([nil, 'SUMMON', ['jto']],
		 msg_to_a('SUMMON jto'))
    assert_equal([nil, 'SUMMON', ['jto', 'tolsun.oulu.fi']],
		 msg_to_a('SUMMON jto tolsun.oulu.fi'))
    assert_equal([nil, 'USERS', ['eff.org']],
		 msg_to_a('USERS eff.org'))
    assert_equal(['csd.bu.edu', 'WALLOPS', ['Connect \'*.uiuc.edu 6667\' from Joshua']],
		 msg_to_a(':csd.bu.edu WALLOPS :Connect \'*.uiuc.edu 6667\' from Joshua'))
    assert_equal([nil, 'USERHOST', ['Wiz', 'Michael', 'syrk']],
		 msg_to_a('USERHOST Wiz Michael syrk'))
    assert_equal(['ircd.stealth.net', '302', ['yournick', 'syrk=+syrk@millennium.stealth.net']],
		 msg_to_a(':ircd.stealth.net 302 yournick :syrk=+syrk@millennium.stealth.net'))
    assert_equal([nil, 'ISON', ['phone', 'trillian', 'WiZ', 'jarlek', 'Avalon', 'Angel', 'Monstah', 'syrk']],
		 msg_to_a('ISON phone trillian WiZ jarlek Avalon Angel Monstah syrk'))

    assert_equal(['ay3!akira@qp.arika.org', 'NICK', ['ay2']],
		 msg_to_a(':ay3!akira@qp.arika.org NICK :ay2'))
  end
end

if $0 == __FILE__
  if ARGV.size == 0
    suite = TestRICE__Message.suite
  else
    suite = RUNIT::TestSuite.new
    ARGV.each do |testmethod|
      suite.add_test(TestRICE__Message.new(testmethod))
    end
  end
  RUNIT::CUI::TestRunner.run(suite)
end
