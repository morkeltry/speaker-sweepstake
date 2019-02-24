
var contract;
const contract_address = '0x';
const abi = {};
var user_address = '0x';
var baseTx = {
      gasPrice: "21000000000",
      gas: "85000",
      to: contract_address,
      value: 1000000000000000
    };

  const doTheWeb3 = function() {
		// Load WEB3
		// Check wether it's already injected by something else (like Metamask or Parity Chrome plugin)
		if(typeof web3 !== 'undefined') {
			web3 = new Web3(web3.currentProvider);
		// Or connect to a node
		} else {
			web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
		}

    web3.eth.net.isListening().then(ready => {
      if (ready) {
    		web3.eth.getAccounts()
        .then (accounts=> {
          console.log(accounts);
          account = accounts[0];
      		document.getElementById("user_eth_address").value = account;
      		var accountInterval = setInterval(function() {
      			if (web3.eth.accounts[0] !== account)
      			{
      				account = web3.eth.accounts[0];
      				if(account)
      				{
      					web3.version.getNetwork((err, netId) => {
      						if(netId == 1)
      						{
      							//window.location = 'index.html';
      							document.getElementById("address").innerHTML = account;
      							document.getElementById("borrower_eth_address").value = account;
      						}
      						else
      						{
      							window.location = 'index.html';
      						}
      					})
      				}
      				else
      				{
      					//window.location = 'index.html';
      				}
    			}
    		}, 100);

        web3.eth.getAccounts(function(err, accounts){
        	if (accounts.length == '') window.location = 'index.html';
        });

        baseTx.from= web3.eth.accounts[0];

        populate()

      })} else {
        console.log('Fell over :(');
      }

    });



};

function updateWithSuccess (speakerIndex, speakerName) {
  if (document.getElementById('speaker '+speakerIndex)) {
    // speaker exists - guess that was a bet placed, then.
    // Find speaker odds. Update value.
  } else {
    // speaker doesn't exist in form yet. Add them.
    populate([speakerName], startIndex);
  };
};


function submitBet (ev) {
  if (contract) {
    ev.preventDefault();
    const form = ev.target.form;
    console.log(form);
    const value = form.amount.value || 1000000000000000;
    const speaker = form.speaker.value;
    const user = form.user.value;
    console.log('got: ',amount,speaker,user,' with value',value);
    const tx = Object.assign ( {}, baseTx, { value });
    console.log(tx);

    contract.playOurGame(speaker, user, tx, function (err, result){
       if (err)
        console.log(err);
      else {
        updateWithSuccess(speaker);
      }
    });

  } else {
    console.log('Easy, tiger! No contract connected yet!');
  }
}

var doSubmit = submitBet;

function addSpeaker (ev) {
  const tx = Object.assign ( {}, baseTx, { value : 420000000000000 });
  contract.addSpeaker(speakerName, tx, function (err, result){
     if (err)
      console.log(err);
    else {
      updateWithSuccess(result, speakerName);
    }
  });

};


function getSpeakers (contract) {
  contract = web3.eth.contract(abi).at(contract_address)
  // use .call for non-mutating functions
  contract.methods.speakersLength().call( 'dummy', function (err, response) {
    if (err)
      console.log('getSpeakers() error:',err);
    else {
      let waiting = true;
      const speakersNames = [];
      const speakersDosh = [];
      console.log('getSpeakers() response:', response, 'speakers found.');
      let i=response;
      const errors = []
      // Retro fun! Build your own system to return arrays! Build Promise.all in ES5 !
      while (i--) {
        contract.methods.speakerBalanceAt(i, function (err, response) {
          if (err) errors.push(err);
          speakersDosh.push(response);
        });
        contract.methods.speakerNameAt(i, function (err, response) {
          if (err) errors.push(err);
          speakersNames.push(response);
        });
      };
      waiting = setInterval (50, function () {
        if (speakerNameAt.every (function(name, idx) { return name || errors(idx) })) {
          clearInterval(waiting);
          waiting = false;
      }});
      while (waiting) {
      };

      if (speakersNames[0] != 'Satoshi')
        console.error('Some kind of array error there :(');
      else {
        populate (speakersNames, 0, speakersDosh);
        // NB balances currently ignored as not yet displayed..
      }
    }
  });
}


document.getElementById('bet').addEventListener ('click', doSubmit)

window.addEventListener('load', ()=>{
  doTheWeb3();
  populate();
  populateUserAccount();
});

// 	$(function()
// 	{
// 	  $('.number-only').keyup(function(e) {
// 			if(this.value!='-')
// 			  while(isNaN(this.value))
// 				this.value = this.value.split('').reverse().join('').replace(/[\D]/i,'')
// 									   .split('').reverse().join('');
// 		})
// });



function populateUserAccount () {
  const foundAddresses = web3.eth.accounts[0];
  console.log('foundAddresses',foundAddresses);
	if (foundAddresses && foundAddresses.length) {
    user_address = foundAddresses[0];
    getElementById ('user_eth_address').setAttribute('value', user_address);
  };
};

function populate (speakers, startIndex, speakerBalances) {
  console.log('called populate with', speakers);
	speakers = speakers || ['Satoshi', 'Craig Wright', 'Antonio', 'More Antonio', 'Vitalik'];
  startIndex = startIndex ||0;
  console.log('speakers : ', speakers);

  const speakersDiv = document.getElementById('speakers');

  speakers.forEach ((speaker, idx)=> {
    console.log(speaker);
    const div=document.createElement ('div');
    const radio=document.createElement ('input');
    const text=document.createTextNode(speaker);
    radio.setAttribute('type', 'radio');
    radio.setAttribute('name', 'speaker');
    radio.setAttribute('value', idx+startIndex);
    radio.setAttribute('id', 'speaker '+idx+startIndex);
    radio.setAttribute('class', 'form-control');
    speakersDiv.appendChild (radio);
    speakersDiv.appendChild (text);
    console.log(document.getElementById('speaker '+idx+startIndex));
    document.getElementById('speaker '+idx+startIndex).classList.remove("hidden");

  });
};
