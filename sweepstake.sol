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

    // Initialise the mutex to lock contract during execution of withdraw function
    bool reEntrancyMutex = false;

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
        // require a fee to raise the cost of array-spamming gas exhaustion attack.
        require ((msg.value >= 420 szabo || owner == msg.sender), "Costs ETH0.00042 to add a speaker");
        _;
    }

    constructor() public {
        owner = msg.sender;
        // Set an initial list of speakers when contract is deployed
        uint256[] memory l;
        speakers.push(Speaker("Satoshi Nakamoto",l));
        speakers.push(Speaker("Dorian Nakamoto",l));
        speakers.push(Speaker("Antonio Sabado",l));
        speakers.push(Speaker("Nick Johnson",l));
        speakers.push(Speaker("Nick Szabo",l));
        speakers.push(Speaker("Wei Dai",l));
        speakers.push(Speaker("Craig Wright",l));
        speakers.push(Speaker("Carlos Matos",l));
        speakers.push(Speaker("Ross Ulbricht",l));
        speakers.push(Speaker("Amir Taaki",l));
        speakers.push(Speaker("Gavin Wood",l));
        speakers.push(Speaker("Stephen Tual",l));
        speakers.push(Speaker("Joseph Lubin",l));
        speakers.push(Speaker("Afri Schoedon",l));
        speakers.push(Speaker("Raul Jordan",l));
        speakers.push(Speaker("Jutta Steiner",l));
        speakers.push(Speaker("Björn Wagner",l));
        speakers.push(Speaker("Vitalik Buterin",l));
        speakers.push(Speaker("Vlad Zamfir",l));
        speakers.push(Speaker("Mihai Alisie",l));
        speakers.push(Speaker("Justin Drake",l));
        speakers.push(Speaker("Virgil Griffith",l));
        speakers.push(Speaker("Zach Lebeau",l));
        speakers.push(Speaker("Anthony Di Lorio",l));
        speakers.push(Speaker("Charles Hoskinson",l));     

        // What do we do with the one below ?
        /*
        
        speakers.push(Speaker("Laurence Kirk",l));
        speakers.push(Speaker("Oprah Winfrey",l));        
        speakers.push(Speaker("Dan North",l));
        speakers.push(Speaker("William H. Gates",l));
        */
    }

    /// Add a new speaker
    /// @param string       Name of the speaker to add
    /// @dev                Require to be only the Contract owner or to pay a fee
    /// @return uint256     Return the index of the speaker in the array
    function addSpeaker (string memory _speakerName) public payable onlyOwnerUnlessFee returns (uint256) {  
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


    /// Withdraw to Ethereum Address
    /// @dev implements mutex + set balance to 0 before to prevent re-entrancy attacks
    ///
    function withdraw() public {
        require(!reEntrancyMutex);
        uint256 amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;

        // set the reEntrancy mutex before the external call
        reEntrancyMutex = true;
        msg.sender.transfer(amount);
        // release the mutex after the external call
        reEntrancyMutex = false;
    }

}