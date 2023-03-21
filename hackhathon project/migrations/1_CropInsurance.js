// migrations/1_deploy_contract.js
const CropInsurance = artifacts.require("CropInsurance");

module.exports = function (deployer) {
  deployer.deploy(CropInsurance, 100, 1000, 50, "0x123...", "0x456...");
};
