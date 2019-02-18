# speaker-sweepstake
Ether sweepstake on the identity of the week8 speaker for the cyptocurrencies MSc-level.

Based on simple smart contract, something like:

```
pragma solidity >=0.4.22 <0.6.0;
contract SpeakerPrediction {   struct Voter {
       string name;
       address payable payoutAddress;
       uint256 amountPaid;
   }   struct Speaker {
       string name;
       Voter[] voters;
   }   //address chairperson;
   mapping(address => Voter) voters;
   Speaker[] speakers;   address owner;   modifier onlyOwner {
       require(owner == msg.sender, "Screw you hacker!");
       _;
   }   constructor() public {
       owner = msg.sender;
       setSpeakers();
   }   function setSpeakers() private {
       speakers[0].name = "Satoshi";
       speakers[1].name = "Nick Johnson";
       speakers[2].name = "Laurence Kirk";
       speakers[3].name = "Oprah Winfrey";
       speakers[4].name = "Craig Wright";
       speakers[5].name = "Carlos Matos";
       speakers[6].name = "Dan North";
       speakers[7].name = "William H. Gates";
   }   function playOurGame (string memory voterName, uint256 speakerIndex) public payable {
       require(speakerIndex < speakers.length,"Speaker unknown");
       speakers[speakerIndex].voters.push(Voter({name:voterName,payoutAddress:msg.sender,amountPaid:msg.value}));
   }   function doPayouts(uint256 speakerIndex) onlyOwner public {       uint256 thisBalance = address(this).balance;       uint256 payout = 0;
       uint256 len = speakers[speakerIndex].voters.length;       // calculate total paid in winning pool
       uint256 totalPaid = 0;
       if(len > 0){
           for(uint i = 0; i < len ; i++){
               totalPaid += speakers[speakerIndex].voters[i].amountPaid;
           }
       }       // for each speaker divi out money in pool (value.balance) out appropriately       // payout = totalPaid/amountPaid * amount in pool       if(len > 0){
           for(uint i = 0; i < len ; i++){               // rounding!!!
               payout = thisBalance * totalPaid / speakers[speakerIndex].voters[i].amountPaid;               // shouldn't really payout like this BUT ... we don't care!!!               // transfer to winner
               // transfer(payout);               speakers[speakerIndex].voters[i].payoutAddress.transfer(payout);
           }
       }
   }
}
```

