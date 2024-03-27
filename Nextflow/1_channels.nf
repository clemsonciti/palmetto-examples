//Example of branching and setting operators

Channel.of(500,700,"tigers","this",1001,1235)
        .branch{
                nan : it == "this"
                nan2: it == "tigers"
                num : it < 1000
                num2: it > 1000 }
        .set {result}

result.nan.view {"$it is not a number"}
result.num.view {"$it is a number less than 1000"}
result.nan2.view{"$it is not a number"}
result.num2.view{"$it is a number Greater than 1000"}

//Example of mathmatical operators on channels
Channel.of(132508,2359730,3285908392085,320,0.333,0.3532432,23430.3)
        .sum().set{result2}

result2.view {"The sum of the channel is $it"}

Channel.of(132508,2359730,3285908392085,320,0.333,0.3532432,23430.3)
        .max()
        .view{"Max value : $it"}

//Example of join operator
primary_ch = Channel.of(['Tigers',1],['Clemson',1889],['CCIT',1000],['CAFLS',1893])
secondary_ch = Channel.of(['Tigers',5],['Clemson',2018],['CAFLS',2018])
primary_ch.join(secondary_ch).view()

//Example of distinct operator]
repeat_ch = Channel.of('Go','Go','Go','Tigers','Tigers','Tigers','win!','win!','win!','Go','Go','Tigers','Tigers')
repeat_ch.distinct().view()

//Example of randomSample
Channel.of(1..1000)
        .randomSample(10, 234)
        .view()

//Example of randomSample
Channel.of(1..1000)
        .randomSample(10, 234)
        .view()
