var predictionMarket = artifacts.require('setBet');

contract('predictionMarket', addresses => {
    const [creator, better1, better2, better3, better4, better5, _] = addresses;
       const Vote = {
            YES: 0,
            NO: 1,
            INVALID: 2
        }
    it('yes/no prediction market worked', async () => {

        const PredictionMarket = await predictionMarket.new();
        // const predMarket2 = await predictionMarket.new();

        // await predMarket.setCreator(
        //     {from: creator}
        // );
        // await predMarket2.setCreator(
        //     {from: better1}
        // );

        await PredictionMarket.setPredictionMarket("Will Novak Djokovic play finale of Wimbledon?", 'Sport', 'Tennis',
        100, 'If you think Novak will play in the finale say yes, if you think he will not play in the finale say no',
        1, {from: creator});

        await PredictionMarket.setValidityBond({from: creator, value:  web3.utils.toWei('5')});
        await PredictionMarket.setNoShowBond({from: creator, value:  web3.utils.toWei('3')});

        //provera da li je unos za trziste predvidjanja dobar
        var check = await PredictionMarket.readPrediction();
        assert(check === 'Will Novak Djokovic play finale of Wimbledon?', "Prediction input is not correct");
        var check1 = await PredictionMarket.getCategory();
        assert(check1 === 'Sport', "Category is not correct");
        var check2 = await PredictionMarket.getTags();
        assert(check2 === 'Tennis', "Tag is not correct");
        var check3 = await PredictionMarket.getEndTime();
        assert(check3 == 100, "End time of prediction is not correct");
        var check4 = await PredictionMarket.getAdditionalDetails();
        assert(check4 === 'If you think Novak will play in the finale say yes, if you think he will not play in the finale say no',
        'Prediction details are not correct');
        var check5 = await PredictionMarket.getCreatorFee();
        assert(check5 == 1, "Creator fee is not correct");
        var check6 = await PredictionMarket.getCreator();
        assert(check6 === creator, "Market creator is not correct");

        //opciono, da se postavi likvidnost
        //toWei sheres je pomnozen sa etherom koji se salje
        await PredictionMarket.setInitialLiquidity(Vote.YES, 5, {from: creator, value:  web3.utils.toWei('5')});

        // var check7 = await PredictionMarket.getParticipantBetBuy({from: creator});
        // assert(check7 == 5, "Market liquidity is not correct");

        //provera da li ima dovoljno novca u ugovoru
        // var check7 = await PredictionMarket.getBetsFor();
        // const ether1 = web3.utils.fromWei(check7, 'ether');
        // assert(ether1 === '2.6', "Bets for yes are not correct");

        await PredictionMarket.setParticipantBetBuy( 10, 15, {from: better1, value: web3.utils.toWei('7')}); //0.70
        await PredictionMarket.setParticipantBetSell(15, 25, {from: better3, value: web3.utils.toWei('6')}); //0.40
        await PredictionMarket.setParticipantBetBuy( 10, 15, {from: better5, value: web3.utils.toWei('5')});
        // var check8 = await PredictionMarket.getParticipantBetBuy({from: better1});
        // assert(check8 == 10, "Better 1 number of sheres is not correct");
        // var check9 = await PredictionMarket.getParticipantBetSell({from: better3});
        // assert(check9 == 15, "Better 3 number of sheres is not correct");

        // var check7 = await PredictionMarket.getBetsFor();
        // const ether1 = web3.utils.fromWei(check7, 'ether');
        // assert(ether1 === '9.5', "Bets for yes are not correct");

        //kadad korisnik dobije protivnika, opklade pocinju
        await PredictionMarket.setParticipantBetOpponentBuy(better1, 10, 32, {from: better2, value: web3.utils.toWei('3')}); //0.30
        await PredictionMarket.setParticipantBetOpponentSell(better3, 15, 38, {from: better4, value: web3.utils.toWei('9')}); //0.60 
        

        await PredictionMarket.setToSellBuy(5, 80, {from: better1});

        //provera po kojoj ceni korisnik zeli da kupi ili proda deonice
        // var check10 = await PredictionMarket.getSetToSellBuy({from: better1});
        // assert(check10 == 80, "Selling price is not correct");


        await PredictionMarket.buySomeonesBuyBet(better1, {from: better4, value: web3.utils.toWei('4')});

        //provera da je korisnik 1 dobio dovoljno novca za prodate deonice
        // var check7 = await PredictionMarket.getSellersMoney(better1);
        // const ether1 = web3.utils.fromWei(check7, 'ether');
        // assert(ether1 === '4', "Better 1 didn't recieve right amount of money");

        //provera da li se kolicina deonica lepo raspodelila nakon prodaje
        // var check11 = await PredictionMarket.getParticipantBetBuy({from: better1});
        // assert(check11 == 5, "Better 1 number of sheres is not correct");
        // var check11 = await PredictionMarket.getParticipantBetBuy({from: better4});
        // assert(check11 == 20, "Better 4 number of sheres is not correct");

        //korisnik zeli da od trzista dobije novac nazad
        await PredictionMarket.settleCompleteSetBuy(5, 900, 58, {from: better1});

        // var check12 = await PredictionMarket.getsettleCompleteSetBuy({from: better1});
        // assert(check12 == 5, "Better 1 number of sheres is not correct");

        await PredictionMarket.buySomeonesSettleCompleteSetBuy(better1, 65, {from: better3});

        //provera da li korisnici nakon prodaje 
        //imaju ispravan broj deonica
        // var check12 = await PredictionMarket.getParticipantBetBuy({from: better1});
        // assert(check12 == 0, "Better 1 number of sheres is not correct");
        // var check13 = await PredictionMarket.getParticipantBetSell({from: better3});
        // assert(check13 == 10, "Better 3 number of sheres is not correct");
        
        await PredictionMarket.setTentativeWinningOutcome(Vote.YES, 105);
        //await PredictionMarket.setTentativeWinningOutcomeOpenReporter(Vote.YES, 210); 


        await PredictionMarket.disputePredictionOutcame(Vote.NO, 205, {from: better2, value: web3.utils.toWei('6')});
        await PredictionMarket.disputePredictionOutcame(Vote.NO, 235, {from: better3, value: web3.utils.toWei('6')});
        //var check14 = await PredictionMarket.getTentativeWinningOutcome();
        //uspesno su promenili odgovor
        //assert(check14 == Vote.NO, "Wrong dispute");

        await PredictionMarket.disputePredictionOutcame(Vote.YES, 275, {from: better1, value: web3.utils.toWei('11')});
        await PredictionMarket.disputePredictionOutcame(Vote.YES, 295, {from: better4, value: web3.utils.toWei('11')});

        //var check15 = await PredictionMarket.getTentativeWinningOutcome();
        //uspesno su promenili odgovor
        //assert(check15 == Vote.YES, "Wrong dispute");

        //provera da trziste postane invalid
        // await PredictionMarket.disputePredictionOutcame(Vote.NO, 305, {from: better2, value: web3.utils.toWei('21')});
        // await PredictionMarket.disputePredictionOutcame(Vote.NO, 351, {from: better3, value: web3.utils.toWei('25')});
        // var check15 = await PredictionMarket.getTentativeWinningOutcome();
        // //uspesno su promenili odgovor
        // assert(check15 == Vote.INVALID, "Wrong dispute");

        await PredictionMarket.disputePredictionOutcame(Vote.NO, 321, {from: better2, value: web3.utils.toWei('21')});
        //nije doslo do dispute-a
        //korisnik 2 zeli da mu se vrati novac
        //provera da li je ispravan broj ehtera koji je poslao u dispute

       // var check16 = await PredictionMarket.checkDisputedMoney(Vote.NO, {from: better2});
       // const ether1 = web3.utils.fromWei(check16, 'ether');
       // assert(ether1 === '21', "Number of ehter is not correct");

        await PredictionMarket.returnDisputeEther( 352, Vote.NO, {from: better2});
        //korisnik treba da pozove ovu funkciju
        await PredictionMarket.rewardCorrectDispute( 402, Vote.NO, Vote.INVALID, {from: better1});
        await PredictionMarket.rewardCorrectDispute( 402, Vote.NO, Vote.INVALID, {from: better4});
      
        const balanceBefore =(await Promise.all(
                [better1, better2, better3, better4, better5].map(better => (
                    web3.eth.getBalance(better)
                ))
            ))
            .map(balance => web3.utils.toBN(balance)); //dobija se niz stringova

        await Promise.all(
            [better1, better4, better5].map(better => (
                PredictionMarket.getWinningPrize(800,{from: better})
            ))
        );
        
        const balanceAfter =(await Promise.all(
            [better1, better2, better3, better4, better5].map(better => (
                web3.eth.getBalance(better)
            ))
        ))
        .map(balance => web3.utils.toBN(balance)); //dobija se niz stringova
            // assert(balanceAfter[4].sub(balanceBefore[4]).toString().slice(0, 3) === '449',
            // 'Creator didnt recive right amount of money');
            assert(balanceAfter[4].sub(balanceBefore[4]).toString().slice(0, 3) === '499',
            'Better 5 didnt recive right amount of money');
            assert(balanceAfter[1].sub(balanceBefore[1]).isZero(), 'better 2 didnt lost right amount of money');
            assert(balanceAfter[2].sub(balanceBefore[2]).isZero(), 'better 3 didnt lost right amount of money');
            assert(balanceAfter[0].sub(balanceBefore[0]) < 0, 'better 1 didnt lost right amount of money');
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