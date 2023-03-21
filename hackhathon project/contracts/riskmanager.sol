// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface WeatherData {
    function getWeather() external view returns (uint);
}

contract Insurance {
    uint public balance;
    address payable public riskManager;
    
    event PolicyCreated(address indexed _riskManager);
    event PremiumReceived(uint _amount);
    event Payout(address indexed _recipient, uint _amount);
    
    constructor(address payable _riskManager) {
        riskManager = _riskManager;
        emit PolicyCreated(_riskManager);
    }
    
    function payPremium() public payable {
        require(msg.value > 0, "Premium amount must be greater than zero");
        balance += msg.value;
        emit PremiumReceived(msg.value);
    }
    
    function pay(uint _amount) public {
        require(msg.sender == riskManager, "Only the risk manager can make payouts");
        require(_amount <= balance, "Insufficient funds");
        
        riskManager.transfer(_amount);
        balance -= _amount;
        emit Payout(riskManager, _amount);
    }
}

contract RiskManager {
    address payable public insurer;
    address payable public farmer;
    uint public premium;
    uint public coverageAmount;
    uint public triggerThreshold;
    bool public policyActive;
    bool public claimSubmitted;
    bool public claimApproved;
    uint public payoutAmount;
    Insurance public insurance;
    WeatherData public weatherData;
    
    event PolicyCreated(address indexed _insurer, address indexed _farmer, uint _premium, uint _coverageAmount, uint _triggerThreshold);
    event PolicyActivated();
    event PolicyCancelled();
    event ClaimSubmitted();
    event ClaimApproved(uint _payoutAmount);
    event ClaimRejected();
    
    constructor(
        address payable _insurer,
        address payable _farmer,
        uint _premium,
        uint _coverageAmount,
        uint _triggerThreshold,
        address _weatherDataContract
    ) {
        insurer = _insurer;
        farmer = _farmer;
        premium = _premium;
        coverageAmount = _coverageAmount;
        triggerThreshold = _triggerThreshold;
        weatherData = WeatherData(_weatherDataContract);
        insurance = new Insurance(payable(address(this)));
        emit PolicyCreated(_insurer, _farmer, _premium, _coverageAmount, _triggerThreshold);
    }
    
    function activatePolicy() public {
        require(policyActive == false, "Policy is already active");
        require(msg.sender == farmer, "Only the farmer can activate the policy");
        policyActive = true;
        emit PolicyActivated();
    }
    
    function cancelPolicy() public {
        require(policyActive == true, "Policy is already cancelled");
        require(msg.sender == farmer || msg.sender == insurer, "Only the farmer or insurer can cancel the policy");
        policyActive = false;
        uint balance = insurance.balance();
        if (balance > 0) {
            insurer.transfer(balance);
        }
        emit PolicyCancelled();
    }
    
    function submitClaim() public {
        require(policyActive == true, "Policy is not active");
        require(claimSubmitted == false, "Claim has already been submitted");
        require(msg.sender == farmer, "Only the farmer can submit a claim");
        uint weatherValue = weatherData.getWeather();
        if (weatherValue <= triggerThreshold) {
            claimApproved = true;
            payoutAmount = coverageAmount;
            insurance.pay(payoutAmount);
            emit ClaimApproved(payoutAmount);
        } else {
            claimApproved = false;
            emit ClaimRejected();
        }
        claimSubmitted = true;
        emit ClaimSubmitted();
    }
}