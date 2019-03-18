var SpeakerPrediction = artifacts.require("SpeakerPrediction");

module.exports = function(deployer) {
    deployer.deploy(SpeakerPrediction, "sweepstake");
    // Additional contracts can be deployed here
};
