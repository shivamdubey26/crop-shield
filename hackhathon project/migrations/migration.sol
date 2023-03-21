// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "contracts/riskmanager.sol";
import "contracts/weatherdata.sol";

contract Migrations {
    address public owner;
    uint public last_completed_migration;

    constructor() {
        owner = msg.sender;
    }

    modifier restricted() {
        require(msg.sender == owner, "This function is restricted to the contract's owner");
        _;
    }

    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    function deployContracts(
        address payable _insurer,
        address payable _farmer,
        uint _premium,
        uint _coverageAmount,
        uint _triggerThreshold,
        uint _weatherValue
    ) public {
        WeatherData weatherData = new WeatherData();
        weatherData.setTemperature(_weatherValue);
        weatherData.setHumidity(50);

        RiskManager riskManager = new RiskManager(
            _insurer,
            _farmer,
            _premium,
            _coverageAmount,
            _triggerThreshold,
            address(weatherData)
        );
    }
}
