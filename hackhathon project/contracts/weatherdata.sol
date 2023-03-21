// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract WeatherData {
    address owner;
    uint temperature;
    uint humidity;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    function setTemperature(uint _temperature) public onlyOwner {
        temperature = _temperature;
    }

    function setHumidity(uint _humidity) public onlyOwner {
        humidity = _humidity;
    }

    function getTemperature() public view returns (uint) {
        return temperature;
    }

    function getHumidity() public view returns (uint) {
        return humidity;
    }
}
