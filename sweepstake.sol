pragma solidity >=0.5.4 <0.6.0;
contract SpeakerPrediction {

    struct Speaker {
      string name;
      uint256[] votes;
  }

    struct Voter {
      string name;
      address payable payoutAddress;
      uint256 betAmount;
      // required to prevent constant payments to
      bool paidOut;
  }

  Speaker[] speakers;

  mapping (address => uint256) pendingWithdrawals;
  mapping (uint256 => Voter) allVotes;
  uint256 nextEmptyVote = 0;
  address owner;

  modifier onlyOwner {
      require(owner == msg.sender, "Screw you hacker!");
      _;
  }

  modifier onlyOwnerUnlessFee {
     require ((msg.value >= 420 szabo || owner == msg.sender), "Costs ETH0.00042 to add a speaker");
      _;
  }

  constructor() public {
      owner = msg.sender;
      setSpeakers();
  }

//   function setSpeakers() public {
//      uint256[] memory l;
//      speakers.push(Speaker("Satoshi",l));
//      speakers.push(Speaker("Nick Johnson",l));
//      speakers.push(Speaker("Laurence Kirk",l));
//      speakers.push(Speaker("Oprah Winfrey",l));
//      speakers.push(Speaker("Craig Wright",l));
//      speakers.push(Speaker("Carlos Matos",l));
//      speakers.push(Speaker("Dan North",l));
//      speakers.push(Speaker("William H. Gates",l));
//  }


  function setSpeakers() public {
     addSpeaker("Satoshi");
     addSpeaker("Nick Johnson");
     addSpeaker("Laurence Kirk");
     addSpeaker("Oprah Winfrey");
     addSpeaker("Craig Wright");
     addSpeaker("Carlos Matos");
     addSpeaker("Dan North");
     addSpeaker("William H. Gates");
 }

 function addSpeaker (string memory _speakerName)  onlyOwnerUnlessFee public payable returns (uint256) {
     //require a fee to raise the cost of array-spamming gas exhaustion attack.
     require (msg.value >= 420 szabo || owner == msg.sender);
     uint256[] memory l;
     speakers.push(Speaker(_speakerName,l));
     return (speakers.length-1);
}

function speakersLength () public view returns (uint256) {
    return (speakers.length);
}

function speakerNameAt (uint256 speakerIndex) public view returns (string memory) {
    return (speakers[speakerIndex].name);
}

function speakerBalanceAt (uint256 speakerIndex) public view returns (uint256) {
    uint256 i= speakers[speakerIndex].votes.length;
    uint256 total= 0;
    while (i-- > 0) {
        total += allVotes[(speakers[speakerIndex].votes[i])].betAmount;
    }
    return (total);
}

 function playOurGame (uint256 speakerIndex, string memory voterName) public payable {
     require(speakerIndex < speakers.length,"Speaker unknown");
     Voter memory _voter;
     _voter.name = voterName;
     _voter.payoutAddress = msg.sender;
     _voter.betAmount = msg.value;
     _voter.paidOut = false;

     allVotes[nextEmptyVote] = _voter;
     speakers[speakerIndex].votes.push(nextEmptyVote);
     nextEmptyVote++;
 }

 function doPayouts(uint256 speakerIndex) onlyOwner public returns (uint256) {
     uint256 thisBalance = address(this).balance;
     uint256 payout = 0;
     uint256 len = speakers[speakerIndex].votes.length;
     // calculate total betAmount in winning pool
     uint256 totalPaid = 0;
     uint256 i = nextEmptyVote;
     while (i-- > 0) {
         totalPaid += allVotes[i].betAmount;
         // if nobody voted for the winning speaker, iterat4e over all bets and pay back
         if (len==0) {
             if (!allVotes[i].paidOut) {
                 payout = allVotes[i].betAmount;
                 allVotes[i].paidOut = true;
                 address _voterAddress = allVotes[i].payoutAddress;
                 pendingWithdrawals[_voterAddress] = payout;
             }
         }

     }

     // calculate and transfer amount to winner's pot
     if(len > 0){
         for(uint i = 0; i < len ; i++){
             uint256 _vote = speakers[speakerIndex].votes[i];
             // check if paid here;
             if(allVotes[_vote].paidOut == false){
                 // set paidOut=true to prevent draining account
                 allVotes[_vote].paidOut = true;
                 // rounding!
                 payout = thisBalance * totalPaid / allVotes[_vote].betAmount;
                 // transfer to winner's pendingWithdrawal pot
                 address _voterAddress = allVotes[_vote].payoutAddress;
                 pendingWithdrawals[_voterAddress] = payout;
             }
         }
     }
 }

 function withdraw() public {
       uint256 amount = pendingWithdrawals[msg.sender];
       // Remember to zero the pending refund before
       // sending to prevent re-entrancy attacks
       pendingWithdrawals[msg.sender] = 0;
       msg.sender.transfer(amount);
 }
}
