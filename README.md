# ipip-erlang
Erlang lib for 17monipdb.dat(http://www.ipip.net/download.html)  
```
find(Ip) -> {ok, Country, Provine, City} | false
    Types:
        Ip = binary()|string()|tuple()
        Country = binary()
        Provine = binary()
        City = binary()
Return location info of Ip which is IPv4 format if it existes, or 'false'.
```

# How To Use
```shell
$ make   
$ erl -pa ebin   
1> ipip:test("219.137.144.1").  
Ip:"219.137.144.1" -> Country: 中国 Province: 广东 City: 广州  
ok

2> ipip:find("219.137.144.1").  
{ok,<<228,184,173,229,155,189>>, <<229,185,191,228,184,156>>, <<229,185,191,229,183,158>>}
```
# Thank
[erlang-ip](https://github.com/kqqsysu/erlang-ip)
