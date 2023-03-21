//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract CropInsurance {
    
    uint public premium;
    uint public coverageAmount;
    uint public triggerThreshold;
    uint public balance;
    uint public payoutAmount;
    address payable public insurer;
    address payable public farmer;
    bool public policyActive;
    bool public claimSubmitted;
    bool public claimApproved;
    
    event PolicyCreated(uint _premium, uint _coverageAmount, uint _triggerThreshold, address _insurer, address _farmer);
    event PremiumPaid(uint _premium);
    event PayoutAmountCalculated(uint _payoutAmount);
    event ClaimSubmitted();
    event ClaimApproved(uint _payoutAmount);
    event ClaimRejected();
    
    constructor(uint _premium, uint _coverageAmount, uint _triggerThreshold, address payable _insurer, address payable _farmer) {
        premium = _premium;
        coverageAmount = _coverageAmount;
        triggerThreshold = _triggerThreshold;
        insurer = _insurer;
        farmer = _farmer;
        policyActive = true;
        emit PolicyCreated(_premium, _coverageAmount, _triggerThreshold, _insurer, _farmer);
    }
    
    function payPremium() public payable {
        require(msg.value == premium, "Incorrect premium amount");
        balance += msg.value;
        emit PremiumPaid(msg.value);
    }
    
    function calculatePayoutAmount() private {
        payoutAmount = coverageAmount;
        emit PayoutAmountCalculated(payoutAmount);
    }
    
    function submitClaim() public {
        require(policyActive, "Policy not active");
        require(!claimSubmitted, "Claim already submitted");
        require(msg.sender == farmer, "Only the farmer can submit a claim");
        
        // Call machine learning function to determine weather conditions
        // and compare with trigger threshold
        uint weatherValue = getWeatherValue(); // Example function for getting weather data
        if (weatherValue <= triggerThreshold) {
            claimApproved = true;
            calculatePayoutAmount();
            emit ClaimApproved(payoutAmount);
        } else {
            claimApproved = false;
            emit ClaimRejected();
        }
        claimSubmitted = true;
    }
    
    function payout() public {
        require(policyActive, "Policy not active");
        require(claimSubmitted, "No claim submitted");
        require(claimApproved, "Claim not approved");
        require(msg.sender == insurer, "Only the insurer can make payouts");
        
        insurer.transfer(payoutAmount);
        balance -= payoutAmount;
        policyActive = false;
    }
    
    function cancelPolicy() public {
        require(msg.sender == insurer, "Only the insurer can cancel the policy");
        require(policyActive, "Policy not active");
        
        insurer.transfer(balance);
        balance = 0;
        policyActive = false;
    }
    
    function getContractBalance() public view returns (uint) {
        return balance;
    }
    
    function getWeatherValue() public pure returns (uint) {
        // Example function to get weather data and return a numeric value
        // This can be replaced with the actual machine learning function
        return 75;
    }
    
}
