// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract setMultipleBet{
    // market za pitanja sa vise odgovora
    address payable betCreator;
    uint dateOfResolve = 250; // pogledaj manipulaciju sa datumima
    //uint disputePredictionTime = 5 * 1 days; // vreme koje korisnici imaju da pokazu da neko resenje nije dobro
    uint disputePredictionTime = 50; 
    uint endDispute; // ako se do ovog trenutka ne dogovore, trziste postaje invalid
    uint endTime; // vreme do kog traje trziste
    //uint setTentativeWinningOutcomeTime = endTime + 3 * 1 days; // vreme za koje designated reporter treba da postavi
    uint setTentativeWinningOutcomeTime = 100;
    // tacan odgovor
    string public myPrediction; //predvidjanje na koje kreator stavlja rep, posto je da/ne
    string category; //kategorija kojoj pripada pitanje, sport, ...
    string tags; // tagovi, ovo mozda i izbacim
    address designetedReporter; // adresa koja po isteku opklade treba da prijavi rezultat
    string additionalDetails;    //pokazuje na kom sajtu ce biti objavljena resenja
    uint creatorFee; // koliko je fee ako trziste prodje kao invalid
    uint initialLiquidity; // ako se ne postavi, filtrira se kao invalid odmah od samog augura
    bool public betFinished;
    enum Vote {ANSWER1, ANSWER2, ANSWER3, ANSWER4, INVALID}
    string answer_1;
    string answer_2;
    string answer_3;
    string answer_4;
    uint numberOfAnswers;
    bool TWOset = false;
    Vote TentativeWinningOutcome;
    Vote OldTentativeWinningOutcome; // ako se promeni odgovor, zadrzava se prethodni
    uint predictionMarketFinished = 0;
    uint round = 0; // runda za koju se opovrgava predlozeno tacno resenje
    uint threshold; // ako se dostigne ova granica, treba da se forkuje program
    uint roundLimit = 10*10**18; // limit novca da se postavi novo resenje kao tacno
    //neka na pocetku to bude 5 eth
    string predictionOutcome;
    uint noShowBond; //zalog da ce designeted reporter da prijavi ispravno resenje
    uint validityBond; //zalog da ce outcome biti validan
    mapping(Vote => uint) public listOfBets; // pokazuje koliko je novca na svaki odgovor stavljeno
    //mapping(address => mapping(Vote => uint)) public listOfParticipans; // prestavlja listu ucesnika i kolicinu novca koju su ulozili
    mapping(Vote => uint) public listOfREPBets; // pokazuje koliko rep novca je stavljeno 
    mapping(address => mapping(Vote => uint)) public listOfREPreporters; // ljudi koji donose odluku koji odgovor je tacan
    mapping(address => mapping(Vote => uint)) public listOfREPreportersRound; 
    struct betting{ 
    Vote prediction;
    uint sheres;
    uint numberOfEthar;
    bool hasOpponent;
    }
    struct selling{
        Vote prediction;
        uint sheres;
        uint sellingPrice;
    }
    uint betsFor;
    uint betsAgainst;
    uint allBets;
    mapping(address => betting) public ledgerBookBuy;
    mapping(address => betting) public ledgerBookSell;
    mapping(address => selling) public ledgerBookSelles;
    mapping(address => selling) public ledgerBookSettlment;
    uint disputeTime = 50;

    function setPredictionMarket(string memory  prediction, string memory Category, string memory Tags,
     uint numberOfDays, string memory AdditionalDetails, uint CreatorFee, string memory _vote1,
    string memory _vote2, string memory _vote3, string memory _vote4, uint numOfAnswers) external{
        //potrebno je da sva polja budu ispravno popunjena, to u javascriptu se proverava
        //market creator je i designated reporter jer ljudi u najvecem broju slucaja
        //stavljaju sebe
        betCreator=msg.sender;
        designetedReporter = msg.sender;
        myPrediction = prediction;
        category = Category;
        tags = Tags;
        //ovo kad zavrsim sve provere
        //endTime = block.timestamp + (numberOfDays * 1 days);
        //ovo dok radim provere
        endTime = numberOfDays;
        additionalDetails = AdditionalDetails;
        //treba da bude broj izmedju 0 i 5
        // broj * 1000 / creatorFee
        creatorFee = CreatorFee;
        answer_1 = _vote1;
        answer_2 = _vote2;
        answer_3 = _vote3;
        answer_4 = _vote4;
        numberOfAnswers = numOfAnswers;
    }
    function readPrediction() public view returns (string memory) {
        return myPrediction;
    }
    function getCreator() public view returns(address){
        return betCreator;
    }
    function getCategory() public view returns(string memory){
        return category;
    }
    function getTags() public view returns(string memory){
        return tags;
    }
    function getEndTime() public view returns(uint){
        return endTime;
    }
    function getAdditionalDetails() public view returns(string memory){
        return additionalDetails;
    }
    function getCreatorFee() public view returns(uint){
        return creatorFee;
    }
    function setInitialLiquidity(Vote _vote, uint shere, uint forAgainst) public payable{
        require(msg.sender == betCreator, 'Only market creator can set liquidity');
        require(msg.value > 0, 'No money set for liquidity');
        initialLiquidity = msg.value;
        if(forAgainst == 0){
            ledgerBookBuy[msg.sender].prediction = _vote;
            ledgerBookBuy[msg.sender].sheres = shere;
            ledgerBookBuy[msg.sender].numberOfEthar = msg.value;
            ledgerBookBuy[msg.sender].hasOpponent = false;
            betsFor += msg.value;
            allBets += msg.value;
        }
        else if(forAgainst == 1){
            ledgerBookSell[msg.sender].prediction = _vote;
            ledgerBookSell[msg.sender].sheres = shere;
            ledgerBookSell[msg.sender].numberOfEthar = msg.value;
            ledgerBookSell[msg.sender].hasOpponent = false;
            betsAgainst += msg.value;
            allBets += msg.value;
        }
    }
    //koristi se external, a ne public, jer public trosi vise gasa
    function setParticipantBetBuy(uint Shares, uint timeNow, Vote _vote) external payable{ 
        //require(betFinished == false, "Voting is over");
        require(timeNow < endTime, 'You have time to set bet');
        ledgerBookBuy[msg.sender].prediction = _vote; 
        ledgerBookBuy[msg.sender].sheres = Shares; 
        ledgerBookBuy[msg.sender].numberOfEthar = msg.value;
        ledgerBookBuy[msg.sender].hasOpponent= false;

        betsFor += msg.value;
        allBets += msg.value;
        //upisao korisnika u knjigu, koliko deonica zeli, po kojoj ceni,
        //kada na ovaj nacin korisnik upise u knjigu, on nema protivnika
    }
    // function getParticipantBetBuy() public view returns(uint){
    //     return ledgerBookBuy[msg.sender].sheres;
    // }
    // function getBetsFor() public view returns(uint){
    //     return betsFor;
    // }
    function setParticipantBetSell(uint Shares, uint timeNow, Vote _vote) external payable{ 
        //require(betFinished == false, "Voting is over");
        require(timeNow < endTime, 'You have time to set bet');
        ledgerBookSell[msg.sender].prediction = _vote; 
        ledgerBookSell[msg.sender].sheres = Shares; 
        ledgerBookSell[msg.sender].numberOfEthar = msg.value;
        ledgerBookSell[msg.sender].hasOpponent= false;

        betsAgainst += msg.value;
        allBets += msg.value;
    }
    // function getParticipantBetSell() public view returns(uint){
    //     return ledgerBookSell[msg.sender].sheres;
    // }
    //protivnik se slaze sa opkladom,
    //ja se ne slazem sa opkladom
    function setParticipantBetOpponentBuy(address _opponent, uint shere, uint timeNow, Vote _vote) external payable{ 
        //require(betFinished == false, "Voting is over");
        require(timeNow < endTime, 'Time for betting is over');
        require(ledgerBookBuy[_opponent].prediction == _vote, 'Dont have samo prediction');
        ledgerBookBuy[_opponent].hasOpponent = true;
        ledgerBookSell[msg.sender].prediction = _vote; 
        ledgerBookSell[msg.sender].sheres = shere; 
        ledgerBookSell[msg.sender].numberOfEthar = msg.value;
        ledgerBookSell[msg.sender].hasOpponent= true;
        betsAgainst += msg.value;
        allBets += msg.value;
        // namesteno da postoji opklada izmedju
        // dva korisnika
        // ko pobedi osvaja novac, ko izgubi gubi novac
    }
    //ja se slazem sa opkladom
    //protivnik se ne slaze
    function setParticipantBetOpponentSell(address _opponent, uint shere, uint timeNow, Vote _vote) external payable{ 
        //require(betFinished == false, "Voting is over");
        require(timeNow < endTime, 'Time for betting is over');
        require(ledgerBookSell[_opponent].prediction == _vote, 'Dont have samo prediction');
        ledgerBookSell[_opponent].hasOpponent = true; 
        ledgerBookBuy[msg.sender].prediction = _vote; 
        ledgerBookBuy[msg.sender].sheres = shere; 
        ledgerBookBuy[msg.sender].numberOfEthar = msg.value;
        ledgerBookBuy[msg.sender].hasOpponent= true;
        betsFor += msg.value;
        allBets = msg.value;
    }
    // funkcija za prikaz podataka ako zelim da prodam deonice
    function setToSellBuy(uint sheres, uint sellingPrice, Vote _vote) external{
        require(ledgerBookBuy[msg.sender].sheres >= sheres, "You dont own that much sheres");
        require(ledgerBookBuy[msg.sender].hasOpponent == true, "You don't have opponent");
        ledgerBookSelles[msg.sender].prediction = _vote; 
        ledgerBookSelles[msg.sender].sheres = sheres;
        ledgerBookSelles[msg.sender].sellingPrice = sellingPrice;
    }
    // function getsetToSellBuy() public view returns(uint){
    //     return  ledgerBookSelles[msg.sender].sellingPrice;
    // }
    function setToSellSell(uint sheres, uint sellingPrice, Vote _vote) external{
        require(betFinished == false, "Voting is over");
        require(ledgerBookSell[msg.sender].sheres >= sheres, "You dont own that much sheres");
        require(ledgerBookSell[msg.sender].hasOpponent == true, "You don't have opponent");
         ledgerBookSelles[msg.sender].prediction = _vote; 
        ledgerBookSelles[msg.sender].sheres = sheres;
        ledgerBookSelles[msg.sender].sellingPrice = sellingPrice;
    }
    function buySomeonesBuyBet(address payable _seller, Vote _vote) external payable{ 
        //require(betFinished == false, "Voting is over");
            require(ledgerBookSell[msg.sender].prediction == _vote, "You don't have the same answer");
           ledgerBookBuy[msg.sender].sheres = ledgerBookBuy[msg.sender].sheres + ledgerBookSelles[_seller].sheres;
           ledgerBookBuy[_seller].sheres =  ledgerBookBuy[_seller].sheres - ledgerBookSelles[_seller].sheres;
           ledgerBookBuy[msg.sender].hasOpponent = ledgerBookBuy[_seller].hasOpponent; 
           _seller.transfer(msg.value);
           //kako ga izvrisati sa liste
           ledgerBookSelles[_seller].sheres = 0;
           ledgerBookSelles[_seller].sellingPrice = 0;
    }
       function buySomeonesBuySell(address payable _seller, Vote _vote) external payable{ 
        //require(betFinished == false, "Voting is over");
           require(ledgerBookSell[msg.sender].prediction == _vote, "You don't have the same answer");
           ledgerBookSell[msg.sender].sheres = ledgerBookSell[msg.sender].sheres + ledgerBookSelles[_seller].sheres;
           ledgerBookSell[_seller].sheres = ledgerBookSell[_seller].sheres - ledgerBookSelles[_seller].sheres;
           ledgerBookSell[msg.sender].hasOpponent = ledgerBookSell[_seller].hasOpponent;
           _seller.transfer(msg.value);
           ledgerBookSelles[_seller].sheres = 0;
           ledgerBookSelles[_seller].sellingPrice = 0;
    }
    function setValidityBond() external payable{ 
        // validity bond, kreator placa odredjenu svotu novca
        // dobija je nazad ako je outcome valid
         require(betCreator == msg.sender, 'You are not bet creator');
         require(msg.value == 5 * 10**18, 'Price should be 5 eth');
         validityBond = msg.value;
    }
    function getValidityBond(uint timeNow) public payable returns (uint) { 
        // funkcija koja vraca novac creatoru ako
        // je outcome validan
        //require(betFinished == true, "Voting is over");
        require(betCreator == msg.sender, 'You are not bet creator');
        require(endTime < timeNow, 'Bet is not over yet');
        require(TentativeWinningOutcome != Vote.INVALID, 'Bet is invalid');
        require(predictionMarketFinished == 1, 'Prediction market outcome is not decided');
        msg.sender.transfer(validityBond);
    }
    function setNoShowBond() external payable{ 
         require(betCreator == msg.sender);
         require(msg.value == 3 * 10**18, 'Price should be 3 eth');
         noShowBond = msg.value;
    }
    function setTentativeWinningOutcome(Vote _vote, uint timeNow) external payable{ 
        //kreator treba da postavi ko je pobedio 
        //i za to ima 3 dana
        require(timeNow > endTime, 'Market time is not closed');
        require(timeNow < endTime + setTentativeWinningOutcomeTime, 'You didnt report on time');
        require(msg.sender == designetedReporter, "Wrong designeted reporter");
        require(TWOset == false, "Tentative winning outcome is set");
        //ako je proslo tri dana, gubi se rep koji je postavio creator trzista
        TentativeWinningOutcome = _vote;
        TWOset = true;
        //salje mu se no show bond
        msg.sender.transfer(noShowBond);
    }
    // ako prodje odredjen period i nije postavljen rezultat prva 
    // osoba koja prijavi rezultat ce dobiti noShowBond
    // 
    function setTentativeWinningOutcomeOpenReporter(Vote _vote, uint timeNow) external {  
        require(timeNow > endTime + setTentativeWinningOutcomeTime, 'Designeted reported has time to report');
        require(TWOset == false, "Tentative outcome is already set");
        //ako je proslo tri dana, gubi se rep koji je postavio creator trzista
        TentativeWinningOutcome = _vote;
        TWOset = true;
        msg.sender.transfer(noShowBond);
    } 
    // function getTentativeWinningOutcome() public view returns (Vote) { 
    //     // funkcija koja prikazuje ko je pobednik
    //     return TentativeWinningOutcome;
    // }
    function disputePredictionOutcame(Vote _vote, uint timeNow) external payable{  
        //pobednik je ko ima vise novca u ovoj listi
        require(timeNow > endTime + setTentativeWinningOutcomeTime + disputePredictionTime*round, 'Dispute time did not started yet');
        require(timeNow < endTime + setTentativeWinningOutcomeTime + disputePredictionTime*(round+1) + disputeTime, 'Dispute round has finished');
        //korisnik moze da ulozi izmedju 
        // 5 i 10 eth u prvoj rundi
        // u svakoj sledecoj moze + 5 eth
        require(msg.value > 5*10**18 + 5*10**18*round, "Min amount is not acquired");
        require(msg.value < 10*10**18 + 10*10**18*round, "Max amount is exceeded");
        //require(listOfREPBets[ _vote] > threshold, "Threshold is reached");
        listOfREPBets[ _vote] += msg.value;   // globalna lista opklada
        listOfREPreporters[msg.sender] [_vote] += msg.value; // pojedinacna lista opklada
        listOfREPreportersRound[msg.sender] [_vote] = msg.value;
        if(listOfREPBets[ _vote] > roundLimit){
            round = round + 1;
            roundLimit = 2*roundLimit;
            OldTentativeWinningOutcome = TentativeWinningOutcome;
            TentativeWinningOutcome = _vote;
        }
        if(round == 3){
            //trziste je invalid ako
            //ne mogu da se dogovore oko odgovora
            TentativeWinningOutcome = Vote.INVALID;
        }
    }
    // function checkDisputedMoney(Vote _vote) public view returns (uint) { 
    //     return listOfREPreportersRound[msg.sender] [_vote];
    // }
        function returnDisputeEther(uint timeNow, Vote _vote) external payable{  
        //ako vreme prodje i ne dodje do disputa
        //vraca se novac svim ucesnicima
        require(timeNow > endTime + setTentativeWinningOutcomeTime + disputePredictionTime*(round+1), 'Dispute round didnt finish');
        require(timeNow < endTime + setTentativeWinningOutcomeTime + disputePredictionTime*(round+1)+disputeTime, 'Payback time is finished');
        require(OldTentativeWinningOutcome != TentativeWinningOutcome, 'Dispute didnt happened');
        require(round < 3, 'Market is invalid');
        listOfREPreporters[msg.sender] [_vote] -= listOfREPreportersRound[msg.sender] [_vote];
        listOfREPBets[ _vote] -= listOfREPreportersRound[msg.sender] [_vote]; 
        msg.sender.transfer(listOfREPreportersRound[msg.sender] [_vote]);
        }
        function rewardCorrectDispute(uint timeNow, Vote _wrongVote1, Vote _wrongVote2,
        Vote _wrongVote3, Vote _wrongVote4) external payable{  
        //ako se postavi pravo resenje
        //svim ucesnicima koji su glasali za pravo resenje 
        //treba da se prosledi novac
        require(timeNow > setTentativeWinningOutcomeTime + disputePredictionTime*(round+1)+disputeTime, 'Dispute round didnt finish');
        require(OldTentativeWinningOutcome != TentativeWinningOutcome, 'Dispute didnt happened');
        require(TentativeWinningOutcome != _wrongVote1, 'Vote is not incorrect');
        require(TentativeWinningOutcome != _wrongVote2, 'Vote is not incorrect');
        require(TentativeWinningOutcome != _wrongVote3, 'Vote is not incorrect');
        require(TentativeWinningOutcome != _wrongVote4, 'Vote is not incorrect');
        require(round <= 3, 'Market is not invalid');
        uint reward = listOfREPreporters[msg.sender] [TentativeWinningOutcome];
        //korisnik dobija nazad ether koji je ulozio
        //i deo od ethera od korisnika koji su glasali za druga resenja
        uint wholeReward = reward + listOfREPBets[_wrongVote1] * (reward /listOfREPBets[TentativeWinningOutcome]) +
        listOfREPBets[_wrongVote2] * (reward/listOfREPBets[TentativeWinningOutcome]) +
        listOfREPBets[_wrongVote3] * (reward/listOfREPBets[TentativeWinningOutcome]) +
        listOfREPBets[_wrongVote4] * (reward/listOfREPBets[TentativeWinningOutcome]);
        msg.sender.transfer(wholeReward);
        listOfREPreporters[msg.sender] [TentativeWinningOutcome] = 0;
        }
    function getWinningPrize(uint timeNow, uint forAgainst) external{
       // require(timeNow >  endTime + setTentativeWinningOutcomeTime + disputePredictionTime*(round+1)+disputeTime, 'Dispute round didnt finish');
        //nakon sto se zavrsi dispute runda
        //treba da se saceka jos jedan period pre nego sto krene da se dodeljuje novac
        require(timeNow > endTime + setTentativeWinningOutcomeTime + disputePredictionTime*(round+1) + disputeTime + dateOfResolve, 'Date of resolve didnt star yet');
         if(TentativeWinningOutcome == Vote.INVALID){
            if((ledgerBookSell[msg.sender].sheres > 0) && (ledgerBookSell[msg.sender].hasOpponent == true)){
            uint winningEther = (ledgerBookSell[msg.sender].sheres/ numberOfAnswers) * 10**18 ;
            uint creatorFeeEth = (winningEther/100)*creatorFee;
            uint receivingEth = winningEther - creatorFeeEth;
            msg.sender.transfer(receivingEth);
            betCreator.transfer(creatorFeeEth);
            allBets -= winningEther;
            ledgerBookSell[msg.sender].sheres = 0; 
            ledgerBookSell[msg.sender].numberOfEthar = 0;
            ledgerBookSell[msg.sender].hasOpponent= false;
            }
            else if((ledgerBookBuy[msg.sender].sheres > 0) && (ledgerBookBuy[msg.sender].hasOpponent == true)){
            uint winningEther = (ledgerBookBuy[msg.sender].sheres/numberOfAnswers) * 10**18 ;
            uint creatorFeeEth = (winningEther/100)*creatorFee;
            uint receivingEth = winningEther - creatorFeeEth;
            msg.sender.transfer(receivingEth);
            betCreator.transfer(creatorFeeEth);
            allBets -= winningEther;
            ledgerBookBuy[msg.sender].sheres = 0; 
            ledgerBookBuy[msg.sender].numberOfEthar = 0;
            ledgerBookBuy[msg.sender].hasOpponent= false;
            }
         }
        else if(TentativeWinningOutcome == ledgerBookBuy[msg.sender].prediction && forAgainst == 0){
            // && (ledgerBookBuy[msg.sender].hasOpponent == true)
            if((ledgerBookBuy[msg.sender].sheres > 0)){
            uint numOfSheres = ledgerBookBuy[msg.sender].sheres;
            uint winningEther = numOfSheres * 10**18;
            uint creatorFeeEth = (winningEther/100)*creatorFee;
            uint receivingEth = winningEther - creatorFeeEth;
            if(ledgerBookBuy[msg.sender].hasOpponent == false){
                 receivingEth = ledgerBookBuy[msg.sender].numberOfEthar;
            }
            msg.sender.transfer(winningEther);
            //msg.sender.transfer(receivingEth);
            betCreator.transfer(creatorFeeEth);
            allBets -= winningEther;
            ledgerBookBuy[msg.sender].sheres = 0; 
            ledgerBookBuy[msg.sender].numberOfEthar = 0;
            ledgerBookBuy[msg.sender].hasOpponent = false;
            }
        }
        else if(TentativeWinningOutcome == ledgerBookSell[msg.sender].prediction && forAgainst == 1){
            //&& (ledgerBookSell[msg.sender].hasOpponent == true)
            if((ledgerBookSell[msg.sender].sheres > 0)){
            uint winningEther = ledgerBookSell[msg.sender].sheres * 10**18;
            uint creatorFeeEth = (winningEther/100)*creatorFee;
            uint receivingEth = winningEther - creatorFeeEth;
            if(ledgerBookSell[msg.sender].hasOpponent == false){
                 receivingEth = ledgerBookSell[msg.sender].numberOfEthar;
            }
            msg.sender.transfer(receivingEth);
            betCreator.transfer(creatorFeeEth);
            allBets -= winningEther;
            ledgerBookSell[msg.sender].sheres = 0; 
            ledgerBookSell[msg.sender].numberOfEthar = 0;
            ledgerBookSell[msg.sender].hasOpponent= false;
            }
        }
        }
}