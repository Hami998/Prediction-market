var predictionMarketMultipleChoice = artifacts.require('setMultipleBet');

contract('predictionMarketMultipleChoice', addresses => {
    const [creator, better1, better2, better3, better4, better5, _] = addresses;
       const Vote = {
            ANSWER1: 0,
            ANSWER2: 1,
            ANSWER3: 2,
            ANSWER4: 3,
            INVALID: 4
        }
    it('multiple choice prediction market worked', async () => {

        const PredictionMarketMultipleChoice = await predictionMarketMultipleChoice.new();

        await PredictionMarketMultipleChoice.setPredictionMarket("Who will win Wimbledon?", 'Sport', 'Tennis',
        100, 'Novak == answer 1, Roger == number 2, Berettini == number 3, Khachanov == number 4',
        1,'Novak Djokovic','Roger Federer','Matteo Berrettini','Karen Khachanov', 4, {from: creator});

        await PredictionMarketMultipleChoice.setValidityBond({from: creator, value:  web3.utils.toWei('5')});
        await PredictionMarketMultipleChoice.setNoShowBond({from: creator, value:  web3.utils.toWei('3')});

        //provera da li je unos za trziste predvidjanja dobar
        var check = await PredictionMarketMultipleChoice.readPrediction();
        assert(check === 'Who will win Wimbledon?', "Prediction input is not correct");
        var check1 = await PredictionMarketMultipleChoice.getCategory();
        assert(check1 === 'Sport', "Category is not correct");
        var check2 = await PredictionMarketMultipleChoice.getTags();
        assert(check2 === 'Tennis', "Tag is not correct");
        var check3 = await PredictionMarketMultipleChoice.getEndTime();
        assert(check3 == 100, "End time of prediction is not correct");
        var check4 = await PredictionMarketMultipleChoice.getAdditionalDetails();
        assert(check4 === 'Novak == answer 1, Roger == number 2, Berettini == number 3, Khachanov == number 4');
        var check5 = await PredictionMarketMultipleChoice.getCreatorFee();
        assert(check5 == 1, "Creator fee is not correct");
        var check6 = await PredictionMarketMultipleChoice.getCreator();
        assert(check6 === creator, "Market creator is not correct");

        //opciono, da se postavi likvidnost
        //toWei sheres je pomnozen sa etherom koji se salje
       await PredictionMarketMultipleChoice.setInitialLiquidity(Vote.ANSWER1, 5, 0, {from: creator, value:  web3.utils.toWei('5')});

        // var check7 = await PredictionMarket.getParticipantBetBuy({from: creator});
        // assert(check7 == 5, "Market liquidity is not correct");

        //provera da li ima dovoljno novca u ugovoru
        // var check7 = await PredictionMarket.getBetsFor();
        // const ether1 = web3.utils.fromWei(check7, 'ether');
        // assert(ether1 === '5', "Bets for yes are not correct");

        await PredictionMarketMultipleChoice.setParticipantBetBuy(10, 15, Vote.ANSWER1, {from: better1, value: web3.utils.toWei('7')}); //0.70
        await PredictionMarketMultipleChoice.setParticipantBetSell(15, 25,Vote.ANSWER2, {from: better3, value: web3.utils.toWei('6')}); //0.40
        
        
        // var check8 = await PredictionMarket.getParticipantBetBuy({from: better1});
        // assert(check8 == 10, "Better 1 number of sheres is not correct");
        // var check9 = await PredictionMarket.getParticipantBetSell({from: better3});
        // assert(check9 == 15, "Better 3 number of sheres is not correct");

        //kadad korisnik dobije protivnika, opklade pocinju
        await PredictionMarketMultipleChoice.setParticipantBetOpponentBuy(better1, 10, 32, Vote.ANSWER1, {from: better2, value: web3.utils.toWei('3')}); //0.30
        await PredictionMarketMultipleChoice.setParticipantBetOpponentSell(better3, 15, 38, Vote.ANSWER2, {from: better4, value: web3.utils.toWei('9')}); //0.60 
        

        await PredictionMarketMultipleChoice.setToSellBuy(5, 80, Vote.ANSWER1, {from: better1});

        //provera po kojoj ceni korisnik zeli da kupi ili proda deonice
        // var check10 = await PredictionMarket.getSetToSellBuy({from: better1});
        // assert(check10 == 80, "Selling price is not correct");


        await PredictionMarketMultipleChoice.buySomeonesBuyBet(better1, Vote.ANSWER1, {from: better5, value: web3.utils.toWei('4')});

        //provera da je korisnik 1 dobio dovoljno novca za prodate deonice
        // var check7 = await PredictionMarket.getSellersMoney(better1);
        // const ether1 = web3.utils.fromWei(check7, 'ether');
        // assert(ether1 === '4', "Better 1 didn't recieve right amount of money");

        //provera da li se kolicina deonica lepo raspodelila nakon prodaje
        // var check11 = await PredictionMarket.getParticipantBetBuy({from: better1});
        // assert(check11 == 5, "Better 1 number of sheres is not correct");
        // var check11 = await PredictionMarket.getParticipantBetBuy({from: better4});
        // assert(check11 == 20, "Better 4 number of sheres is not correct");
        
        await PredictionMarketMultipleChoice.setTentativeWinningOutcome(Vote.ANSWER1, 105);
       // await PredictionMarketMultipleChoice.setTentativeWinningOutcomeOpenReporter(Vote.ANSWER1, 210); 


       //await PredictionMarketMultipleChoice.disputePredictionOutcame(Vote.ANSWER3, 205, {from: better2, value: web3.utils.toWei('6')});
       //await PredictionMarketMultipleChoice.disputePredictionOutcame(Vote.ANSWER3, 235, {from: better3, value: web3.utils.toWei('6')});
        
        // var check14 = await PredictionMarket.getTentativeWinningOutcome();
        // //uspesno su promenili odgovor
        // assert(check14 == Vote.ANSWER3, "Wrong dispute");

       //await PredictionMarketMultipleChoice.disputePredictionOutcame(Vote.ANSWER1, 275, {from: better1, value: web3.utils.toWei('11')});
       //await PredictionMarketMultipleChoice.disputePredictionOutcame(Vote.ANSWER1, 283, {from: better4, value: web3.utils.toWei('11')});

        // var check15 = await PredictionMarket.getTentativeWinningOutcome();
        //uspesno su promenili odgovor
        // assert(check15 == Vote.ANSWER1, "Wrong dispute");

        //await PredictionMarketMultipleChoice.disputePredictionOutcame(Vote.ANSWER4, 305, {from: better2, value: web3.utils.toWei('21')});
        
        //nije doslo do dispute-a
        //korisnik 2 zeli da mu se vrati novac
        //provera da li je ispravan broj ehtera koji je poslao u dispute

        //var check16 = await PredictionMarketMultipleChoice.checkDisputedMoney(Vote.ANSWER4, {from: better2});
        //const ether1 = web3.utils.fromWei(check16, 'ether');
        //assert(ether1 === '21', "Number of ehter is not correct");

        //await PredictionMarketMultipleChoice.returnDisputeEther( 352, Vote.ANSWER4, {from: better2});
        
        //korisnik treba da pozove ovu funkciju
      //  await PredictionMarketMultipleChoice.rewardCorrectDispute( 352, Vote.ANSWER2, Vote.ANSWER3, Vote.ANSWER4, Vote.INVALID, {from: better1});
      //  await PredictionMarketMultipleChoice.rewardCorrectDispute( 352, Vote.ANSWER2, Vote.ANSWER3, Vote.ANSWER4, Vote.INVALID, {from: better4});
      
        const balanceBefore =(await Promise.all(
                [better1, better2, better3, better4, better5].map(better => (
                    web3.eth.getBalance(better)
                ))
            ))
            .map(balance => web3.utils.toBN(balance)); //dobija se niz stringova

        await Promise.all(
            [better1, better4, better5].map(better => (
                PredictionMarketMultipleChoice.getWinningPrize(800, 0, {from: better})
            ))
        );
        
        const balanceAfter =(await Promise.all(
            [better1, better2, better3, better4, better5].map(better => (
                web3.eth.getBalance(better)
            ))
        ))
        .map(balance => web3.utils.toBN(balance)); //dobija se niz stringova
            assert(balanceAfter[0].sub(balanceBefore[0]).toString().slice(0, 3) === '499',
            'Better 1 didnt recive right amount of money');
            // assert(balanceAfter[4].sub(balanceBefore[4]).toString().slice(0, 3) === '499',
            // 'Better 5 didnt recive right amount of money');
            // assert(balanceAfter[1].sub(balanceBefore[1]).isZero(), 'better 2 didnt lost right amount of money');
            // assert(balanceAfter[2].sub(balanceBefore[2]).isZero(), 'better 3 didnt lost right amount of money');
            // assert(balanceAfter[0].sub(balanceBefore[0]) < 0, 'better 1 didnt lost right amount of money');
            // assert(balanceAfter[3].sub(balanceBefore[3]).toString().slice(0, 3) === '199',
            // 'Better 4 didnt recive right amount of money');
            //ako je trziste invalid, 
            //svi primaju pola nagrade
            // assert(balanceAfter[0].sub(balanceBefore[0]) < 0,
            // 'Better 1 didnt recive right amount of money');
            // assert(balanceAfter[1].sub(balanceBefore[1]).toString().slice(0, 3) === '499',
            // 'Better 2 didnt recive right amount of money');
            // assert(balanceAfter[2].sub(balanceBefore[2]).toString().slice(0, 3) === '499',
            // 'Better 3 didnt recive right amount of money');
            // assert(balanceAfter[3].sub(balanceBefore[3]).toString().slice(0, 3) === '999',
            // 'Better 4 didnt recive right amount of money');
    });
});